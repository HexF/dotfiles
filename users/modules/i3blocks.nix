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
        xdg.configFile."i3blocks/config".onChange = ''
          i3Socket=''${XDG_RUNTIME_DIR:-/run/user/$UID}/i3/ipc-socket.*
          if [ -S $i3Socket ]; then
            echo "Reloading i3"
            $DRY_RUN_CMD ${pkgs.i3}/bin/i3-msg -s $i3Socket restart 1>/dev/null
          fi
        '';
    };
}