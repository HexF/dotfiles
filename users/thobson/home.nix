{ config, pkgs, ... }:
let
  secrets = (builtins.fromJSON (builtins.readFile ./secrets.json));
  discord-latest = pkgs.discord.overrideAttrs (old: {
      version = "0.0.15";
      src = pkgs.fetchurl {
        url = "https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.tar.gz";
        sha256 = "sha256-re3pVOnGltluJUdZtTlSeiSrHULw1UjFxDCdGj/Dwl4=";
      };
    });

  factorio-authed = pkgs.factorio.override {
    username = secrets.factorio.username;
    token = secrets.factorio.token;
  };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "thobson";
  home.homeDirectory = "/home/thobson";


  imports = [
    ./i3.nix
    ./alacritty.nix
    ./emacs.nix
    ];

  home.packages = with pkgs; [
    discord-latest
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
    pavucontrol
    dotnet-sdk
    nmap
    logisim
    obs-studio
    direnv
    exa
    insomnia
    qpaeq
    jetbrains.datagrip
    jetbrains.idea-ultimate
    git-crypt
    factorio-authed
    xfce.thunar
    (callPackage ../../packages/audio-reactive-led-strip {})
    (callPackage ../../packages/digital {})
    #callPackage ../../test.nix {}
    #custom.audio-reactive-led-strip
    
  ];

  services.udiskie = {
    enable = true;
  };



  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-vscode.cpptools
        WakaTime.vscode-wakatime
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

  programs.ssh = {
    enable = true;
    matchBlocks = import ./ssh_hosts.nix {};
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;

    shellAliases = {
      sl = "exa";
      ls = "exa";
      l = "exa -l";
      la = "exa -la";
      nrb = "sudo nixos-rebuild --flake ~/dotfiles# switch";
    };

    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
  };


  

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
