{ lib, stdenv, fetchurl, jre, makeWrapper, unzip }:

let version = "0.27"; in

stdenv.mkDerivation {
  pname = "digital";
  inherit version;

  src = fetchurl {
    url = "https://github.com/hneemann/Digital/releases/download/v${version}/Digital.zip";
    sha256 = "sha256-qTud1w7VsFG/BKrMN/J5TDw9F/IUq5nwyPSjblW76DU=";
  };

  phases = [ "installPhase" ];

  nativeBuildInputs = [makeWrapper unzip];

  installPhase = ''
    mkdir -pv $out/bin
    unzip $src -d $out
    makeWrapper ${jre}/bin/java $out/bin/digital --add-flags "-jar $out/Digital/Digital.jar"
  '';

  meta = {
    homepage = "https://github.com/hneemann/Digital";
    description = "A digital logic designer and circuit simulator. ";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
}