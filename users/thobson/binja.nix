{config, lib, pkgs, ...}:
let
  pp = pkgs.python3Packages;
  jfx_bridge = pp.buildPackage rec {
    pname = "jfx-bridge";
    version = "1.0.0";
    propagatedBuildInputs = [];
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "";
    };
  };
  ghidra_bridge = pp.buildPythonPackage rec {
    pname = "ghidra-bridge";
    version = "1.0.0";
    propagatedBuildInputs = [];
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "";
    };
  };
  libbs = pp.buildPythonPackage rec {
    pname = "libbs";
    version = "1.0.0";
    propagatedBuildInputs = [
      pp.toml
      pp.pycparser
      pp.setuptools
      pp.prompt-toolkit
      pp.tqdm
      ghidra_bridge
      pp.psutil
    ];
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "";
    };
  };
  binsync = pp.buildPythonPackage rec {
    pname = "binsync";
    version = "4.0.0";
    propagatedBuildInputs = [
      pp.sortedcontainers
      pp.toml
      pp.gitpython
      pp.filelock
      pp.pycparser
      pp.prompt-toolkit
      pp.tqdm
      libbs
    ];
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "";
    };
  };
in
{
  home.packages = with pkgs; [
    (callPackage ../../packages/binaryninja {})
    (python3.withPackages (python-pkgs: [
      binsync
    ]))
  ];
}