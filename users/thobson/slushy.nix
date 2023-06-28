{config, lib, pkgs, inputs, ...}:
{
  imports = [
    ./ctf.nix
  ];

  home.packages = with pkgs; builtins.filter (x: x != null) [
    jetbrains.datagrip
    jetbrains.idea-ultimate
  ];

}
