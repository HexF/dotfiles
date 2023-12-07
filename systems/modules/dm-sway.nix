{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager = {
      session = [
        {
            manage = "desktop";
            name = "sway";
            start = ''
              systemctl --user start graphical-session.target
              export XDG_SESSION_TYPE="wayland"
              exec sway
            '';
        }
      ];
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    config.common.default = "*";
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
  };
}

