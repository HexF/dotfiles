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
        xdg.configFile."i3blocks/config".text = builtins.concatStringsSep "\n" (cfg.blocksLeft ++ cfg.blocksCenter ++ cfg.blocksRight);
    };
}