{config, lib, pkgs, ...}:

let
  mod = "Mod1";
  colors = import ./colors.nix;
  rofiPackage = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
in {
  
  programs.rofi = {
    enable = true;
    package = rofiPackage;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    separator = "none";

    lines = 10;
    extraConfig = {
      modi = "drun,run,emoji,ssh";
      combi-modi = "run,ssh";
      show-icons = false;
      display-drun = "Launch ";
      display-run = "Launch ";
      display-ssh = "Connect to ";
      display-combi = "";
    };
    colors = {
      rows = rec {
        normal = rec {
          background = colors.background;
          backgroundAlt = background;
          foreground = colors.foreground;
          highlight = {
            background = colors.accent;
            foreground = foreground;
          };
        };
        active = normal;
        urgent = rec {
          background = (builtins.elemAt colors.color 1);
          backgroundAlt = background;
          foreground = colors.foreground;
          highlight = {
            background = colors.accent;
            foreground = foreground;
          };
        };
      };

      window = rec {
        background = colors.background;
        border = background;
        separator = "#00000000";
      };
    };

  };


  services.picom = {
    enable = true;
    vSync = false;
    blur = true;
    backend = "xrender";

    blurExclude = [
      "class_g = 'i3_bar'"
    ];

    extraOptions = ''
    xrender-sync-fence = true
    blur-radius=32
    '';
  };

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      menu = "${rofiPackage}/bin/rofi -show combi";
      modifier = mod;
      terminal = "${pkgs.alacritty}/bin/alacritty";

      keybindings = lib.mkOptionDefault {
        # bindsym --release Mod4+e exec --no-startup-id "emojify -c > /tmp/out"
        "${mod}+l" = "exec hass_light";
        "${mod}+Shift+e" = "exit";
        "${mod}+j" = "${rofiPackage}/bin/rofi -show emoji";

        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";

        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 1 +5% && pkill -SIGRTMIN+2 i3blocks";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 1 -5% && pkill -SIGRTMIN+2 i3blocks";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute 1 toggle && pkill -SIGRTMIN+2 i3blocks";

        "Print" = "--release exec scrot --select -e 'xclip -selection clipboard -t image/png -i $f'";
      };

      bars = [
        {
          position = "bottom";
          command = "${pkgs.i3-gaps}/bin/i3bar --transparency";
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
          colors = rec {
            background = "#00000000"; # Transparent

            activeWorkspace = {
              border = "#00000000"; # Transparent
              background = (builtins.elemAt colors.color 0) ;
              text = colors.foreground;
            };

            focusedWorkspace = {
              border = "#00000000"; # Transparent
              background = (builtins.elemAt colors.color 8) ;
              text = colors.foreground;
            };

            inactiveWorkspace = activeWorkspace;

            urgentWorkspace = {
              border = "#00000000"; # Transparent
              background = (builtins.elemAt colors.color 1);
              text = colors.foreground;
            };

            bindingMode = urgentWorkspace;
            

            

          };
        }
      ];

      gaps = {
        inner = 25;
        outer = 10;
      };

      window = {
        hideEdgeBorders = "vertical";
      };

      colors = rec {
        background = colors.background;

        focused = rec {
          background = builtins.elemAt colors.color 8;
          text = colors.foreground;
          border = builtins.elemAt colors.color 4;
          indicator = builtins.elemAt colors.color 12;
          childBorder = background;
        };

        focusedInactive = rec {
          background = colors.background;
          text = colors.foreground;
          border = builtins.elemAt colors.color 0;
          indicator = builtins.elemAt colors.color 8;
          childBorder = background;
        };

        urgent = rec {
          background = builtins.elemAt colors.color 1;
          text = colors.foreground;
          border = builtins.elemAt colors.color 1;
          indicator = builtins.elemAt colors.color 9;
          childBorder = background;
        };

        placeholder = focusedInactive;
        unfocused = focusedInactive;

      };
    };
  };

  xdg.configFile."i3blocks/config".text = ''
  [song]
  label=Song: 
  command=echo $(${pkgs.playerctl}/bin/playerctl metadata title) - $(${pkgs.playerctl}/bin/playerctl metadata artist); echo $(${pkgs.playerctl}/bin/playerctl metadata title)

  interval=1

  [volume]
  label=Volume: 
  command=amixer get Master | grep -oP 'Right: .* \[\K\d+'
  interval=once
  signal=2

  [date]
  command=date "+%D %T"
  interval=1

  '';

}
