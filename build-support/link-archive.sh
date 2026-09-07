#!/usr/bin/env bash

set -euo pipefail

output=$1
archive=$2
shift 2

platform=$(uname -s)
library_paths=()
if [[ $platform == Darwin && " $* " == *" -lgmp "* ]]; then
  read -r -a library_paths <<< "$(pkg-config --libs-only-L gmp)"
fi

case $platform in
  Darwin)
    "${CXX:-g++}" -dynamiclib -o "$output" \
      "-Wl,-force_load,$archive" \
      "-Wl,-install_name,@rpath/$output" -Wl,-rpath,@loader_path \
      "${library_paths[@]}" "$@"
    ;;
  *)
    "${CXX:-g++}" -shared -fPIC -o "$output" \
      -Wl,--whole-archive "$archive" -Wl,--no-whole-archive "$@"
    ;;
esac
