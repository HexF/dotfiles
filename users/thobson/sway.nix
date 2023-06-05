{config, lib, pkgs, ...}:

let
  mod = "Mod1";
  theme = import ./theme.nix;
  rofiPackage = pkgs.rofi-wayland.override { plugins = [ pkgs.rofi-emoji ]; };
  terminal = "${pkgs.kitty}/bin/kitty";
in {
  imports = [
    ./statusline.nix
    ../modules/i3blocks.nix
  ];

  programs.rofi = {
    enable = true;
    package = rofiPackage;
    terminal = terminal;
    
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };


      window = rec {
        enabled = true;
        background-color = mkLiteral theme.background;
        border-color = background-color;
        transparency = "real";
        anchor = "center";
        location = "center";
        width = mkLiteral "60%"; #60% of monito
      };

      scrollbar = {
        enabled = false;
      };

      element = {
        border = 0;
        padding = mkLiteral "1px";
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      element-text = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      
      "element normal.normal" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element selected.normal" = {
        background-color = mkLiteral theme.accent;
        text-color = mkLiteral theme.foreground;
      };

      "element alternate.normal" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element normal.active" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element selected.active" = {
        background-color = mkLiteral theme.accent;
        text-color = mkLiteral theme.foreground;
      };

      "element alternate.active" = {
        background-color = mkLiteral theme.background;
        text-color = mkLiteral theme.foreground;
      };

      "element normal.urgent" = {
        background-color = mkLiteral (builtins.elemAt theme.color 1);
        text-color = mkLiteral theme.foreground;
      };

      "element selected.urgent" = {
        background-color = mkLiteral theme.accent;
        text-color = mkLiteral theme.foreground;
      };

      "element alternate.urgent" = {
        background-color = mkLiteral (builtins.elemAt theme.color 1);
        text-color = mkLiteral theme.foreground;
      };
    };
  };


  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = {
      inherit terminal;
    };
  };
}
