{config, lib, pkgs, inputs, ...}:
{


  home.packages = with pkgs; builtins.filter (x: x != null) [
    #(multimc.override { msaClientID = "72638b48-de29-4187-980e-209e4747e099"; })
    prismlauncher
    jdk
    dotnet-sdk
    insomnia
    unstable.easyeffects
    jetbrains.datagrip
    jetbrains.idea-ultimate

    teamspeak_client
    lutris

    (callPackage ../../packages/audio-reactive-led-strip {})
    #unstable.factorio

  ];

}
