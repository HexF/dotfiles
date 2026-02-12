{config, lib, pkgs, inputs, ...}:
{
  imports = [
    ./i3.nix
    ./ctf.nix
    # ./binja.nix
  ];

  home.packages = with pkgs; builtins.filter (x: x != null) [
    unstable.kicad
    prismlauncher
    jdk
    imhex

  ];

}
