{config, lib, pkgs, ...}:
let
    myEmacs = (pkgs.emacs.override {
        withGTK3 = true;
        withGTK2 = false;
    })
in
{
    services.emacs.enable = true;
    services.emacs.package = myEmacs;
}