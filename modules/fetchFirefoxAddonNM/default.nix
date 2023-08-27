{stdenv, lib, coreutils, unzip, jq, zip, fetchurl,writeScript,  ...}:

{
  name
, url
, addonId
, md5 ? ""
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
    inherit md5 sha1 sha256 sha512 hash;
  };
  nativeBuildInputs = [ coreutils unzip zip jq  ];
}