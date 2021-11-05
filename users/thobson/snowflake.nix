{config, lib, pkgs, inputs, ...}:
{


  home.packages = with pkgs; builtins.filter (x: x != null) [
    multimc
    adoptopenjdk-jre-openj9-bin-16
    dotnet-sdk
    insomnia
    unstable.easyeffects
    jetbrains.datagrip
    jetbrains.idea-ultimate
    (callPackage ../../packages/audio-reactive-led-strip {})

  ];

}
