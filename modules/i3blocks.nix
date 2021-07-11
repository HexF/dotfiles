{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.programs.i3blocks;
in {
    options = {
        programs.i3blocks = {
            enable = mkOption {
                default = false;                
            };

            pkg = mkOption {
                default = pkgs.i3blocks;
            };
            
            blocksLeft = mkOption {
                default = [];
            };

            blocksCenter = mkOption {
                default = [];
            };

            blocksRight = mkOption {
                default = [];
            };
        };
    };


    config = mkIf cfg.enable {
        home.packages = [ cfg.pkg ];
        xdg.configFile."i3blocks/config".text = builtins.concatStringsSep "\n" (cfg.blocksLeft ++ cfg.blocksCenter ++ cfg.blocksRight);
    };
}