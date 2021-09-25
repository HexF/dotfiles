# Server for hydra
{ config, pkgs, ... }: {

    imports = [
        ./common/base.nix
        ./common/bios.nix
        ./common/server.nix
        ./hydroxide-hardware.nix
        ../modules/media-server.nix
    ];
    networking.interfaces.ens192.useDHCP = true;
    networking.hostName = "hydroxide";

    services.hydra = {
        enable = true;
        hydraURL = "https://hydra.hexf.me"; # externally visible URL
        notificationSender = "hydra@localhost"; # e-mail of hydra service
        # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
        buildMachinesFiles = [];
        # you will probably also want, otherwise *everything* will be built from scratch
        useSubstitutes = true;
        extraConfig = ''
            binary_cache_public_uri = https://binarycache.hexf.me
        '';
    };

    services.nginx = {
        enable = true;
        virtualHosts = {
            "bincache.hexf.me" = {
                serverAliases = [ "binaryCache" ];
                locations."/".extraConfig = ''
                    proxy_pass http://localhost:${toString config.services.nix-serve.port};
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                '';
            };
        };  

        
    };


    services.nix-serve = {
        enable = true;
        secretKeyFile = "/var/cache-priv-key.pem";
        # Generate with
        # $ nix-store --generate-binary-cache-key binarycache.example.com cache-priv-key.pem cache-pub-key.pem
        # # mv cache-priv-key.pem /var/cache-priv-key.pem
        # # chown nix-serve /var/cache-priv-key.pem
        # # chmod 600 /var/cache-priv-key.pem
    };

    nix.buildMachines = [
        {
            hostName = "localhost";
            system = "x86_64-linux";
            supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
            maxJobs = 8;
        }
    ];


    services.media-server = {
        enable = true;
        jellyfin.enable = true;
        transmission.enable = true;
        transmission.dataDir = "/mnt/media/";
        sonarr.enable = true;
        radarr.enable = true;
        jackett.enable = true;

        vhostSuffix = ".oh.hexf.me";
    };

    fileSystems."/mnt/media" = {
        device = "192.168.1.101:/volume2/Media";
        fsType = "nfs";
    };


    users.users.turbotylar = {
        isNormalUser = true;
        extraGroups = [ ];
        shell = pkgs.zsh;
    };

    

    networking.firewall.allowedTCPPorts = [ 3000 80 ];
}