{config, lib, pkgs, ...}: {

    xdg.configFile."i3blocks/config".text = builtins.replaceStrings ["; DEVICE_SPECIFIC"] [''

    [battery]
    label=Battery:
    command=echo "$(cat /sys/class/power_supply/BAT0/capacity) ($(cat /sys/class/power_supply/BAT0/status))"
    
    ''];
    
}