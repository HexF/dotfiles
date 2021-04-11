{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "thobson";
  home.homeDirectory = "/home/thobson";

  imports = [
    ./i3.nix
    ];

  home.packages = with pkgs; [
    discord
    spotify
    scrot
    thunderbird
    playerctl
    neofetch
    nix-index
    xclip
    texstudio
    multimc
    dmenu
    i3blocks
    alacritty
    pavucontrol
    dotnet-sdk
    nmap
    (callPackage ../../packages/audio-reactive-led-strip {})
    #callPackage ../../test.nix {}
    #custom.audio-reactive-led-strip
    
  ];


  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-vscode.cpptools
        #ms-vscode-remote.remote-ssh # won't work with vscodium
      ];
  };

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
  home.stateVersion = "20.09";
}
