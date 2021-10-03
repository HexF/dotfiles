{config, libs, pkgs, ...}:
let
    theme = import ./theme.nix;
in {
    #programs.alacritty = {
    #    enable = true;
    #    settings = {
    #        env.TERM = "xterm-256color";
    #        background_opacity = 0.5;
    #        font = {
    #            normal = {
    #                family = theme.font.general.family;
    #            };
    #        };

    #        colors = {
    #            normal = {
    #                black = builtins.elemAt theme.color 0;
    #                red = builtins.elemAt theme.color 1;
    #                green = builtins.elemAt theme.color 2;
    #                yellow = builtins.elemAt theme.color 3;
    #                blue = builtins.elemAt theme.color 4;
    #                magenta = builtins.elemAt theme.color 5;
    #                cyan = builtins.elemAt theme.color 6;
    #                white = builtins.elemAt theme.color 7;
    #            };

    #            bright = {
    #                black = builtins.elemAt theme.color 8;
    #                red = builtins.elemAt theme.color 9;
    #                green = builtins.elemAt theme.color 10;
    #                yellow = builtins.elemAt theme.color 11;
    #                blue = builtins.elemAt theme.color 12;
    #                magenta = builtins.elemAt theme.color 13;
    #                cyan = builtins.elemAt theme.color 14;
    #                white = builtins.elemAt theme.color 15;
    #            };
    #        };
    #    };
    #};


    programs.kitty = {
        enable = true;
        font = {
            name = theme.font.terminal.family;
            size = theme.font.terminal.size;
        };
        settings = {
            background_opacity = "0.5";
            foreground = theme.foreground;
            background = theme.background;

            color0 = builtins.elemAt theme.color 0;
            color1 = builtins.elemAt theme.color 1;
            color2 = builtins.elemAt theme.color 2;
            color3 = builtins.elemAt theme.color 3;
            color4 = builtins.elemAt theme.color 4;
            color5 = builtins.elemAt theme.color 5;
            color6 = builtins.elemAt theme.color 6;
            color7 = builtins.elemAt theme.color 7;
            color8 = builtins.elemAt theme.color 8;
            color9 = builtins.elemAt theme.color 9;
            color10 = builtins.elemAt theme.color 10;
            color11 = builtins.elemAt theme.color 11;
            color12 = builtins.elemAt theme.color 12;
            color13 = builtins.elemAt theme.color 13;
            color14 = builtins.elemAt theme.color 14;
            color15 = builtins.elemAt theme.color 15;

        };
    };
    
}