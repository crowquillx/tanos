{
  lib,
  pkgs,
  config,
  ...
}:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
  fishEnabled = get [ "features" "shell" "fish" "enable" ] true;
in
{
  nix.settings = {
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extra-substituters = [
      "https://install.determinate.systems"
      "https://noctalia.cachix.org"
      "https://nix-community.cachix.org"
    ];
    auto-optimise-store = true;
  };

  nix.gc.automatic = false;

  time.timeZone = get [ "host" "timeZone" ] "America/Chicago";
  i18n.defaultLocale = get [ "host" "locale" ] "en_US.UTF-8";

  boot.loader.systemd-boot.enable = lib.mkDefault (get [ "boot" "systemdBoot" "enable" ] true);
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 7;
  boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  boot.kernelPackages =
    let
      kernel = get [ "boot" "kernel" ] "default";
    in
    if kernel == "zen" then
      pkgs.linuxPackages_zen
    else if kernel == "latest" then
      pkgs.linuxPackages_latest
    else
      pkgs.linuxPackages;

  networking.networkmanager.enable = lib.mkDefault false;

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services.dbus.enable = true;
  services.openssh.enable = lib.mkDefault true;

  users.users.${primaryUser} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
    shell = if fishEnabled then pkgs.fish else pkgs.bashInteractive;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    dejavu_fonts
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig = {
    defaultFonts = {
      serif = [
        "DejaVu Serif"
        "Noto Serif CJK SC"
        "Noto Serif CJK JP"
        "Noto Serif CJK KR"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans CJK SC"
        "Noto Sans CJK JP"
        "Noto Sans CJK KR"
        "Noto Color Emoji"
      ];
      monospace = [
        "FiraCode Nerd Font"
        "Hack Nerd Font"
        "Noto Sans Mono CJK SC"
        "Noto Sans Mono CJK JP"
        "Noto Sans Mono CJK KR"
        "Noto Color Emoji"
        "Symbols Nerd Font"
      ];
      emoji = [
        "Noto Color Emoji"
        "Symbols Nerd Font"
      ];
    };
  };

  # Keep system-wide packages minimal; user-facing tooling lives in Home Manager.
  environment.systemPackages = [ pkgs.git ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
