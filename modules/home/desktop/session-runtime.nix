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
  shell = get [ "desktop" "shell" ] "none";
  startupCommand = get [ "desktop" "shellStartupCommand" ] null;
  defaultStartupApps = [
    "wl-paste --watch cliphist store"
    "qs -c ii"
  ];
  startupApps = get [ "desktop" "startup" "apps" ] defaultStartupApps;
  defaultShellStartupCommand =
    if shell == "dms" then "dms run --session"
    else if shell == "noctalia" then "noctalia-shell"
    else null;
  effectiveShellStartupCommand = if startupCommand != null then startupCommand else defaultShellStartupCommand;
  shellStartupEnable = shell != "none" && effectiveShellStartupCommand != null;
  appStartupEnable = startupApps != [ ];

  mkStartupService = index: command: {
    name = "tanos-startup-app-${toString index}";
    value = {
      Unit = {
        Description = "Tanos Startup App ${toString index}";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash -lc ${lib.escapeShellArg command}";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  startupAppServices = builtins.listToAttrs (lib.imap0 mkStartupService startupApps);

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
        {
          assertion =
            !(desktopEnabled && sessionEnabled && shellStartupEnable)
            || (lib.isString effectiveShellStartupCommand && effectiveShellStartupCommand != "");
          message = "desktop.shellStartupCommand must be a non-empty string when a desktop shell is enabled.";
        }
        {
          assertion = builtins.all (cmd: lib.isString cmd && cmd != "") startupApps;
          message = "desktop.startup.apps must be a list of non-empty command strings.";
        }
      ];
    }
    (lib.mkIf (desktopEnabled && sessionEnabled) {
      systemd.user.services = lib.mkMerge [
        (lib.mkIf polkitEnable {
          tanos-polkit-agent = {
            Unit = {
              Description = "Tanos Polkit Authentication Agent";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        })
        (lib.mkIf lockEnable {
          tanos-idle-lock = {
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
        (lib.mkIf shellStartupEnable {
          tanos-shell-startup = {
            Unit = {
              Description = "Tanos Desktop Shell Startup";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${pkgs.bash}/bin/bash -lc ${lib.escapeShellArg effectiveShellStartupCommand}";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        })
        (lib.mkIf appStartupEnable startupAppServices)
      ];
    })
  ];
}
