{config, lib, pkgs, ...}:

let
  mod = "Mod1";
in {
  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = mod;
      terminal = "${pkgs.alacritty}/bin/alacritty";

      keybindings = lib.mkOptionDefault {
        # bindsym --release Mod4+e exec --no-startup-id "emojify -c > /tmp/out"
        "${mod}+l" = "exec hass_light";
        "${mod}+Shift+e" = "exit";

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
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
        }
      ];
    };


    extraConfig = ''
    gaps outer 10
    gaps inner +25

    new_window pixel 2
    hide_edge_borders vertical

    '';
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
