{config, lib, pkgs, inputs, ...}:
let
  useSecret = import ../../useSecret.nix;
in
{


  home.packages = with pkgs; builtins.filter (x: x != null) [
    multimc
    adoptopenjdk-jre-openj9-bin-16
    dotnet-sdk
    insomnia
    (mindustry.override {
      jdk = adoptopenjdk-hotspot-bin-15;
    })
    unstable.easyeffects
    jetbrains.datagrip
    jetbrains.idea-ultimate
    (callPackage ../../packages/audio-reactive-led-strip {})
    (callPackage ../../packages/digital {})
    #(callPackage (fetchTarball {
    #  url = "https://github.com/craigmbooth/nix-visualize/archive/ee6ad3cb3ea31bd0e9fa276f8c0840e9025c321a.tar.gz";
    #  sha256 = "sha256:1v0lg6g1cnpb2q5crmv8sv68gc1h497psy6vscv7syqlpm9zkh4y";
    #  }) {inherit pkgs; pythonPackages = python3Packages;})
    osu-lazer
    (useSecret {
      callback = secrets: (pkgs.master.factorio.override {
        username = secrets.factorio.username;
        token = secrets.factorio.token;
        experimental = true;
      });
      default = null;
    })

  ];

}
