{fetchFromGitHub, python3Packages, python}: 

with python3Packages;

buildPythonPackage rec {
  pname = "swagger_ui_py";
  version = "22.7.13";
  format = "wheel";

  src = fetchPypi rec {
    inherit pname version format;
    sha256 = "sha256-AhTdjab99DocRCXexFN4m0MbbGjLlnNJbIvJchtLpJM=";
    dist = python;
    python = "py3";
  };

  propagatedBuildInputs = [
    jinja2
    pyyaml
  ];

}