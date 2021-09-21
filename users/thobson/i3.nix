{config, lib, pkgs, ...}:

let
  mod = "Mod1";
  colors = import ./colors.nix;
  rofiPackage = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
  useSecret = import ../../useSecret.nix;
in {

  imports = [
    ../../modules/i3blocks.nix
  ];

  services.udiskie = {
    enable = true;
  };
  
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

  services.dunst = {
    enable = true;
    settings = {
      global = {
        geometry = "300x5-30+50";
        transparency = 10;
        frame_color = "#eceff1";
        font = "Droid Sans 9";
      };
      urgency_normal = {
        background = "#37474f";
        foreground = "#eceff1";
        timeout = 10;
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
        "${mod}+Shift+f" = "fullscreen toggle global";
        "${mod}+Shift+e" = "exit";
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


  programs.i3blocks = {
    enable = true;
    blocksLeft = [
      ''
      [song]
      label=Song: 
      command=echo $(${pkgs.playerctl}/bin/playerctl metadata title) - $(${pkgs.playerctl}/bin/playerctl metadata artist); echo $(${pkgs.playerctl}/bin/playerctl metadata title)
      interval=1
      ''
      ''
      [volume]
      label=Volume: 
      command=amixer get Master | grep -oP 'Right: .* \[\K\d+'
      interval=once
      signal=2
      ''
      ''
      [notifications]
      label=Notifications: 
      interval=once
      signal=3
      command=[[ $(${pkgs.dunst}/bin/dunstctl is-paused) == "true" ]] && echo "Disabled" || echo "Enabled"
      ''
    ];

    blocksCenter = (useSecret {
      callback = secrets: [];
      default = [
        ''
        [warnsecrets]
        label=WARNING: 
        interval=once
        command=echo "Secrets are not loaded into build - refer to github:hexf/dotfiles README for more info"
        ''
      ];
    });

    blocksRight = [
      ''
      [date]
      command=date "+%D %T"
      interval=1
      '' 
    ];

  };

}
