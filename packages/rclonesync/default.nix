{ lib, stdenv, fetchurl, python3, makeWrapper, rclone }:

let version = "15c05d7000ef2426466a501ef045cd1d6eba0437"; in

stdenv.mkDerivation {
  pname = "rclonesync";
  inherit version;

  src = fetchurl {
    url = "https://raw.githubusercontent.com/cjnaz/rclonesync-V2/15c05d7000ef2426466a501ef045cd1d6eba0437/rclonesync";
    sha256 = "sha256-9D1a9zsBefwRuK8imaxIGu4GR/DiCVQJubn26rvqudM=";
  };

  phases = [ "installPhase" ];

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/rclonesync
    makeWrapper ${python3}/bin/python3 $out/bin/rclonesync --add-flags "$out/rclonesync --rclone ${rclone}/bin/rclone"
  '';

  meta = {};
}