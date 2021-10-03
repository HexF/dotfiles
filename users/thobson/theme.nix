rec {
    color = [
        "#2e3436"
        "#cc0000"
        "#4e9a06"
        "#c4a000"
        "#3465a4"
        "#75507b"
        "#06989a"
        "#d3d7cf"
        "#555753"
        "#ef2929"
        "#8ae234"
        "#fce94f"
        "#729fcf"
        "#ad7fa8"
        "#34e2e2"
        "#eeeeec"
    ];
    foreground = "#dedede";
    background = "#2b2b2b";
    accent = builtins.elemAt color 4;
    # xcolors: tartan

    font = {
        general = {
            family = "JetBrainsMono Nerd Font Mono";
        };
        terminal = {
            family = "JetBrainsMono Nerd Font Mono";
            size = 11;
        };
    };
}

