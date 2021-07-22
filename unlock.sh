#!/usr/bin/env bash

echo "$0 [keyfile]"
echo "Unlocks secrets"
echo
echo

git crypt unlock $1 && echo true > unlocked