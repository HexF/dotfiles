{config, lib, pkgs, inputs, ...}:
{


  home.packages = with pkgs; builtins.filter (x: x != null) [
    multimc
    jdk
    dotnet-sdk
    insomnia
    unstable.easyeffects
    jetbrains.datagrip
    jetbrains.idea-ultimate

    (callPackage ../../packages/audio-reactive-led-strip {})
    #unstable.factorio

  ];

}
