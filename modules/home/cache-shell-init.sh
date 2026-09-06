#!/usr/bin/env bash
set -euo pipefail

zsh_bin=$1
cache_file=$2
shift 2

mkdir -p "${cache_file%/*}"
staging_dir=$(mktemp -d "$cache_file.XXXXXX")
trap 'rm -rf -- "$staging_dir"' EXIT
# zsh identifies compiled scripts by basename, so preserve it while staging.
staged_file="$staging_dir/${cache_file##*/}"
"$@" >"$staged_file"
# shellcheck disable=SC2016 # The child zsh expands its own positional parameter.
"$zsh_bin" -fc 'zcompile -R "$1"' -- "$staged_file"

# Avoid loading the old bytecode if both versions have the same timestamp.
rm -f -- "$cache_file.zwc"
mv -f -- "$staged_file" "$cache_file"
mv -f -- "$staged_file.zwc" "$cache_file.zwc"
