{ lib, pkgs, config, ... }:
let
  v = config.tanos.variables;
  get = path: default: lib.attrByPath path default v;
  primaryUser = get [ "users" "primary" ] "tan";
  fishEnabled = get [ "features" "shell" "fish" "enable" ] true;
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
    shell = if fishEnabled then pkgs.fish else pkgs.bashInteractive;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    dejavu_fonts
    nerd-fonts.fira-code
  ];

  # Keep system-wide packages minimal; user-facing tooling lives in Home Manager.
  environment.systemPackages = with pkgs; [
    git
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
