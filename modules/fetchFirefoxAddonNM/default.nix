{stdenv, lib, coreutils, unzip, jq, zip, fetchurl,writeScript,  ...}:

{
  name
, url
, addonId
, sha1 ? ""
, sha256 ? ""
, sha512 ? ""
, hash ? ""
}:

stdenv.mkDerivation rec {

  inherit name;
  passthru = {
    extid = addonId;
  };

  builder = writeScript "xpibuilder" ''
    source $stdenv/setup
    #header "firefox addon $name into $out"
    UUID="${addonId}"
    mkdir -p "$out/$UUID"
    cp ${src} $out/$UUID.xpi
  '';
  
  src = fetchurl {
    url = url;
    inherit sha1 sha256 sha512 hash;
  };
  nativeBuildInputs = [ coreutils unzip zip jq  ];
}