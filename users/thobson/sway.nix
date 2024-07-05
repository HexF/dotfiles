{config, lib, pkgs, ...}:

let
  mod = "Mod1";
  theme = import ./theme.nix;
  rofiPackage = pkgs.rofi-wayland.override { plugins = [ pkgs.rofi-emoji ]; };
  terminal = "${pkgs.kitty}/bin/kitty";
  autorotate = pkgs.writeScriptBin "autorotate-script.sh" ''
  
SCREEN="eDP-1"

function rotate_ms {
    case $1 in
        "normal") rotate 0 ;;
        "right-up") rotate 90 ;;
        "bottom-up") rotate 180 ;;
        "left-up") rotate 270 ;;
    esac
}

function rotate {

    TARGET_ORIENTATION=$1

    echo "Rotating to" $TARGET_ORIENTATION

    swaymsg output $SCREEN transform $TARGET_ORIENTATION

    swaymsg input "type:touchpad" map_to_output "$SCREEN"
    swaymsg input "type:touch" map_to_output "$SCREEN"
    swaymsg input "type:tablet_tool" map_to_output "$SCREEN"

}

while IFS='$\n' read -r line; do
    rotation="$(echo $line | sed -En "s/^.*orientation changed: (.*)/\1/p")"
    [[ !  -z  $rotation  ]] && rotate_ms $rotation
done < <(stdbuf -oL monitor-sensor)
  '';
in {
  imports = [
    ./statusline.nix
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # chromium ozone wayland support - Discord, vscode & co.
  };

  programs.rofi = {
    enable = true;
    package = rofiPackage;
    terminal = terminal;
    
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };


      window = rec {
        enabled = true;
        background-color = mkLiteral theme.background;
        border-color = background-color;
        transparency = "real";
        anchor = "center";
        location = "center";
        width = mkLiteral "60%"; #60% of monito
      };

      scrollbar = {
        enabled = false;
      };

      element = {
        border = 0;
        padding = mkLiteral "1px";
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      element-text = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      
      "element normal.normal" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element selected.normal" = {
        background-color = mkLiteral theme.accent;
        text-color = mkLiteral theme.foreground;
      };

      "element alternate.normal" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element normal.active" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element selected.active" = {
        background-color = mkLiteral theme.accent;
        text-color = mkLiteral theme.foreground;
      };

      "element alternate.active" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element normal.urgent" = {
        background-color = mkLiteral (builtins.elemAt theme.color 1);
        text-color = mkLiteral theme.foreground;
      };

      "element selected.urgent" = {
        background-color = mkLiteral theme.accent;
        text-color = mkLiteral theme.foreground;
      };

      "element alternate.urgent" = {
        background-color = mkLiteral (builtins.elemAt theme.color 1);
        text-color = mkLiteral theme.foreground;
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
        image = "$HOME/.background-image";
        inside-ver-color="00000000";
        inside-wrong-color="00000000";
        inside-color="00000000";
        ring-ver-color="${builtins.elemAt theme.color 4}80";
        ring-wrong-color="${builtins.elemAt theme.color 1}80";
        ring-color="${builtins.elemAt theme.color 2}80";
        line-uses-inside=true;
        key-hl-color="${builtins.elemAt theme.color 3}80";
        bs-hl-color="${builtins.elemAt theme.color 5}80";
        # time-color="${theme.foreground}80";
        # date-color="${theme.foreground}80";
        # text-verif-color="${theme.foreground}80";
        text-wrong-color="${theme.foreground}80";
    };
  };

  services.swayidle = {
    enable = true;
    events = [
#      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock"; }
    ];
  };

  services.mako = {
    enable = true;
    backgroundColor = theme.background;
    borderColor = theme.background;
    textColor = theme.foreground;

    defaultTimeout = 15000;
    font = "${theme.font.general.family} 9";
    format = "<big>%a</big>\\n%s\\n<small>%b</small>";
    
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;

    extraConfig = ''
    exec_always ${pkgs.swaybg}/bin/swaybg -m fill -i $HOME/.background-image
    exec_always ${pkgs.iio-sensor-proxy}/bin/monitor-sensor | ${autorotate}/bin/autorotate-script.sh
    '';

    config = {
      fonts = {
        names = [theme.font.general.family];
        size = 11.0;
      };
      menu = "${rofiPackage}/bin/rofi -show combi";
      modifier = mod;
      terminal = terminal;

      keybindings = lib.mkOptionDefault {
        "${mod}+Shift+f" = "fullscreen toggle global";
        "${mod}+j" = "exec ${rofiPackage}/bin/rofi -show emoji";
        "${mod}+n" = "exec ${pkgs.dunst}/bin/dunstctl set-paused toggle && pkill -SIGRTMIN+3 i3blocks";

        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5% && pkill -SIGRTMIN+2 i3blocks";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5% && pkill -SIGRTMIN+2 i3blocks";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle && pkill -SIGRTMIN+2 i3blocks";

        "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
        "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";


        "Print" = "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png";
      };

      bars = [
        {
          position = "bottom";
          command = "${pkgs.sway}/bin/swaybar";
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
          trayOutput = "primary";
          colors = rec {
            background = "#00000000"; # Transparent

            activeWorkspace = {
              border = "#00000000"; # Transparent
              background = (builtins.elemAt theme.color 0) ;
              text = theme.foreground;
            };

            focusedWorkspace = {
              border = "#00000000"; # Transparent
              background = (builtins.elemAt theme.color 8) ;
              text = theme.foreground;
            };

            inactiveWorkspace = activeWorkspace;

            urgentWorkspace = {
              border = "#00000000"; # Transparent
              background = (builtins.elemAt theme.color 1);
              text = theme.foreground;
            };

            bindingMode = urgentWorkspace;

          };

          fonts = {
            names = [theme.font.general.family];
            size = 10.0;
          };
        }
      ];

      /*gaps = {
        inner = 25;
        outer = 10;
      };*/

      window = {
        hideEdgeBorders = "vertical";
      };

      colors = rec {
        background = theme.background;

        focused = rec {
          background = builtins.elemAt theme.color 8;
          text = theme.foreground;
          border = builtins.elemAt theme.color 4;
          indicator = builtins.elemAt theme.color 12;
          childBorder = background;
        };

        focusedInactive = rec {
          background = theme.background;
          text = theme.foreground;
          border = builtins.elemAt theme.color 0;
          indicator = builtins.elemAt theme.color 8;
          childBorder = background;
        };

        urgent = rec {
          background = builtins.elemAt theme.color 1;
          text = theme.foreground;
          border = builtins.elemAt theme.color 1;
          indicator = builtins.elemAt theme.color 9;
          childBorder = background;
        };

        placeholder = focusedInactive;
        unfocused = focusedInactive;

      };
    };
  };

}
