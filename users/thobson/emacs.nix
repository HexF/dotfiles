{config, lib, pkgs, ...}:
let
    myEmacsPkg = (pkgs.emacs.override {
        withGTK3 = true;
        withGTK2 = false;
    });
    myEmacs = (pkgs.emacsPackagesGen myEmacsPkg).emacsWithPackages(epkgs: (
        with epkgs.melpaStablePackages; [ 
            magit          # ; Integrate git <C-x g>
            zerodark-theme # ; Nicolas' theme
        ]) ++ (with epkgs.melpaPackages; [ 
            #undo-tree      # ; <C-x u> to show the undo tree
            #zoom-frm       # ; increase/decrease font size for all buffers %lt;C-x C-+>
        ]) ++ (with epkgs.elpaPackages; [ 
            #auctex         # ; LaTeX mode
            beacon         # ; highlight my cursor when scrolling
            nameless       # ; hide current package name everywhere in elisp code
        ]) ++ [
            pkgs.notmuch   # From main packages set 
        ]
    );
in
    {
        programs.emacs = {
            enable = true;
            package = myEmacs;

        };

        services.emacs.enable = true;
        
    }