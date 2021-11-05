{ systemName, config, pkgs, ... }:
let
  useSecret = import ../../useSecret.nix;
  discord-latest = pkgs.discord.overrideAttrs (old: {
    version = "0.0.16";
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/0.0.16/discord-0.0.16.tar.gz";
      sha256 = "sha256-UTVKjs/i7C/m8141bXBsakQRFd/c//EmqqhKhkr1OOk=";
    };
  });
  theme = import ./theme.nix;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "thobson";
  home.homeDirectory = "/home/thobson";


  imports = [
    ./notes.nix
    ./i3.nix
    ./kitty.nix
    ./keepass.nix
    ./browser.nix
    ./display.nix
    ../../modules/betterdiscord.nix

    (./. + "/${systemName}.nix")
    ];

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs;[
      mopidy-mpd
      mopidy-subidy
      mopidy-scrobbler
    ];
    configuration = ''
    [file]
    enabled=false
    [mpd]
    hostname=127.0.0.1
    command_blacklist=
    '' + (useSecret {
      callback = secrets: ''
      [subidy]
      url=${secrets.airsonic.url}
      username=${secrets.airsonic.username}
      password=${secrets.airsonic.password}
      [scrobbler]
      username=${secrets.lastfm.username}
      password=${secrets.lastfm.password}
      '';
      default = "";
    });
  };

  fonts.fontconfig.enable = true;


  home.packages = with pkgs; [
    spotify
    thunderbird
    master.neofetch
    texstudio
    languagetool
    pavucontrol
    nmap
    xfce.thunar
    xdotool
    cantata
    carla
    libreoffice
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  


  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-vscode.cpptools
        gruntfuggly.todo-tree
        pkief.material-icon-theme
        github.vscode-pull-request-github
        eamodio.gitlens
        jnoortheen.nix-ide
        esbenp.prettier-vscode
        ms-python.vscode-pylance
        ms-python.python
        zhuangtongfa.material-theme # One Dark Pro
      ];
    userSettings = {
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.colorTheme" = "One Dark Pro";
      "editor.fontFamily" = "'${theme.font.general.family}'";
      "window.zoomLevel" = -1;
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "nix.enableLanguageServer" = true;
      "git.autofetch" = true;
      "glassit.alpha" = 250;

    };
  };

  programs.git = {
    enable = true;
    userName = "Thomas Hobson";
    userEmail = "thomas@hexf.me";
    signing.key = "0x107DA02C7AE97B084746564B9F1FD9D87950DB6F";
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "qt";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = (useSecret {
      callback = secrets: secrets.ssh_hosts;
      default = {};
    });
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;

    shellAliases = {
      nrb = "sudo nixos-rebuild --flake ~/dotfiles# switch";
    };

    plugins = [
      {
        name = "hexf-zsh-prompt";
        file = "hexf.zsh-theme";
        src = ./zsh-hexf;
      }
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
    
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.betterdiscord = {
    enable = true;
    discord-pkg = discord-latest;
  };

  

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
