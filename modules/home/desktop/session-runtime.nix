{ lib, pkgs, vars ? { }, ... }:
let
  v = vars;
  get = path: default: lib.attrByPath path default v;
  desktopEnabled = get [ "desktop" "enable" ] true;
  sessionEnabled = get [ "desktop" "session" "enable" ] desktopEnabled;

  polkitEnable = get [ "desktop" "session" "polkit" "enable" ] true;
  lockEnable = get [ "desktop" "session" "lock" "enable" ] true;
  lockCommand = get [ "desktop" "session" "lock" "command" ] "loginctl lock-session";
  idleSeconds = get [ "desktop" "session" "lock" "idleSeconds" ] 600;
  lockBeforeSleep = get [ "desktop" "session" "lock" "beforeSleep" ] true;

  lockScript = pkgs.writeShellScript "tanos-lock-session" ''
    exec ${lockCommand}
  '';

  swayidleArgs =
    [
      "-w"
      "timeout"
      (toString idleSeconds)
      lockScript
    ]
    ++ lib.optionals lockBeforeSleep [
      "before-sleep"
      lockScript
    ];
in
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(sessionEnabled && lockEnable) || (lib.isString lockCommand && lockCommand != "");
          message = "desktop.session.lock.command must be a non-empty string when desktop.session.lock.enable is true.";
        }
        {
          assertion = !(sessionEnabled && lockEnable) || (builtins.isInt idleSeconds && idleSeconds > 0);
          message = "desktop.session.lock.idleSeconds must be a positive integer.";
        }
      ];
    }
    (lib.mkIf (desktopEnabled && sessionEnabled) {
      systemd.user.services.tanos-polkit-agent = lib.mkIf polkitEnable {
        Unit = {
          Description = "Tanos Polkit Authentication Agent";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.services.tanos-idle-lock = lib.mkIf lockEnable {
        Unit = {
          Description = "Tanos Idle Lock Service";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.escapeShellArgs ([ "${pkgs.swayidle}/bin/swayidle" ] ++ swayidleArgs);
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })
  ];
}
