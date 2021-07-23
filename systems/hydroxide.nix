# Server for hydra
{ config, pkgs, ... }: {

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

    networking.firewall.allowedTCPPorts = [ 3000 80 ];
}