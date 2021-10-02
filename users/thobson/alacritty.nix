{config, libs, pkgs, ...}:
let
    colors = import ./colors.nix;
in {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
        (nerdfonts.override {fonts = ["JetBrainsMono"];})
    ];


    programs.alacritty = {
        enable = true;
        settings = {
            env.TERM = "xterm-256color";
            background_opacity = 0.5;
            font = {
                normal = {
                    family = "JetbrainsMono Nerd Font Mono";
                };
            };

            colors = {
                normal = {
                    black = builtins.elemAt colors.color 0;
                    red = builtins.elemAt colors.color 1;
                    green = builtins.elemAt colors.color 2;
                    yellow = builtins.elemAt colors.color 3;
                    blue = builtins.elemAt colors.color 4;
                    magenta = builtins.elemAt colors.color 5;
                    cyan = builtins.elemAt colors.color 6;
                    white = builtins.elemAt colors.color 7;
                };

                bright = {
                    black = builtins.elemAt colors.color 8;
                    red = builtins.elemAt colors.color 9;
                    green = builtins.elemAt colors.color 10;
                    yellow = builtins.elemAt colors.color 11;
                    blue = builtins.elemAt colors.color 12;
                    magenta = builtins.elemAt colors.color 13;
                    cyan = builtins.elemAt colors.color 14;
                    white = builtins.elemAt colors.color 15;
                };
            };
        };
    };
    
}