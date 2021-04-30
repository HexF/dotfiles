{config, libs, pkgs, ...}: 
{

    programs.alacritty = {
        enable = true;
        settings = {
            env.TERM = "xterm-256color";
            background_opacity = 0.5;
        };
    };
    
}