{config, lib, pkgs, inputs, ...}:
{
  imports = [
    ./i3.nix
    ./ctf.nix
    ./binja.nix
  ];

  home.packages = with pkgs; builtins.filter (x: x != null) [
    #(multimc.override { msaClientID = "72638b48-de29-4187-980e-209e4747e099"; })
    unstable.kicad
    prismlauncher
    jdk
    dotnet-sdk
    insomnia
    unstable.easyeffects
    unstable.anydesk

    lutris

    (callPackage ../../packages/audio-reactive-led-strip {})
    #unstable.factorio
    imhex

    proxmark3
  ];

}
