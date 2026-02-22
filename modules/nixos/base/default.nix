{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = get [ "host" "timeZone" ] "America/Chicago";
  i18n.defaultLocale = get [ "host" "locale" ] "en_US.UTF-8";

  boot.loader.systemd-boot.enable = lib.mkDefault (get [ "boot" "systemdBoot" "enable" ] true);
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  networking.networkmanager.enable = lib.mkDefault false;

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services.dbus.enable = true;
  services.openssh.enable = lib.mkDefault true;

  users.users.${primaryUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    shell = pkgs.bashInteractive;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    dejavu_fonts
    nerd-fonts.fira-code
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    jq
    ripgrep
    fd
    unzip
    zip
    vim
    neovim
    htop
    fastfetch
    foot
    fuzzel
    waybar
    wl-clipboard
    networkmanagerapplet
    pavucontrol
    brightnessctl
    playerctl
    grim
    slurp
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
