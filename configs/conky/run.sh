#!/bin/sh

pkill conky

conky --config $HOME/.config/conky/conky.conf --quiet
