{ lib, pkgs, vars ? { }, inputs, config, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  thunarEnabled = get [ "features" "fileManager" "thunar" "enable" ] (get [ "desktop" "enable" ] true);
  system = pkgs.stdenv.hostPlatform.system;
  gitUserName = get [ "users" "git" "name" ] null;
  gitUserEmail = get [ "users" "git" "email" ] null;
  browserDefault = get [ "desktop" "browser" "default" ] "firefox";
  firefoxEnabled = get [ "desktop" "browser" "firefox" "enable" ] true;
  zenEnabled = get [ "desktop" "browser" "zen" "enable" ] false;
  chromeEnabled = get [ "desktop" "browser" "chrome" "enable" ] false;
  heliumEnabled = get [ "desktop" "browser" "helium" "enable" ] false;
  fishEnabled = get [ "features" "shell" "fish" "enable" ] true;

  zenPkg = lib.attrByPath [ "zen-browser" "packages" system "default" ] null inputs;
  thunarPkg =
    let
      topLevelPkg = lib.attrByPath [ "thunar" ] null pkgs;
    in
    topLevelPkg;
  thunarArchivePluginPkg =
    let
      topLevelPkg = lib.attrByPath [ "thunar-archive-plugin" ] null pkgs;
    in
    topLevelPkg;
  xfconfPkg =
    let
      topLevelPkg = lib.attrByPath [ "xfconf" ] null pkgs;
      xfcePkg = lib.attrByPath [ "xfce" "xfconf" ] null pkgs;
    in
    if topLevelPkg != null then topLevelPkg else xfcePkg;
  archiveManagerPkg =
    let
      fileRoller = lib.attrByPath [ "file-roller" ] null pkgs;
      xarchiver = lib.attrByPath [ "xarchiver" ] null pkgs;
    in
    if fileRoller != null then fileRoller else xarchiver;
  heliumPkg =
    lib.findFirst (pkg: pkg != null) null [
      (lib.attrByPath [ "helium2nix" "packages" system "default" ] null inputs)
      (lib.attrByPath [ "helium2nix" "packages" system "helium" ] null inputs)
      (lib.attrByPath [ "helium2nix" "packages" system "helium-browser" ] null inputs)
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
    {
      assertion = (gitUserName == null) == (gitUserEmail == null);
      message = "Set both users.git.name and users.git.email (or leave both unset).";
    }
    {
      assertion = !(thunarEnabled && thunarPkg == null);
      message = "features.fileManager.thunar.enable is true, but thunar package could not be resolved from nixpkgs.";
    }
    {
      assertion = !(thunarEnabled && thunarArchivePluginPkg == null);
      message = "features.fileManager.thunar.enable is true, but thunar-archive-plugin package could not be resolved from nixpkgs.";
    }
    {
      assertion = !(thunarEnabled && xfconfPkg == null);
      message = "features.fileManager.thunar.enable is true, but xfconf package could not be resolved from nixpkgs.";
    }
    {
      assertion = !(thunarEnabled && archiveManagerPkg == null);
      message = "features.fileManager.thunar.enable is true, but no archive manager package (file-roller/xarchiver) could be resolved from nixpkgs.";
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
    ++ lib.optionals (thunarEnabled && thunarPkg != null) [ thunarPkg ]
    ++ lib.optionals (thunarEnabled && thunarArchivePluginPkg != null) [ thunarArchivePluginPkg ]
    ++ lib.optionals (thunarEnabled && xfconfPkg != null) [ xfconfPkg ]
    ++ lib.optionals (thunarEnabled && archiveManagerPkg != null) [ archiveManagerPkg ]
    ++ lib.optionals (zenEnabled && zenPkg != null) [ zenPkg ]
    ++ lib.optionals chromeEnabled [ pkgs.google-chrome ]
    ++ lib.optionals (heliumEnabled && heliumPkg != null) [ heliumPkg ]
    ++ lib.optionals (get [ "desktop" "enable" ] true) (with pkgs; [
      # Desktop helpers commonly used by shell overlays.
      libnotify
    ]);

  programs.git =
    {
      enable = true;
    }
    // lib.optionalAttrs (gitUserName != null && gitUserEmail != null) {
      settings.user = {
        name = gitUserName;
        email = gitUserEmail;
      };
    };
  programs.bash.enable = true;
  programs.fish.enable = fishEnabled;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      setSessionVariables = false;
    };
    # Avoid repeated activation failures when a previous backup file already exists.
    configFile."user-dirs.dirs".force = true;
    mimeApps = {
      enable = true;
      defaultApplications = browserAssociations;
      associations.added = browserAssociations;
    };
  };

  home.sessionVariables = {
    TANOS_FLAKE_DIR = "${config.home.homeDirectory}/tanos";
    QT_STYLE_OVERRIDE = lib.mkForce "";
  };
  systemd.user.sessionVariables = {
    QT_STYLE_OVERRIDE = lib.mkForce "";
  };

  gtk = lib.mkIf (get [ "desktop" "enable" ] true) {
    enable = true;
  };
})
