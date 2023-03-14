#!/bin/bash

folder::clear() {
  echo "  - contains no $2"
  echo "  - removing folder"
  dir=$1
  rm -rf "${dir:?}"/
}

parse::args() {
  shift $((OPTIND - 1))
  args=("$@")
  N=${#args[@]}

  if [[ ${N} -eq "0" ]]; then
    echo "<packages> required"
    usage 1
  fi
}

jobs::print() {
  echo "Jobs started:"
  jobs -l
}

jobs::exit() {
  j=$(jobs -p)
  if [[ -n ${j} ]]; then
    echo "unwinding background processes..."
    for pid in ${j}; do kill "${pid}"; done
  fi
  echo "exiting"
  exit 0
}

# https://google.github.io/styleguide/shellguide.html#s7-naming-conventions
