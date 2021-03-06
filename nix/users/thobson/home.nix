{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "thobson";
  home.homeDirectory = "/home/thobson";

  imports = [./i3.nix];

  home.packages = [
    pkgs.discord
    pkgs.spotify
    pkgs.vscode
    pkgs.scrot
    pkgs.thunderbird
    pkgs.playerctl
    pkgs.neofetch
    pkgs.nix-index
    pkgs.xclip
    pkgs.texstudio
    pkgs.multimc
    pkgs.dmenu
    pkgs.i3blocks
    pkgs.alacritty
  ];

  programs.git = {
    enable = true;
    userName = "Thomas Hobson";
    userEmail = "thomas@hexf.me";
    signing.key = "0x107DA02C7AE97B084746564B9F1FD9D87950DB6F";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };


  xdg.configFile."i3blocks/config".text = ''
  [song]
  label=Song: 
  command=echo $(${pkgs.playerctl}/bin/playerctl metadata title) - $(${pkgs.playerctl}/bin/playerctl metadata artist); echo $(${pkgs.playerctl}/bin/playerctl metadata title)

  interval=1

  [volume]
  label=Volume: 
  command=amixer get Master | grep -oP 'Right: .* \[\K\d+'
  interval=once
  signal=2

  [date]
  command=date "+%D %T"
  interval=1

  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
