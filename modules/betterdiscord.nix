{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.programs.betterdiscord;

in {
    options = {
        programs.betterdiscord = {
            enable = mkOption {
                default = false;                
            };

            discord-pkg = mkOption {
                default = pkgs.discord;
            };

            pkg = mkOption {
                default = pkgs.betterdiscordctl;
            };
            
        };
    };


    config = mkIf cfg.enable {
        home.packages = [
            cfg.discord-pkg
        ];

        home.activation.betterdiscord = config.lib.dag.entryAfter ["writeBoundary"] ''
            ${betterdiscordctl}/bin/betterdiscordctl status | grep 'injected: yes$'

            if [[ $? -eq 1 ]]; then
                ${betterdiscordctl}/bin/betterdiscordctl install
            fi
        '';
    };
}