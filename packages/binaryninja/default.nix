{ stdenv, autoPatchelfHook, makeWrapper, fetchurl, unzip, libGL, glib, fontconfig, xorg, dbus, xkeyboard_config, qt6 }:
stdenv.mkDerivation rec {
  name = "binary-ninja-personal";
  buildInputs = [ autoPatchelfHook makeWrapper unzip libGL stdenv.cc.cc.lib glib fontconfig xorg.libXi xorg.libXrender dbus qt6.full ];
  src = fetchurl {
    url = "https://binaryninja.s3.amazonaws.com/installers/binaryninja_personal_linux.zip";
    sha256 = "sha256-dwvp5+dvSwg6p2f48q1v3T3dviR2WKhJBaf2JUAvSb8=";
  };

  buildPhase = ":";
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja
    makeWrapper $out/opt/binaryninja \
          $out/bin/binaryninja \
          --prefix "QT_XKB_CONFIG_ROOT" ":" "${xkeyboard_config}/share/X11/xkb"
  '';
}
