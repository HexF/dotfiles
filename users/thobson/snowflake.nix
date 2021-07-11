{config, lib, pkgs, ...}:
let
  secrets = (builtins.fromJSON (builtins.readFile ./secrets.json));

  factorio-authed = pkgs.factorio.override {
    username = secrets.factorio.username;
    token = secrets.factorio.token;
  };
in
{

  home.packages = with pkgs; [
    multimc
    dotnet-sdk
    insomnia
    factorio-authed
    jetbrains.datagrip
    jetbrains.idea-ultimate
    (callPackage ../../packages/audio-reactive-led-strip {})
    (callPackage ../../packages/digital {})

  ];

}
