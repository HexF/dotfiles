{fetchgit, python3Packages, git, nodejs, napalm, ffmpeg, swagger_ui_py, peewee_migrate}: 

let
  frontend = (napalm.buildPackage (
    fetchgit {
      url = "https://github.com/Unmanic/unmanic-frontend.git";
      rev = "HEAD";
      sha256 = "sha256-/o9+Um/Dw1W0AmGFjrgIOE1UkrlPonvqwlCnzcwB1D4=";
    }
  ) {
    npmCommands = [
      "npm install --loglevel verbose --nodedir=${nodejs}/include/node"
      "npm run build:publish"
    ];
  });
in with python3Packages;
buildPythonApplication rec {
    pname = "unmanic";
    version = "0.2.3";

    patches = [
      ./0001-frontend.patch
      ./0002-requirements.patch
    ];

    src = fetchgit {
        url = "https://github.com/Unmanic/unmanic.git";
        rev = "HEAD";
        sha256 = "sha256-ieRN++uWOnErwj34OH7obHtjYwV2cQwL+Swj6toeReY=";
        leaveDotGit = false;
    };

    FRONTEND_DIR = "${frontend}/_napalm-install/dist/spa";

    propagatedBuildInputs = [ 
      schedule
      tornado
      marshmallow
      peewee
      peewee_migrate
      psutil
      requests
      requests_toolbelt
      py-cpuinfo
      watchdog
      inquirer
      ffmpeg
      swagger_ui_py
    ];

    nativeBuildInputs = [git];

    doCheck = false;
    meta = {
        description = "Unmanic transcoding service";
    };
}