{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.programs.betterdiscord;
    betterdiscordctl = "${cfg.pkg}/bin/betterdiscordctl";
    plugins = cfg.plugins;
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

            plugins = mkOption {
                default = [];
            };
            
        };
    };


    config = mkIf cfg.enable {
        home.packages = [
            cfg.discord-pkg
        ];

        home.activation.betterdiscord = config.lib.dag.entryAfter ["writeBoundary"] ''
            ${betterdiscordctl} status | grep 'injected: yes$' || ${betterdiscordctl} install
        '';
    };
}