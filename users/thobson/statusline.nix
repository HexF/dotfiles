{config, lib, pkgs, ...}:
let
  theme = import ./theme.nix;
in {
  imports = [
    ../modules/i3blocks.nix
  ];

  programs.i3blocks = {
    enable = true;
    blocksLeft = [
      ''
      [window_title]
      interval=persist
      command=${pkgs.xtitle}/bin/xtitle -s | cat
      ''
      ''
      [ipaddr]
      label=🛜 
      command=ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1 
      interval=5
      ''
      ''
      [tailscale]
      label=🛡️ 
      interval=1
      command=${pkgs.writeScriptBin "tailscale-block" ''
      alias tailscale="${pkgs.tailscale}/bin/tailscale"
      if [[ $button -eq 3 ]]; then
        echo Switching
        tailscale switch "$(tailscale switch --list | ${pkgs.rofi}/bin/rofi -dmenu)"   
      elif [[ $button -eq 1 ]]; then
        if [[ $(tailscale status --json | ${pkgs.jq}/bin/jq -r '.BackendState') == "Stopped" ]]; then
          echo Starting
          tailscale up --operator=$USER > /dev/null
        else
          echo Stopping
          tailscale down
        fi
      else
        tailscale status --json | ${pkgs.jq}/bin/jq -r 'if .BackendState == "Running" then .CurrentTailnet | "\(.Name) (\(.MagicDNSSuffix))" else .BackendState end'
      fi
      ''}/bin/tailscale-block
      
      ''
      ''
      [song]
      command=[[ $(${pkgs.playerctl}/bin/playerctl status) = "Playing" ]] && ${pkgs.playerctl}/bin/playerctl metadata -f ' {{title}} - {{artist}}' || echo ""
      interval=1
      ''
      ''
      [volume]
      label= 
      command=${pkgs.pipewire}/bin/pw-dump -m | ${pkgs.jq}/bin/jq --unbuffered -r '.[] | if .type == "PipeWire:Interface:Metadata" then (.metadata[] | select(.key == "default.audio.sink") | "source=\( .value.name )") else if .type == "PipeWire:Interface:Node" and .info.props["media.class"] == "Audio/Sink" then "vol=\( .info.props["node.name"] )=\(.info.params.Props[0].channelVolumes[0] *100 | round)" else empty end end'  | ${pkgs.gawk}/bin/awk -F= '{ if ($1 == "source") AUDIO_SOURCE=$2; else if ($1 == "vol" && $2 == AUDIO_SOURCE) {print $3; fflush(stdout);} }' 
      interval=persist
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
      command=date "+%d/%m/%y %T"
      interval=1
      '' 
    ];

  };
}