{ config, lib, pkgs, ... }:

with lib;


let
	cfg = config.services.mopidy;

	file = pkgs.writeText "mopidy.conf" cfg.configuration;
	configs = concatStringsSep ":" ([file] ++ cfg.extraConfigFiles);

	mopidyEnv = with pkgs; buildEnv {
        name = "mopidy-with-extensions-${mopidy.version}";
        paths = closePropagation cfg.extensionPackages;
        pathsToLink = [ "/${mopidyPackages.python.sitePackages}" ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
        makeWrapper ${mopidy}/bin/mopidy $out/bin/mopidy \
            --prefix PYTHONPATH : $out/${mopidyPackages.python.sitePackages}
        '';
	};
in {
	options = {
		services.mopidy = {
			enable = mkEnableOption "Mopidy, a music player daemon";

			dataDir = mkOption {
				default = "${config.xdg.dataHome}/mopidy";
				defaultText = "$XDG_DATA_HOME/mopidy";
				type = types.str;
				description = ''
					The directory where Mopidy stores its state.
				'';
			};

			extensionPackages = mkOption {
				default = [];
				type = types.listOf types.package;
				example = literalExample "[ pkgs.mopidy-spotify ]";
				description = ''
					Mopidy extensions that should be loaded by the service.
				'';
			};

			configuration = mkOption {
				default = "";
				type = types.lines;
				description = ''
					The configuration that Mopidy should use.
				'';
			};

			extraConfigFiles = mkOption {
				default = [];
				type = types.listOf types.str;
				description = ''
					Extra config file read by Mopidy when the service starts.
					Later files in the list overrides earlier configuration.
				'';
			};
		};
	};

	config = let
		ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p '${cfg.dataDir}'";
		ExecStart = "${mopidyEnv}/bin/mopidy --config ${configs}";
	in mkIf cfg.enable {
		systemd.user.services.mopidy = {
			Unit = {
				After = ["network.target" "sound.target"];
				Description = "mopidy music player daemon";
			};

			Service = {
				Restart = "on-failure";
				inherit ExecStartPre ExecStart;
			};

			Install = {
				WantedBy = ["default.target"];
			};
		};

		systemd.user.services.mopidy-scan = {
			Unit = {
				Description = "mopidy local files scanner";
			};

			Service = {
				ExecStart = "${ExecStart} local scan";
				Type = "oneshot";
				inherit ExecStartPre;
			};
		};
	};
}