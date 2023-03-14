#!/bin/bash

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "${DIR}/common.sh"

usage() {
  echo "Usage: $0 [-f=<fraction>] [-i=<ip>] [-b=<build>] [-p=<project>] <packages>"
  exit "$1"
}

trap jobs::exit EXIT

ip=localhost
project=unknown
build=build
fraction=0.0

while getopts "hi:p:b:f:" opt; do
  case ${opt} in
    i) ip=${OPTARG} ;;
    f) fraction=${OPTARG} ;;
    p) project=${OPTARG} ;;
    b) build=${OPTARG} ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done
parse::args "$@"

packages=${args[*]}

profiles="cpuprofile memprofile"
port=10000

for package in ${packages}; do
  prefix=${project}/
  pkg=${package#"${prefix}"}

  # Check existence
  binary=${build}/prof/${pkg}/${pkg##*/}.cpuprofile.test
  if [[ ! -f ${binary} ]]; then
    continue
  fi
  echo "serving ${pkg} profile analysis on ports ${port} - $((port + 2)) (${profiles[*]} trace)"
  for profile in ${profiles}; do
    binary=${build}/prof/${pkg}/${pkg##*/}.${profile}.test
    prof=${build}/prof/${pkg}/${profile}.out
    go tool pprof -nodefraction="${fraction}" -http="${ip}:${port}" "${binary}" "${prof}" &>/dev/null &
    ((port++))
  done
  go tool trace -http="${ip}:${port}" "${build}/prof/${pkg}"/trace.out &>/dev/null &
  ((port += 8))
done

echo "press [enter] to quit"
read -r
