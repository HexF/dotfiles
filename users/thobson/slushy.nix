{config, lib, pkgs, inputs, ...}:
{
  imports = [
    ./ctf.nix
    ./sway.nix
  ];

  home.packages = with pkgs; builtins.filter (x: x != null) [
    jetbrains.datagrip
    jetbrains.idea-ultimate

    proxmark3
    kicad
  ];

  programs.i3blocks.blocksCenter = [
    ''
    [battery]
    label=Battery:
    command=echo " $(cat /sys/class/power_supply/BAT0/capacity)% ($(cat /sys/class/power_supply/BAT0/status))"
    interval=5
    ''
    ''
    [wifi]
    command=iwgetid --raw 
    command=awk "BEGIN {print int($(iwconfig wlp0s20f3 | grep -oP '[0-9]+/[0-9]+')*100)}"
    interval=5
    ''
  ];
}
