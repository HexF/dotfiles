{ config, pkgs, ... }: {

    imports = [
        ../modules/base.nix
        ../modules/bios.nix
        ../modules/server.nix

        ./modules/media-server.nix

        ./hardware-configuration.nix
    ];

    
    networking.interfaces.ens192.useDHCP = true;
    networking.hostName = "hydroxide";


    services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        virtualHosts = {
            "git.hexdev.nz" = {
                locations."/".proxyPass = "http://localhost:8092/";   # Proxy Gitea
            };
            "ci.hexdev.nz" = {
                locations."/".proxyPass = "http://localhost:8080/";   # Proxy Jenkins
            };
            "auth.hexdev.nz" = {
                locations."/".proxyPass = "http://localhost:8081/";   # Proxy Keycloak
            };
            "issue.hexdev.nz" = {
                locations."/".proxyPass = "http://localhost:8082/";   # Proxy YouTrack
                locations."/".extraConfig = ''
                    proxy_set_header X-Forwarded-Host $http_host;
                '';
            };
        };    
    };

    services.media-server = {
        enable = true;
        jellyfin.enable = true;
        sonarr.enable = true;
        radarr.enable = true;
        jackett.enable = true;
        lidarr.enable = true;
        navidrome.enable = true;
        unmanic.enable = true;

        vhostSuffix = ".oh.hexf.me";
    };

    services.gitea = {
        enable = true;
        appName = "HexDev: Gitea";
        database = {
            type = "postgres";
            passwordFile = "/etc/passwordfile";
        };
        domain = "git.hexdev.nz";
        rootUrl = "https://git.hexdev.nz";
        httpPort = 8092;
        repositoryRoot = "/mnt/src/repo";
        stateDir = "/mnt/src/gitea";
        disableRegistration = true;
    
    };

    services.youtrack = {
        enable = true;
        port = 8082;
        package = with pkgs; stdenv.mkDerivation rec {
            pname = "youtrack";
            version = "2021.4.35970";

            jar = fetchurl {
                url = "https://download.jetbrains.com/charisma/${pname}-${version}.jar";
                sha256 = "sha256-HB515TS0XXEAiT463nVHP/naeoF7nmeB+6EK0NJ+5c0=";
            };

            nativeBuildInputs = [ makeWrapper ];

            dontUnpack = true;

            installPhase = ''
                runHook preInstall
                makeWrapper ${jdk11}/bin/java $out/bin/youtrack \
                --add-flags "\$YOUTRACK_JVM_OPTS -jar $jar" \
                --prefix PATH : "${lib.makeBinPath [ gawk ]}" \
                --set JRE_HOME ${jdk11}
                runHook postInstall
            '';
        };
    };

    services.keycloak = {
        enable = true;
        httpPort = "8081";
        database.passwordFile = "/etc/passwordfile";

        settings = {
            hostname = "auth.hexdev.nz";
            http-relative-path = "auth";
        };
    };

    services.postgresql = {
        enable = true;
        authentication = ''
            local gitea all ident map=gitea-users
        '';
        identMap = ''
            gitea-users gitea gitea
        '';
    };

    services.jenkins = {
        enable = true;
        home = "/mnt/src/jenkins";

        withCLI = true;
    };

    fileSystems."/mnt/media" = {
        device = "192.168.1.101:/volume2/Media";
        fsType = "nfs";
    };

    fileSystems."/mnt/src" = {
        device = "192.168.1.101:/volume4/Thomas Source Code";
        fsType = "nfs";
    };


    users.users.turbotylar = {
        isNormalUser = true;
        extraGroups = [ ];
        shell = pkgs.zsh;
    };

    

    networking.firewall.allowedTCPPorts = [ 3000 80 ];
}