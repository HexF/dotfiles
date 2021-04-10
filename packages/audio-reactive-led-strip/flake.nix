{
  inputs = {};
  outputs = { self, nixpkgs, .. }:
    pkgs.python3Packages.buildPythonApplication rec {
      pname = "audio-reactive-led-strip";
      version = "1.0.0";

      src = pkgs.fetchFromGitHub {
        owner = "HexF";
        repo = "audio-reactive-led-strip";
        rev = "v1.0.0";
        sha256 = "sha256-hCZH/xOLqjrkIBaCr5MnTvMVlbcnglHlyWjh13iyYo4=";
      };

      propagatedBuildInputs = with pkgs.python3Packages; [ numpy scipy pyaudio ];

      checkPhase = ''
      '';

      meta = {
        description = "Audio Reactive LED Strip service";
      };
    };
}