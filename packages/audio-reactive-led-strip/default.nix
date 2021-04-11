{fetchFromGitHub, python3Packages}: 

with python3Packages;

buildPythonApplication rec {
    pname = "audio-reactive-led-strip";
    version = "1.0.1";

    src = fetchFromGitHub {
        owner = "HexF";
        repo = "audio-reactive-led-strip";
        rev = "v${version}";
        sha256 = "sha256-2rVRgDKrgd4nhuX67DNzYRjCD2BhtiDzrGS2OeBsO7A=";
    };

    propagatedBuildInputs = [ numpy scipy pyaudio ];

    checkPhase = ''
    '';

    meta = {
        description = "Audio Reactive LED Strip service";
    };
}