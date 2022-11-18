{ config, pkgs, ... }:

{
  services.openvpn.servers = {
    htb_starting_point  = { config = "config ${config.sops.secrets.htb_starting_point_vpn.path}"; };
  };

  sops.secrets = {
    htb_starting_point_vpn = {
        key = "htb_starting_point";
        mode = "0400";

        sopsFile = ../secrets/secrets.yaml;
    };
  };
}
