#!/usr/bin/env bash
set -e

# Change this to the path of your real executable, or accept it as $1.
# e.g. exe="/usr/local/bin/openvpn"
exe="/bin/openvpn_exporter"

declare -a new_args

while [[ $# -gt 0 ]]; do
  case "$1" in
    -openvpn.status_paths)
      new_args+=( "$1" )
      shift

      # 1) Collect all following args that don't start with '-'
      patterns=()
      while [[ $# -gt 0 && ! $1 == -* ]]; do
        patterns+=( "$1" )
        shift
      done

      # 2) Expand each pattern (in case it's still a glob)
      shopt -s nullglob
      files=()
      for pat in "${patterns[@]}"; do
        files+=( $pat )
      done
      shopt -u nullglob

      # 3) Join with commas
      if (( ${#files[@]} )); then
        printf -v joined '%s,' "${files[@]}"
        joined=${joined%,}
      else
        echo "Warning: no files match '${patterns[*]}'" >&2
        joined=""
      fi

      new_args+=( "$joined" )
      ;;
    *)
      new_args+=( "$1" )
      shift
      ;;
  esac
done

exec "$exe" "${new_args[@]}"
