#!/usr/bin/env bash

# needroot
if [ $EUID != 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

# clean old files
rm -rf /usr/local

# link lisp library
mkdir -p /usr/local/lib
ln -s "$(pwd)/src/lisplib" /usr/local/lib/lisp

# arm binaries
chmod u+x "$(pwd)/bin/"*

# I'm unclear as to where the include files should live. Adding an -I to CC will not work, it's not enough to get liszt to care about them :/

export PATH="${PATH};$(pwd)/bin"

# rebuild libraries
# - bin in path
# - cd to lisplib
