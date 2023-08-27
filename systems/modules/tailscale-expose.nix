{ config, lib, pkgs, ... }:

with lib;


let
  cfg = config.services.tailscale.expose;
  pcfg = config.service.tailscale;
in {
  options.services.tailscale.expose = {

    enable = (mkEnableOption (mdDoc "tailscale expose")) // {
      default = true;
      example = false;
    };

    authKey = mkOption {
      type = types.str;
      description = mdDoc ''
        auth key to authorize all the tailscale service node
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/tailscale-expose";
      description = mdDoc ''
        persistent data dir path
      '';
    };

    services = mkOption {
      description = mdDoc "tailscale expose services";
      type = types.attrsOf ( types.submodule {
        options = {
          httpsRoutes = mkOption {
            type = types.attrs;
            default = null;
            example = {
              "/" = "http://localhost:3000"
            };
            description = mdDoc ''
              Paths and destinations. Tailscale will automatically add TLS
            '';
          };

          funnel = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = mdDoc ''
            Funnel traffic through tailscale funnel0
            '';
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    systemd.services = (mapAttrs' (name: cfg': nameValuePair ("tailscale_expose_tailscaled@" + name) ({
      wantedBy = [ "multi-user.target" ];
      path = [
        config.networking.resolvconf.package # for configuring DNS in some configs
        pkgs.procps     # for collecting running services (opt-in feature)
        pkgs.glibc      # for `getent` to look up user shells
      ];

      serviceConfig.ExecStart = "${pcfg.package}/bin/tailscaled --tun userspace-networking --statedir '${cfg.dataDir}/${name}' --socket '${cfg.dataDir}/${name}/tailscale.sock'";
    }))) // (mapAttrs' (name: cfg': nameValuePair ("tailscale_expose_setup@" + name) (let
      tailscale = "${pcfg.package}/bin/tailscale --socket '${cfg.dataDir}/${name}/tailscale.sock'";
    in {
      wantedBy = [ "multi-user.target" ];
      after = ["tailscale_expose_tailscaled@" + name];

      serviceConfig.Type = "oneshot";
      script = ''
        ${tailscale} up --hostname "${name}" 
      '' + ((foldr (a: b: ''
      ${a}
      ${b}
      '') "") (mapAttrsToList (path: target: ''
        ${tailscale} serve https '${path}' '${target}'
      '') cfg'.httpsRoutes)) + optionalString cfg'.funnel ''
        ${tailscale} funnel 443 on
      '';
    })));
  
  };
}