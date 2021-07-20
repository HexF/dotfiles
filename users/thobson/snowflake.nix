{config, lib, pkgs, ...}:
let
  useSecret = import ../../useSecret.nix;

in
{

  home.packages = with pkgs; [
    multimc
    adoptopenjdk-jre-openj9-bin-16
    dotnet-sdk
    insomnia
    (mindustry.override {
      jdk = adoptopenjdk-hotspot-bin-15;
    })
    (useSecret {
      callback = secrets: pkgs.factorio.override {
        username = secrets.factorio.username;
        token = secrets.factorio.token;
      };
    })
    jetbrains.datagrip
    jetbrains.idea-ultimate
    (callPackage ../../packages/audio-reactive-led-strip {})
    (callPackage ../../packages/digital {})

  ];

}
