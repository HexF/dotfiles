{ systemName, config, pkgs, nixpkgs, ... }:
let
  theme = import ./theme.nix;
  secrets_path = "/run/secrets/";
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
    ./mail.nix

    (./. + "/${systemName}.nix")
    ];

  fonts.fontconfig.enable = true;


  home.packages = with pkgs; [
    remmina
    unstable.tidal-hifi
    thunderbird
    discord
    master.neofetch
    pavucontrol
    nmap
    xfce.thunar
    xdotool
    # (nerdfonts.override {fonts = ["JetBrainsMono"];})
    aileron
    devenv
    zotero
  ];

  qt.style.name = "adwaita-dark";
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  home.sessionVariables.NIX_PATH = "nixpkgs=${nixpkgs.outPath}";

  # programs.emacs = {
	# enable = true;
	# package = pkgs.emacs-gtk;
  # };

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
    pinentryPackage = pkgs.pinentry-gtk2;
    # pinentryFlavor = "gtk2";
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
    # enableBashIntegration = true;
    # enableZshIntegration = true;
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
    # enable = true;
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
