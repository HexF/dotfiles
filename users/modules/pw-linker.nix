{config, lib, pkgs, ...}:
with lib;

let
    cfg = config.services.pwlinker;
    lines = map ({src, dst}: ''
    ${pkgs.pipewire}/bin/pw-link '${src}' '${dst}'
    '') cfg.connections;
    script = concatStringsSep "\n" lines;
in {
    options = {
        services.pwlinker = {
            enable = mkOption {
                default = false
            };

            connections = {
                default = [
                    {
                        src="spotify:output_FL";
                        dst="carla:audio-in1";
                    }
                    {
                        src="spotify:output_FR";
                        dst="carla:audio-in2";
                    }
                ];
            };
        };
    };

    config = mkIf cfg.enable {
        # Run this script
    };
}