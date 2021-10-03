#!/usr/bin/env bash

PRIMARY=$1

function i3-workspaces(){
    local inactive_bg="#2b2b2b" #background
    local urgent_bg="#cc0000" # color 1
    local focused_bg="#2e3436" # color 0

    i3-msg -t get_workspaces | jq -c '. | map(
        {
            icon: null,
            text: .name,
            bg: (
                if .focused then "'$urgent_bg'"
                else if .focused then "'$focused_bg'"
                else "'$inactive_bg'" end end
            ),
            fg: "#ffffff",
            click: {
                left: "i3-switch-workspace \(.id)"
            },
            align: "left",
            output: .output,
            order: 0
        })'
}

function make_lemonbar(){
    jq -s 'add | map({
        content: (
            if (.icon != null) then
                "\(.icon) \(.text)"
            else
                "\(.text)"
            end
        ),
        click_handler: .click | (
            if (. == null) then
                ""
            else
                [
                    if .left == null then null else "%{A1:\(.left):}" end,
                    if .middle == null then null else "%{A2:\(.middle):}" end,
                    if .right == null then null else "%{A3:\(.right):}" end,
                    if .scrollup == null then null else "%{A4:\(.scrollup):}" end,
                    if .scrolldown == null then null else "%{A5:\(.scrolldown):}" end
                ] | join("") 
            end
        ),
        click_handler_end: .click | (
            if (. == null) then
                ""
            else
                [
                    if .left == null then null else "%{A}" end,
                    if .middle == null then null else "%{A}" end,
                    if .right == null then null else "%{A}" end,
                    if .scrollup == null then null else "%{A}" end,
                    if .scrolldown == null then null else "%{A}" end
                ] | join("") 
            end
        ),
        bg: .bg,
        fg: .fg,
        align: .align,
        output: .output,
        order: .order
    }) | sort_by(.order) | group_by(.output)| map(group_by(.align)) | map(
        # Output Grouped
        "%{Sn\(.[0][0].output)}" + 
        (
            map(
                # Alignment Grouped
                
                "%{\(
                    if .[0].align == "left" then "l" else
                    if .[0].align == "right" then "r" else
                    "c" end end
                )}" + (
                    reduce .[] as $i (
                        "";
                        . + ([
                            "%{B\($i.bg)}",
                            (if . != "" then "" else null end),
                            "%{F\($i.fg)}",
                            $i.click_handler,
                            $i.content,
                            $i.click_handler_end,
                            "%{R}"
                        ] | join(""))
                    ) + "%{B#00FFFFFF}"
                )
            ) | join("")
        )
    ) | join("")' -r
}

function bar_items(){
    i3-workspaces
}

bar_items | make_lemonbar
