{ systemName, config, pkgs, nixpkgs, ... }:
let
  discord-latest = pkgs.discord.overrideAttrs (old: {
    version = "0.0.21";
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/0.0.21/discord-0.0.21.tar.gz";
      sha256 = "sha256-KDKUssPRrs/D10s5GhJ23hctatQmyqd27xS9nU7iNaM=";
    };
  });
  theme = import ./theme.nix;
  secrets_path = "/run/secrets/";

  tidalapi = pkgs.python3Packages.buildPythonPackage rec {
    pname = "tidalapi";
    version = "0.6.8";
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-/kce4n8uhpm8hncPY3/iodwWShbkcuWODuwgHoTvfz0=";
    };
    propagatedBuildInputs = [
      pkgs.python3Packages.requests
    ];
  };

  mopidy-tidal = pkgs.python3Packages.buildPythonApplication rec {
    pname = "mopidy-tidal";
    version = "0.2.6";
    src = pkgs.fetchFromGitHub {
      owner = "tehkillerbee";
      repo = "mopidy-tidal";
      rev = "83ad5c4363c3c578dc7c67a9ff8ac49bec212443";
      sha256 = "sha256-PFmGdpN7s1d4TpwFxgsZDetFlL09boXA3c/GNiLkDc4=";
    };

    propagatedBuildInputs = [
      pkgs.mopidy
      pkgs.python3Packages.pykka
      tidalapi
      pkgs.python3Packages.requests
    ];
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
    ./notes.nix
    # ./i3.nix
    #./sway.nix
    ./kitty.nix
    ./keepass.nix
    ./browser.nix
    ./display.nix
    

    (./. + "/${systemName}.nix")
    ];

  services.mopidyCustom = {
    enable = true;
    extensionPackages = with pkgs;[
      mopidy-mpd
      mopidy-subidy
      mopidy-scrobbler
      mopidy-tidal
    ];
    configuration = ''
    [file]
    enabled=false
    [mpd]
    hostname=127.0.0.1
    command_blacklist=
    '';
    extraConfigFiles = [
      "${secrets_path}/thobson_mopidy_config"
    ];
  };

  fonts.fontconfig.enable = true;


  home.packages = with pkgs; [
    remmina
    # spotify
    tidal-hifi
    thunderbird
    discord
    master.neofetch
    texstudio
    languagetool
    pavucontrol
    nmap
    xfce.thunar
    xdotool
    cantata
    libreoffice
    plantuml
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
    aileron
    oci-cli
    lens
    kubernetes-helm
    kubectl
    devenv
    unstable.rnote
    zotero
    # (rnote.overrideAttrs(old: rec {
    #   version = "0.9.0";
    #    src = fetchFromGitHub {
    #     owner = "flxzt";
    #     repo = "rnote";
    #     rev = "v${version}";
    #     hash = "sha256-fkJQfIp4Q5CpQUbBtiHA4SGQP/O6jiccfqrz4yiXpbk=";
    #   };

    #   cargoDeps = rustPlatform.importCargoLock {
    #     lockFile = ./Cargo-rnote.lock;
    #     outputHashes = {
    #       "ink-stroke-modeler-rs-0.1.0" = "sha256-WfZwezohm8+ZXiKZlssTX+b/Izk1M4jFwxQejeTfc6M=";
    #       "piet-0.6.2" = "sha256-WrQok0T7uVQEp8SvNWlgqwQHfS7q0510bnP1ecr+s1Q=";
    #     };
    #   };
    # }))
    (sage.override { extraPythonPackages = pypkgs: [ (
      # we need to package this for python??
      pypkgs.buildPythonPackage rec {
        pname = "sagetex";
        version = sagetex.version;
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-AxYuxiy4baE6dH+YIkGvPk9M3U0p/LqPu2xpgqnpBtk=";
        };
        doCheck = false;
        propagatedBuildInputs = [
          pypkgs.pyparsing
        ];
      }
    ) ]; requireSageTests = false; } ) # math major vibes
  ];

  qt.style.name = "adwaita-dark";
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.sessionVariables.NIX_PATH = "nixpkgs=${nixpkgs.outPath}";

  programs.emacs = {
	enable = true;
	package = pkgs.emacs-gtk;
  };

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
      "sops.binPath" = "${pkgs.sops}/bin/sops";
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
    extraOptionOverrides = {
      Include = "${secrets_path}/thobson_ssh_hosts";
    };

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
    };
    
  };

  programs.eza = {
    enable = true;
    enableAliases = true;
  };


  home.file.".background-image".source = ../../wallpaper.jpg;

  services.udiskie = {
    enable = true;
  };

  services.nextcloud-client  = {
    enable = true;
    startInBackground = true;
  };


  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs) 
      scheme-full;
      inherit (pkgs) sagetex;
    };
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
