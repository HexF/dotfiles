{config, pkgs, lib, ...}:


let 
  atm10_serverfiles = pkgs.fetchzip {
    url = "https://mediafilez.forgecdn.net/files/7558/613/ServerFiles-5.5.zip";
    sha512 = "sha512-BwnDRyiCEskca9GEq+loVqaN1R42upVrcket+jQE+DLj8ybTwmSoHi50tCG9hnlW06cGiL1VAM+HfrhGRsuP7Q==";
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.atm10 = {
        enable = true;
        package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_219;

        serverProperties = {
          allow-flight = true;
          motd = "All the Mods 10";
          max-tick-time = 180000;
        };

        symlinks = {
          mods = "${atm10_serverfiles}/mods";
          local = "${atm10_serverfiles}/local";
          defaultconfigs = "${atm10_serverfiles}/defaultconfigs";
          kubejs = "${atm10_serverfiles}/kubejs";
          "datapacks/sawmill.zip" = "${atm10_serverfiles}/datapacks/sawmill.zip";
        };

        files = {
          config = "${atm10_serverfiles}/config";
        };

        jvmOpts = "-Xms4G -Xmx16G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
      };
  };

}


