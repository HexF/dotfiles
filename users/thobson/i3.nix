{config, lib, pkgs, ...}:

let
  mod = "Mod1";
  theme = import ./theme.nix;
  rofiPackage = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
  terminal = "${pkgs.kitty}/bin/kitty";
  imagemagickCustom = pkgs.imagemagick;
in {

  imports = [
    ../modules/i3blocks.nix
  ];

  home.file.".background-image".source = ../../wallpaper.jpg;

  services.udiskie = {
    enable = true;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.bash}/bin/bash -c \"${imagemagickCustom}/bin/import -window root PNG:- | ${imagemagickCustom}/bin/convert PNG:- -resize 10% -blur 10 -resize 1000% RGB:- | ${pkgs.i3lock-color}/bin/i3lock-color --raw=$(${pkgs.xorg.xdpyinfo}/bin/xdpyinfo | ${pkgs.gnugrep}/bin/grep dimensions | ${pkgs.gnused}/bin/sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\\1/'):rgb --image /dev/stdin -k --insidever-color=00000000 --insidewrong-color=00000000 --inside-color=00000000 --ringver-color=${builtins.elemAt theme.color 4}80 --ringwrong-color=${builtins.elemAt theme.color 1}80 --ring-color=${builtins.elemAt theme.color 2}80 --line-uses-inside --keyhl-color=${builtins.elemAt theme.color 3}80 --bshl-color=${builtins.elemAt theme.color 5}80 --time-color=${theme.foreground}80 --date-color=${theme.foreground}80 --verif-color=${theme.foreground}80 --wrong-color=${theme.foreground}80 --pass-volume-keys --verif-text=Checking... --wrong-text=Wrong --noinput-text=Empty --lock-text=Locking... --lockfailed-text=Failed\"";
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

    extraConfig = {
      modi = "drun,run,emoji,ssh";
      combi-modi = "run,ssh";
      show-icons = false;
      display-drun = "Launch ";
      display-run = "Launch ";
      display-ssh = "Connect to ";
      display-combi = "";
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      generic = {
        background = theme.background;
        foreground = theme.foreground;
      };
      discord = {
        appname="discord";

        format = "<big>Discord</big>\\n%s\\n<small>%b</small>";
      };
      global = {
        geometry = "300x3-30+50";
        transparency = 10;
        font = "${theme.font.general.family} 9";
        markup = "full";
        word_wrap = true;
        shrink = true;
        follow = "none";

        
        icon_position = "left";
        max_icon_size = 100;

        format = "<big>%a</big>\\n%s\\n<small>%b</small>";

        dmenu = "${rofiPackage}/bin/rofi -dmenu";

        timeout = 10;

        frame_width = 1;
        frame_color = theme.background;
        #separator_color = theme.foreground;

      };

      urgency_normal = {
        frame_color = builtins.elemAt theme.color 9;
      };

      urgency_critical = {
        frame_color = builtins.elemAt theme.color 1;
      };
    };
  };


  services.picom = {
    enable = true;
    vSync = false;
    settings = {
      blur = true;
      blur-exclude = [
        "class_g = 'i3_bar'"
      ];
      xrender-sync-fence = true;
      blue-radius=32;
    };
    
    backend = "xrender";
  };

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    extraConfig = ''
    exec_always ${pkgs.feh}/bin/feh --bg-fill $HOME/.background-image
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

        "Print" = "--release exec ${pkgs.scrot}/bin/scrot --select -e '${pkgs.xclip}/bin/xclip -selection clipboard -t image/png -i $f'";
      };

      assigns = {
        "keepass" = [
          {
            class = "KeePassXC";
          }         
        ];
        "thunderbird" = [
          {
            class = "Thunderbird";
          }
        ];
        "communication" = [
          {
            class = "discord";
          }
          {
            class = "Spotify";
          }
        ];
      };

      bars = [
        {
          position = "bottom";
          command = "${pkgs.i3-gaps}/bin/i3bar --transparency";
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

      gaps = {
        inner = 25;
        outer = 10;
      };

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


  programs.i3blocks = {
    enable = true;
    blocksLeft = [
      ''
      [window_title]
      interval=-3
      command=${pkgs.xtitle}/bin/xtitle -s
      ''
      ''
      [song]
      command=[[ $(${pkgs.playerctl}/bin/playerctl status) = "Playing" ]] && ${pkgs.playerctl}/bin/playerctl metadata -f ' {{title}} - {{artist}}' || echo ""
      interval=1
      ''
      ''
      [volume]
      label= 
      command=${pkgs.pipewire}/bin/pw-dump | ${pkgs.jq}/bin/jq '.[] | select(.type == "PipeWire:Interface:Node" and .info.props["media.class"] == "Audio/Sink" and .info.state == "running") | "\(.info.params.Props[0].channelVolumes[0] *100 | round)"' -r
      interval=1
      signal=2
      ''
      ''
      [notifications]
      interval=1
      signal=3
      command=[[ $(${pkgs.dunst}/bin/dunstctl is-paused) == "true" ]] && echo '<span foreground="${builtins.elemAt theme.color 1}"></span>' || echo '<span foreground="${builtins.elemAt theme.color 2}"></span>'
      markup=pango
      ''
    ];

    blocksRight = [
      ''
      [date]
      label= 
      command=date "+%D %T"
      interval=1
      '' 
    ];

  };

}
