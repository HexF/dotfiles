{config, lib, pkgs, ...}:
let
  pp = pkgs.python3Packages;
  jfx_bridge = pp.buildPythonPackage rec {
    pname = "jfx_bridge";
    version = "1.0.0";
    propagatedBuildInputs = [];
    patchPhase = ''
      sed 's|subprocess.check_output("git describe --tags", shell=True).decode("utf-8").strip()|"${version}"|g' -i setup.py
    '';
    doCheck = false;
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-4pG1H1EL0lh2GUNPlMifDIBZNsSSkkwNkF6SIvopByk=";
    };
  };
  ghidra_bridge = pp.buildPythonPackage rec {
    pname = "ghidra_bridge";
    version = "1.0.0";
    propagatedBuildInputs = [ jfx_bridge ];
    patchPhase = ''
      sed 's|subprocess.check_output("git describe --tags", shell=True).decode("utf-8").strip()|"${version}"|g' -i setup.py
    '';
    doCheck = false;
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-OnvfnIwdx4rNPoz+lknQ6VVOR+FHQ1cwEE7+5jSwHJ0=";
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
    doCheck = false;
    src = pkgs.fetchPypi {
        inherit pname version;
        sha256 = "sha256-5YCEsdIEWWriH9eNyvM/fqrMvkpaBVlpPpQe9vuX/p8=";
    };
  };
  binsync = pp.buildPythonPackage rec {
    pname = "binsync";
    version = "4.0.0";
    format = "pyproject";
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
    patchPhase = ''
      sed 's|decompiler_stubs|stub_files *.png|g' -i MANIFEST.in
    '';
    src = pkgs.fetchFromGitHub {
        owner = "binsync";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-lDH+PjFBG17V4mv4dydAJl2Z1qfLTD9yGPzWThUZ0nM=";
    };
  };
in
{
  home.packages = with pkgs; [
    # (callPackage ../../packages/binaryninja {})
    (python3.withPackages (python-pkgs: [
      binsync
      pp.remote-pdb
    ]))
  ];
}