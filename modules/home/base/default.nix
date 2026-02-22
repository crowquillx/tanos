{ lib, pkgs, vars ? { }, inputs, options, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  dsearchEnabled = get [ "features" "danksearch" "enable" ] true;
  browserDefault = get [ "desktop" "browser" "default" ] "firefox";
  firefoxEnabled = get [ "desktop" "browser" "firefox" "enable" ] true;
  zenEnabled = get [ "desktop" "browser" "zen" "enable" ] false;
  chromeEnabled = get [ "desktop" "browser" "chrome" "enable" ] false;
  heliumEnabled = get [ "desktop" "browser" "helium" "enable" ] false;

  zenPkg = lib.attrByPath [ "zen-browser" "packages" pkgs.system "default" ] null inputs;
  heliumPkg =
    lib.findFirst (pkg: pkg != null) null [
      (lib.attrByPath [ "helium2nix" "packages" pkgs.system "default" ] null inputs)
      (lib.attrByPath [ "helium2nix" "packages" pkgs.system "helium" ] null inputs)
      (lib.attrByPath [ "helium2nix" "packages" pkgs.system "helium-browser" ] null inputs)
    ];

  allowedBrowsers = [ "firefox" "zen" "chrome" "helium" ];
  browserEnabledMap = {
    firefox = firefoxEnabled;
    zen = zenEnabled;
    chrome = chromeEnabled;
    helium = heliumEnabled;
  };
  browserPackageMap = {
    firefox = pkgs.firefox;
    zen = zenPkg;
    chrome = pkgs.google-chrome;
    helium = heliumPkg;
  };
  desktopFileFor = pkg: fallback:
    if pkg == null then fallback else (pkg.meta.desktopFileName or fallback);
  browserDesktopMap = {
    firefox = "firefox.desktop";
    zen = desktopFileFor zenPkg "zen.desktop";
    chrome = "google-chrome.desktop";
    helium = desktopFileFor heliumPkg "helium.desktop";
  };
  browserPkg = lib.attrByPath [ browserDefault ] null browserPackageMap;
  browserDesktopFile = lib.attrByPath [ browserDefault ] "firefox.desktop" browserDesktopMap;
  browserMimeTypes = [
    "application/xhtml+xml"
    "text/html"
    "x-scheme-handler/about"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/unknown"
  ];
  browserAssociations =
    builtins.listToAttrs (map (mime: {
      name = mime;
      value = browserDesktopFile;
    }) browserMimeTypes);
in
({
  assertions = [
    {
      assertion = builtins.elem browserDefault allowedBrowsers;
      message = "Unsupported desktop.browser.default \"${browserDefault}\". Allowed values: firefox, zen, chrome, helium.";
    }
    {
      assertion = lib.attrByPath [ browserDefault ] false browserEnabledMap;
      message = "desktop.browser.default is \"${browserDefault}\" but desktop.browser.${browserDefault}.enable is false.";
    }
    {
      assertion = !(zenEnabled && zenPkg == null);
      message = "desktop.browser.zen.enable is true, but zen-browser package could not be resolved from flake input.";
    }
    {
      assertion = !(heliumEnabled && heliumPkg == null);
      message = "desktop.browser.helium.enable is true, but helium2nix package could not be resolved from flake input.";
    }
    {
      assertion = !(browserDefault == "helium" && browserPkg == null);
      message = "desktop.browser.default = \"helium\" requires a resolvable helium2nix package.";
    }
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages =
    (with pkgs; [
      # General user tooling should be HM-managed.
      alacritty
      foot
      fuzzel
      waybar
      wl-clipboard
      cliphist
      pavucontrol
      brightnessctl
      playerctl
      grim
      slurp
      networkmanagerapplet
      fzf
      bat
      eza
      jq
      ripgrep
      fd
      unzip
      zip
      vim
      neovim
      htop
      fastfetch
      wget
      curl
    ])
    ++ lib.optionals firefoxEnabled [ pkgs.firefox ]
    ++ lib.optionals (zenEnabled && zenPkg != null) [ zenPkg ]
    ++ lib.optionals chromeEnabled [ pkgs.google-chrome ]
    ++ lib.optionals (heliumEnabled && heliumPkg != null) [ heliumPkg ]
    ++ lib.optionals (get [ "desktop" "enable" ] true) (with pkgs; [
      # Desktop helpers commonly used by shell overlays.
      libnotify
    ]);

  programs.git.enable = true;
  programs.bash.enable = true;

  xdg = {
    enable = true;
    userDirs.enable = true;
    # Avoid repeated activation failures when a previous backup file already exists.
    configFile."user-dirs.dirs".force = true;
    mimeApps = {
      enable = true;
      defaultApplications = browserAssociations;
      associations.added = browserAssociations;
    };
  };

  gtk = lib.mkIf (get [ "desktop" "enable" ] true) {
    enable = true;
  };
}
// lib.optionalAttrs (options ? programs.dsearch.enable) {
  programs.dsearch.enable = dsearchEnabled;
})
