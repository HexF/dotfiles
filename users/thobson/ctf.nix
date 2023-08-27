{config, lib, pkgs, ...}:
let
  ghidra = pkgs.ghidra.overrideAttrs(old: {
    _JAVA_AWT_WM_NONREPARENTING = 1;
  });
  mkGhidraExtension = {src, version, extname}: pkgs.stdenv.mkDerivation {
    inherit src version;

    pname = "ghidra-ext-${extname}";

    nativeBuildInputs = with pkgs; [
      gradle unzip
    ];

    dontStrip = true;

    buildPhase = ''
    shopt -s extglob
    mkdir ${extname}
    
    mv ./!(${extname}) ${extname}
    
    cd ${extname}


    gradle --offline --no-daemon --info -Dorg.gradle.java.home=${pkgs.openjdk17} -PGHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra
    '';

    installPhase = ''
    cp dist/*.zip $out
    '';
  };


  gotools = mkGhidraExtension rec {
    extname = "gotools";
    version = "0.1.2";

    src = pkgs.fetchFromGitHub {
        owner = "felberj";
        repo = "gotools";
        rev = "v${version}";
        sha256 = "sha256-/mNe2fKyMtwqHMRXyZOOkhkhTqMWbozlRXGt8PnfdX4=";
    };
  };

  ghostrings = mkGhidraExtension rec {
    extname = "ghostrings";
    version = "2.0";

    src = pkgs.fetchFromGitHub {
        owner = "nccgroup";
        repo = "ghostrings";
        rev = "v${version}";
        sha256 = "sha256-guGhth7dHwweFlAjvPCxSaevKinMLRVv8JwyaHs+eow=";
    };
  };

  wasm = mkGhidraExtension rec {
    extname = "wasm";
    version = "2.1.0";

    src = pkgs.fetchFromGitHub {
      #https://github.com/nneonneo/ghidra-wasm-plugin
        owner = "nneonneo";
        repo = "ghidra-wasm-plugin";
        rev = "v${version}";
        sha256 = "sha256-1UalKrCLYf8G3L4Svft4r+1aYmtzevZkGgBGgpWI0rM=";
    };
  };

  ghihorn = mkGhidraExtension rec {
    extname = "ghihorn";
    version = "ghidra-10.2.2";

    src = pkgs.fetchFromGitHub {
      # https://github.com/CERTCC/kaiju
        owner = "CERTCC";
        repo = "kaiju";
        rev = "${version}";
        sha256 = "sha256-F+qo3KbFCDR18UzxZMTICCunNy7RTXMWMX4z6ZGnVPg=";
    };
  };


  ghidraExtensions = [
    # gotools
    # ghostrings
    # wasm
    # ghihorn
  ];
in
{
  home.packages = with pkgs; [
    binwalk
    file
    stegseek
    swift
    yara
    z3

    pulseview

    (ghidra.overrideAttrs(old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [unzip];

      installPhase = old.installPhase + ''
        # Install extensions
        for ext in ${builtins.concatStringsSep " " ghidraExtensions}
        do
          echo "ext $ext"
          unzip $ext -d $out/lib/ghidra/Ghidra/Extensions
        done
      '';
    }))

  ];
}