{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager = {
      session = [
        {
            manage = "desktop";
            name = "xsession";
            start = ''exec $HOME/.xsession'';
        }
      ];
    };
  };
}

