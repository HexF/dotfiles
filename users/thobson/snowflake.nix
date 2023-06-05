{config, lib, pkgs, inputs, ...}:
{
  imports = [
    ./ctf.nix
  ];

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
    imhex


    (proxmark3.overrideAttrs (old: { 
      src = fetchFromGitHub {
        owner = "RfidResearchGroup";
        repo = "proxmark3";
        rev = "v4.16191";
        sha256 = "sha256-l0aDp0s9ekUUHqkzGfVoSIf/4/GN2uiVGL/+QtKRCOs=";
      };

      nativeBuildInputs = old.nativeBuildInputs ++ [ libsForQt5.wrapQtAppsHook lua ];

      postPatch = ''

      '';

      buildPhase = ''
        make client
      '';

      installPhase = ''
        install -Dt $out/bin client/proxmark3
      '';
    }))
  ];

}
