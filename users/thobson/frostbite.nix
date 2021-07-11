{config, lib, pkgs, ...}: {

    programs.i3blocks.blocksCenter = [
    ''
    [battery]
    label=Battery:
    command=echo " $(cat /sys/class/power_supply/BAT0/capacity)% ($(cat /sys/class/power_supply/BAT0/status))"
    interval=5
    ''
    ];

}