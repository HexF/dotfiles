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
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
  };
}

