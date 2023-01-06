{fetchFromGitHub, python3Packages}: 

with python3Packages;

buildPythonPackage rec {
  pname = "peewee_migrate";
  version = "1.1.6";

  src = fetchPypi rec {
    inherit pname version;
    sha256 = "sha256-kpHGzTnSFGROvF0u8qQ/kxD5VGrtyCgAFWR8b475JhQ=";
  };

  patches = [
    ./0001-py10.patch
  ];

  propagatedBuildInputs = [
    peewee
    click
    mock
    cached-property
  ];

  nativeBuildInputs = [
    psycopg2
    pytest
  ];

  doCheck = false;
}