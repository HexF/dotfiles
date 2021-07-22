#!/usr/bin/env bash

echo "$0 [keyfile]"
echo "Unlocks secrets"
echo
echo

git crypt unlock $1 && echo -e "true\nDo not commmit this file to the repo" > unlocked