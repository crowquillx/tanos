{ lib, pkgs, vars ? { }, inputs, config, options, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  hasIllogicalEnableOption = lib.hasAttrByPath [ "programs" "illogical-impulse" "enable" ] options;
  dsearchEnabled = get [ "features" "danksearch" "enable" ] true;
  codingToolsEnabled = get [ "features" "codingTools" "enable" ] true;
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
  dsearchPkg = lib.attrByPath [ "danksearch" "packages" system "default" ] null inputs;
  codexPkg = lib.attrByPath [ "codex" ] null pkgs;
  vscodePkg = lib.attrByPath [ "vscode" ] null pkgs;
  geminiCliPkg =
    let
      sourcePkg = lib.attrByPath [ "gemini-cli" ] null pkgs;
      binPkg = lib.attrByPath [ "gemini-cli-bin" ] null pkgs;
    in
    if sourcePkg != null then sourcePkg else binPkg;
  antigravityPkg =
    let
      fhsPkg = lib.attrByPath [ "antigravity-fhs" ] null pkgs;
      nativePkg = lib.attrByPath [ "antigravity" ] null pkgs;
    in
    if fhsPkg != null then fhsPkg else nativePkg;
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
      assertion = !(dsearchEnabled && dsearchPkg == null);
      message = "features.danksearch.enable is true, but danksearch package could not be resolved from flake input.";
    }
    {
      assertion = !(codingToolsEnabled && codexPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'codex' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && vscodePkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'vscode' could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && geminiCliPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'gemini-cli' (or gemini-cli-bin fallback) could not be resolved.";
    }
    {
      assertion = !(codingToolsEnabled && antigravityPkg == null);
      message = "features.codingTools.enable is true, but nixpkgs package 'antigravity-fhs' (preferred) or 'antigravity' could not be resolved.";
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
    ++ lib.optionals (dsearchEnabled && dsearchPkg != null) [ dsearchPkg ]
    ++ lib.optionals (codingToolsEnabled && codexPkg != null) [ codexPkg ]
    ++ lib.optionals (codingToolsEnabled && vscodePkg != null) [ vscodePkg ]
    ++ lib.optionals (codingToolsEnabled && geminiCliPkg != null) [ geminiCliPkg ]
    ++ lib.optionals (codingToolsEnabled && antigravityPkg != null) [ antigravityPkg ]
    ++ lib.optionals (thunarEnabled && thunarPkg != null) [ thunarPkg ]
    ++ lib.optionals (thunarEnabled && thunarArchivePluginPkg != null) [ thunarArchivePluginPkg ]
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
  programs.starship = lib.optionalAttrs hasIllogicalEnableOption {
    enable = lib.mkForce false;
  };

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
