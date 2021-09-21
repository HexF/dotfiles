{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.programs.discord;
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
            }
            
        };
    };


    config = mkIf cfg.enable {
        home.packages = [
            cfg.pkg
            ] ++ (
                if cfg.autostart 
                then ([
                    pkgs.makeDesktopItem {
                        name = "discord";
                        desktopName = "Discord";
                        exec = cfg.pkg + "/bin/Discord";
                    }
                ])
                else []
            );
    };
}