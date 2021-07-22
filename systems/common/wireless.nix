{ config, pkgs, ... }:
let
  useSecret = import ../../useSecret.nix;
in
{
  
  networking.wireless.enable = true;

  networking.wireless.networks = useSecret {
    callback =
      secrets:
        builtins.mapAttrs (k: v: {psk = v;})
        secrets.wireless.connections
      ;
    default = {};
  };

  
  
}