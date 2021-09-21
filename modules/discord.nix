{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.programs.discord;
    autoStartItem = pkgs.makeAutostartItem {
        name = "discord";
        package = cfg.pkg;
    };
in {
    options = {
        programs.discord = {
            enable = mkOption {
                default = false;                
            };

            pkg = mkOption {
                default = pkgs.discord;
            };

            autostart = mkOption {
                default = false;
            };
            
        };
    };


    config = mkIf cfg.enable {
        home.packages = [
            cfg.pkg
            ] ++ (
                if cfg.autostart 
                then [ autoStartItem ]
                else []
            );
    };
}