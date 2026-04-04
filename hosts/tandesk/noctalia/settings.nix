{
  "appLauncher" = {
    "autoPasteClipboard" = false;
    "clipboardWatchImageCommand" = "wl-paste --type image --watch cliphist store";
    "clipboardWatchTextCommand" = "wl-paste --type text --watch cliphist store";
    "clipboardWrapText" = true;
    "customLaunchPrefix" = "";
    "customLaunchPrefixEnabled" = false;
    "density" = "comfortable";
    "enableClipPreview" = true;
    "enableClipboardChips" = true;
    "enableClipboardHistory" = true;
    "enableClipboardSmartIcons" = true;
    "enableSessionSearch" = true;
    "enableSettingsSearch" = true;
    "enableWindowsSearch" = true;
    "iconMode" = "tabler";
    "ignoreMouseInput" = true;
    "overviewLayer" = false;
    "pinnedApps" = [ ];
    "position" = "top_center";
    "screenshotAnnotationTool" = "";
    "showCategories" = true;
    "showIconBackground" = true;
    "sortByMostUsed" = true;
    "terminalCommand" = "ghostty -e";
    "viewMode" = "grid";
  };
  "audio" = {
    "mprisBlacklist" = [
      "zen"
      "firefox"
      "brave"
    ];
    "preferredPlayer" = "spotify";
    "spectrumFrameRate" = 60;
    "spectrumMirrored" = true;
    "visualizerType" = "linear";
    "volumeFeedback" = false;
    "volumeFeedbackSoundFile" = "";
    "volumeOverdrive" = false;
    "volumeStep" = 5;
  };
  "bar" = {
    "autoHideDelay" = 500;
    "autoShowDelay" = 150;
    "backgroundOpacity" = 0.5;
    "barType" = "floating";
    "capsuleColorKey" = "none";
    "capsuleOpacity" = 1;
    "contentPadding" = 2;
    "density" = "default";
    "displayMode" = "always_visible";
    "enableExclusionZoneInset" = true;
    "fontScale" = 1;
    "frameRadius" = 12;
    "frameThickness" = 8;
    "hideOnOverview" = true;
    "marginHorizontal" = 5;
    "marginVertical" = 5;
    "middleClickAction" = "none";
    "middleClickCommand" = "";
    "middleClickFollowMouse" = false;
    "monitors" = [
      "DP-3"
      "DP-2"
    ];
    "mouseWheelAction" = "none";
    "mouseWheelWrap" = true;
    "outerCorners" = true;
    "position" = "top";
    "reverseScroll" = false;
    "rightClickAction" = "controlCenter";
    "rightClickCommand" = "";
    "rightClickFollowMouse" = true;
    "screenOverrides" = [ ];
    "showCapsule" = false;
    "showOnWorkspaceSwitch" = true;
    "showOutline" = false;
    "useSeparateOpacity" = false;
    "widgetSpacing" = 6;
    "widgets" = {
      "center" = [
        {
          "characterCount" = 2;
          "colorizeIcons" = false;
          "emptyColor" = "secondary";
          "enableScrollWheel" = true;
          "focusedColor" = "primary";
          "followFocusedScreen" = false;
          "fontWeight" = "bold";
          "groupedBorderOpacity" = 1;
          "hideUnoccupied" = false;
          "iconScale" = 0.8;
          "id" = "Workspace";
          "labelMode" = "index";
          "occupiedColor" = "secondary";
          "pillSize" = 0.6;
          "showApplications" = false;
          "showApplicationsHover" = false;
          "showBadge" = true;
          "showLabelsOnlyWhenOccupied" = true;
          "unfocusedIconsOpacity" = 1;
        }
      ];
      "left" = [
        {
          "compactMode" = true;
          "diskPath" = "/";
          "iconColor" = "none";
          "id" = "SystemMonitor";
          "showCpuCores" = false;
          "showCpuFreq" = false;
          "showCpuTemp" = true;
          "showCpuUsage" = true;
          "showDiskAvailable" = false;
          "showDiskUsage" = false;
          "showDiskUsageAsPercent" = false;
          "showGpuTemp" = false;
          "showLoadAverage" = false;
          "showMemoryAsPercent" = false;
          "showMemoryUsage" = true;
          "showNetworkStats" = false;
          "showSwapUsage" = false;
          "textColor" = "none";
          "useMonospaceFont" = true;
          "usePadding" = false;
        }
        {
          "colorizeIcons" = true;
          "hideMode" = "hidden";
          "id" = "ActiveWindow";
          "maxWidth" = 145;
          "scrollingMode" = "hover";
          "showIcon" = true;
          "showText" = true;
          "textColor" = "none";
          "useFixedWidth" = false;
        }
        {
          "compactMode" = false;
          "hideMode" = "hidden";
          "hideWhenIdle" = false;
          "id" = "MediaMini";
          "maxWidth" = 145;
          "panelShowAlbumArt" = true;
          "scrollingMode" = "hover";
          "showAlbumArt" = true;
          "showArtistFirst" = true;
          "showProgressRing" = true;
          "showVisualizer" = true;
          "textColor" = "none";
          "useFixedWidth" = false;
          "visualizerType" = "mirrored";
        }
        {
          "defaultSettings" = {
            "ai" = {
              "apiKeys" = { };
              "maxHistoryLength" = 100;
              "model" = "gemini-2.5-flash";
              "openaiBaseUrl" = "https://api.openai.com/v1/chat/completions";
              "openaiLocal" = false;
              "provider" = "google";
              "systemPrompt" = "You are a helpful assistant integrated into a Linux desktop shell. Be concise and helpful.";
              "temperature" = 0.7;
            };
            "maxHistoryLength" = 100;
            "panelDetached" = true;
            "panelHeightRatio" = 0.85;
            "panelPosition" = "right";
            "panelWidth" = 520;
            "scale" = 1;
            "translator" = {
              "backend" = "google";
              "deeplApiKey" = "";
              "realTimeTranslation" = true;
              "sourceLanguage" = "auto";
              "targetLanguage" = "en";
            };
          };
          "id" = "plugin:assistant-panel";
        }
        {
          "defaultSettings" = {
            "hideBackground" = false;
            "minimumThreshold" = 10;
          };
          "id" = "plugin:catwalk";
        }
      ];
      "right" = [
        {
          "defaultSettings" = {
            "currentIconName" = "world-download";
            "hideOnZero" = false;
            "updateIntervalMinutes" = 30;
            "updateTerminalCommand" = "foot -e";
          };
          "id" = "plugin:update-count";
        }
        {
          "blacklist" = [ ];
          "chevronColor" = "none";
          "colorizeIcons" = true;
          "drawerEnabled" = true;
          "hidePassive" = false;
          "id" = "Tray";
          "pinned" = [ ];
        }
        {
          "hideWhenZero" = true;
          "hideWhenZeroUnread" = false;
          "iconColor" = "none";
          "id" = "NotificationHistory";
          "showUnreadBadge" = true;
          "unreadBadgeColor" = "primary";
        }
        {
          "displayMode" = "onhover";
          "iconColor" = "none";
          "id" = "Volume";
          "middleClickCommand" = "pwvucontrol || pavucontrol";
          "textColor" = "none";
        }
        {
          "clockColor" = "none";
          "customFont" = "";
          "formatHorizontal" = "h:mm AP";
          "formatVertical" = "HH mm - dd MM";
          "id" = "Clock";
          "tooltipFormat" = "HH:mm ddd, MMM dd";
          "useCustomFont" = false;
        }
        {
          "colorizeDistroLogo" = false;
          "colorizeSystemIcon" = "primary";
          "customIconPath" = "";
          "enableColorization" = true;
          "icon" = "alien-filled";
          "id" = "ControlCenter";
          "useDistroLogo" = false;
        }
      ];
    };
  };
  "brightness" = {
    "backlightDeviceMappings" = [ ];
    "brightnessStep" = 5;
    "enableDdcSupport" = false;
    "enforceMinimum" = true;
  };
  "calendar" = {
    "cards" = [
      {
        "enabled" = true;
        "id" = "calendar-header-card";
      }
      {
        "enabled" = true;
        "id" = "calendar-month-card";
      }
      {
        "enabled" = true;
        "id" = "weather-card";
      }
    ];
  };
  "colorSchemes" = {
    "darkMode" = true;
    "generationMethod" = "tonal-spot";
    "manualSunrise" = "06:30";
    "manualSunset" = "18:30";
    "monitorForColors" = "";
    "predefinedScheme" = "Rose Pine";
    "schedulingMode" = "off";
    "syncGsettings" = true;
    "useWallpaperColors" = false;
  };
  "controlCenter" = {
    "cards" = [
      {
        "enabled" = true;
        "id" = "profile-card";
      }
      {
        "enabled" = true;
        "id" = "shortcuts-card";
      }
      {
        "enabled" = true;
        "id" = "audio-card";
      }
      {
        "enabled" = true;
        "id" = "weather-card";
      }
      {
        "enabled" = true;
        "id" = "media-sysmon-card";
      }
      {
        "enabled" = false;
        "id" = "brightness-card";
      }
    ];
    "diskPath" = "/";
    "position" = "top_center";
    "shortcuts" = {
      "left" = [
        {
          "id" = "WiFi";
        }
        {
          "id" = "Bluetooth";
        }
        {
          "id" = "WallpaperSelector";
        }
      ];
      "right" = [
        {
          "id" = "Notifications";
        }
        {
          "id" = "PowerProfile";
        }
        {
          "id" = "KeepAwake";
        }
        {
          "id" = "NightLight";
        }
      ];
    };
  };
  "desktopWidgets" = {
    "enabled" = false;
    "gridSnap" = false;
    "gridSnapScale" = false;
    "monitorWidgets" = [ ];
    "overviewEnabled" = true;
  };
  "dock" = {
    "animationSpeed" = 1;
    "backgroundOpacity" = 1;
    "colorizeIcons" = true;
    "deadOpacity" = 0.6;
    "displayMode" = "auto_hide";
    "dockType" = "floating";
    "enabled" = false;
    "floatingRatio" = 1;
    "groupApps" = false;
    "groupClickAction" = "cycle";
    "groupContextMenuMode" = "extended";
    "groupIndicatorStyle" = "dots";
    "inactiveIndicators" = false;
    "indicatorColor" = "primary";
    "indicatorOpacity" = 0.6;
    "indicatorThickness" = 3;
    "launcherIcon" = "";
    "launcherIconColor" = "none";
    "launcherPosition" = "end";
    "launcherUseDistroLogo" = false;
    "monitors" = [ ];
    "onlySameOutput" = true;
    "pinnedApps" = [ ];
    "pinnedStatic" = false;
    "position" = "bottom";
    "showDockIndicator" = false;
    "showLauncherIcon" = false;
    "sitOnFrame" = false;
    "size" = 1;
  };
  "general" = {
    "allowPanelsOnScreenWithoutBar" = true;
    "allowPasswordWithFprintd" = false;
    "animationDisabled" = false;
    "animationSpeed" = 1.1500000000000001;
    "autoStartAuth" = false;
    "avatarImage" = "/home/tan/.face";
    "boxRadiusRatio" = 1;
    "clockFormat" = "hh\\nmmh:mm AP ";
    "clockStyle" = "custom";
    "compactLockScreen" = false;
    "dimmerOpacity" = 0.2;
    "enableBlurBehind" = true;
    "enableLockScreenCountdown" = true;
    "enableLockScreenMediaControls" = true;
    "enableShadows" = true;
    "forceBlackScreenCorners" = true;
    "iRadiusRatio" = 1;
    "keybinds" = {
      "keyDown" = [
        "Down"
      ];
      "keyEnter" = [
        "Return"
        "Enter"
      ];
      "keyEscape" = [
        "Esc"
      ];
      "keyLeft" = [
        "Left"
      ];
      "keyRemove" = [
        "Del"
      ];
      "keyRight" = [
        "Right"
      ];
      "keyUp" = [
        "Up"
      ];
    };
    "language" = "";
    "lockOnSuspend" = true;
    "lockScreenAnimations" = true;
    "lockScreenBlur" = 0.6;
    "lockScreenCountdownDuration" = 10000;
    "lockScreenMonitors" = [ ];
    "lockScreenTint" = 0.25;
    "passwordChars" = true;
    "radiusRatio" = 1;
    "reverseScroll" = false;
    "scaleRatio" = 1;
    "screenRadiusRatio" = 1;
    "shadowDirection" = "bottom_right";
    "shadowOffsetX" = 2;
    "shadowOffsetY" = 3;
    "showChangelogOnStartup" = true;
    "showHibernateOnLockScreen" = false;
    "showScreenCorners" = true;
    "showSessionButtonsOnLockScreen" = true;
    "smoothScrollEnabled" = true;
    "telemetryEnabled" = true;
  };
  "hooks" = {
    "colorGeneration" = "";
    "darkModeChange" = "";
    "enabled" = false;
    "performanceModeDisabled" = "";
    "performanceModeEnabled" = "";
    "screenLock" = "";
    "screenUnlock" = "";
    "session" = "";
    "startup" = "";
    "wallpaperChange" = "";
  };
  "idle" = {
    "customCommands" = "[]";
    "enabled" = true;
    "fadeDuration" = 5;
    "lockCommand" = "";
    "lockTimeout" = 660;
    "resumeLockCommand" = "";
    "resumeScreenOffCommand" = "";
    "resumeSuspendCommand" = "";
    "screenOffCommand" = "";
    "screenOffTimeout" = 600;
    "suspendCommand" = "";
    "suspendTimeout" = 1800;
  };
  "location" = {
    "analogClockInCalendar" = false;
    "autoLocate" = true;
    "firstDayOfWeek" = -1;
    "hideWeatherCityName" = false;
    "hideWeatherTimezone" = false;
    "name" = "Meridian";
    "showCalendarEvents" = true;
    "showCalendarWeather" = true;
    "showWeekNumberInCalendar" = false;
    "use12hourFormat" = true;
    "useFahrenheit" = true;
    "weatherEnabled" = true;
    "weatherShowEffects" = true;
  };
  "network" = {
    "bluetoothAutoConnect" = true;
    "bluetoothDetailsViewMode" = "grid";
    "bluetoothHideUnnamedDevices" = false;
    "bluetoothRssiPollIntervalMs" = 10000;
    "bluetoothRssiPollingEnabled" = false;
    "disableDiscoverability" = false;
    "networkPanelView" = "wifi";
    "wifiDetailsViewMode" = "grid";
  };
  "nightLight" = {
    "autoSchedule" = true;
    "dayTemp" = "6500";
    "enabled" = false;
    "forced" = false;
    "manualSunrise" = "06:30";
    "manualSunset" = "18:30";
    "nightTemp" = "4000";
  };
  "noctaliaPerformance" = {
    "disableDesktopWidgets" = true;
    "disableWallpaper" = true;
  };
  "notifications" = {
    "backgroundOpacity" = 0.8;
    "clearDismissed" = true;
    "criticalUrgencyDuration" = 9;
    "density" = "default";
    "enableBatteryToast" = true;
    "enableKeyboardLayoutToast" = true;
    "enableMarkdown" = false;
    "enableMediaToast" = false;
    "enabled" = true;
    "location" = "bottom";
    "lowUrgencyDuration" = 2;
    "monitors" = [
      "DP-1"
    ];
    "normalUrgencyDuration" = 6;
    "overlayLayer" = true;
    "respectExpireTimeout" = false;
    "saveToHistory" = {
      "critical" = true;
      "low" = true;
      "normal" = true;
    };
    "sounds" = {
      "criticalSoundFile" = "";
      "enabled" = false;
      "excludedApps" = "discord,firefox,chrome,chromium,edge";
      "lowSoundFile" = "";
      "normalSoundFile" = "";
      "separateSounds" = false;
      "volume" = 0.5;
    };
  };
  "osd" = {
    "autoHideMs" = 2000;
    "backgroundOpacity" = 0.9;
    "enabled" = true;
    "enabledTypes" = [
      0
      1
      2
      4
    ];
    "location" = "top";
    "monitors" = [ ];
    "overlayLayer" = true;
  };
  "plugins" = {
    "autoUpdate" = true;
    "notifyUpdates" = true;
  };
  "sessionMenu" = {
    "countdownDuration" = 6000;
    "enableCountdown" = true;
    "largeButtonsLayout" = "grid";
    "largeButtonsStyle" = true;
    "position" = "center";
    "powerOptions" = [
      {
        "action" = "lock";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "1";
      }
      {
        "action" = "suspend";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "2";
      }
      {
        "action" = "hibernate";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "3";
      }
      {
        "action" = "reboot";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "4";
      }
      {
        "action" = "logout";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "5";
      }
      {
        "action" = "shutdown";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "6";
      }
      {
        "action" = "userspaceReboot";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = false;
        "keybind" = "";
      }
      {
        "action" = "rebootToUefi";
        "command" = "";
        "countdownEnabled" = true;
        "enabled" = true;
        "keybind" = "7";
      }
    ];
    "showHeader" = true;
    "showKeybinds" = true;
  };
  "settingsVersion" = 59;
  "systemMonitor" = {
    "batteryCriticalThreshold" = 5;
    "batteryWarningThreshold" = 20;
    "cpuCriticalThreshold" = 90;
    "cpuWarningThreshold" = 80;
    "criticalColor" = "";
    "diskAvailCriticalThreshold" = 10;
    "diskAvailWarningThreshold" = 20;
    "diskCriticalThreshold" = 90;
    "diskWarningThreshold" = 80;
    "enableDgpuMonitoring" = true;
    "externalMonitor" = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
    "gpuCriticalThreshold" = 90;
    "gpuWarningThreshold" = 80;
    "memCriticalThreshold" = 90;
    "memWarningThreshold" = 80;
    "swapCriticalThreshold" = 90;
    "swapWarningThreshold" = 80;
    "tempCriticalThreshold" = 90;
    "tempWarningThreshold" = 80;
    "useCustomColors" = false;
    "warningColor" = "";
  };
  "templates" = {
    "activeTemplates" = [
      {
        "enabled" = true;
        "id" = "qt";
      }
      {
        "enabled" = true;
        "id" = "alacritty";
      }
      {
        "enabled" = true;
        "id" = "pywalfox";
      }
      {
        "enabled" = true;
        "id" = "code";
      }
      {
        "enabled" = true;
        "id" = "spicetify";
      }
      {
        "enabled" = true;
        "id" = "zed";
      }
      {
        "enabled" = true;
        "id" = "vicinae";
      }
      {
        "enabled" = true;
        "id" = "kitty";
      }
      {
        "enabled" = true;
        "id" = "telegram";
      }
      {
        "enabled" = true;
        "id" = "zenBrowser";
      }
      {
        "enabled" = true;
        "id" = "btop";
      }
      {
        "enabled" = true;
        "id" = "niri";
      }
      {
        "enabled" = true;
        "id" = "kcolorscheme";
      }
      {
        "enabled" = true;
        "id" = "gtk";
      }
      {
        "enabled" = true;
        "id" = "fuzzel";
      }
      {
        "enabled" = true;
        "id" = "ghostty";
      }
    ];
    "enableUserTheming" = false;
  };
  "ui" = {
    "boxBorderEnabled" = false;
    "fontDefault" = "Inter";
    "fontDefaultScale" = 1;
    "fontFixed" = "Hack";
    "fontFixedScale" = 1;
    "panelBackgroundOpacity" = 0.64;
    "panelsAttachedToBar" = true;
    "scrollbarAlwaysVisible" = true;
    "settingsPanelMode" = "attached";
    "settingsPanelSideBarCardStyle" = false;
    "tooltipsEnabled" = true;
    "translucentWidgets" = true;
  };
  "wallpaper" = {
    "automationEnabled" = true;
    "directory" = "/home/tan/Pictures/Wallpapers";
    "enableMultiMonitorDirectories" = true;
    "enabled" = true;
    "favorites" = [ ];
    "fillColor" = "#000000";
    "fillMode" = "crop";
    "hideWallpaperFilenames" = false;
    "linkLightAndDarkWallpapers" = true;
    "monitorDirectories" = [ ];
    "overviewBlur" = 0.4;
    "overviewEnabled" = true;
    "overviewTint" = 0.6;
    "panelPosition" = "follow_bar";
    "randomIntervalSec" = 900;
    "setWallpaperOnAllMonitors" = true;
    "showHiddenFiles" = false;
    "skipStartupTransition" = false;
    "solidColor" = "#1a1a2e";
    "sortOrder" = "name";
    "transitionDuration" = 1500;
    "transitionEdgeSmoothness" = 0.05;
    "transitionType" = [
      "fade"
      "disc"
      "stripes"
      "wipe"
      "pixelate"
      "honeycomb"
    ];
    "useOriginalImages" = false;
    "useSolidColor" = false;
    "useWallhaven" = false;
    "viewMode" = "single";
    "wallhavenApiKey" = "";
    "wallhavenCategories" = "111";
    "wallhavenOrder" = "desc";
    "wallhavenPurity" = "100";
    "wallhavenQuery" = "";
    "wallhavenRatios" = "";
    "wallhavenResolutionHeight" = "";
    "wallhavenResolutionMode" = "atleast";
    "wallhavenResolutionWidth" = "";
    "wallhavenSorting" = "relevance";
    "wallpaperChangeMode" = "random";
  };
}
