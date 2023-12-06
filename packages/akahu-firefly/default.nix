{lib, buildNpmPackage, fetchFromGitHub}: 
buildNpmPackage rec {
  pname = "akahu-firefly";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hexf";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-XfEXJZYIfRlyDtHbeuf3lrU1FGApRWNGKC8x8vQKwSE=";
  };

  npmDepsHash = "sha256-e9GbRYxzHvgUEt9TNSQQI257wcEUITAnx3du6PPtV7c=";
  dontNpmBuild = true;
}