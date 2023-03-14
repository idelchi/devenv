#!/bin/bash

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "${DIR}/common.sh"

usage() {
  echo "Usage: $0 [-b] [-b=<build>] [-p=<project>] <packages>"
  echo "	where passing -b runs only benchmarks"
  exit "$1"
}

project=unknown
build=build
bench=false

while getopts "hbp:d:" opt; do
  case ${opt} in
    b) bench=true ;;
    p) project=${OPTARG} ;;
    d) build=${OPTARG} ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done
parse::args "$@"

rm -rf "${build}"/prof

if ${bench}; then
  echo "- Benchmark selected -"
  benchmark="-bench=. -run=Bench"
fi

packages=${args[*]}

echo "- Processing ${N} packages -"
for arg in ${packages}; do
  echo "  + ${arg}"
done

profiles="cpuprofile memprofile trace"
for package in ${packages}; do
  prefix=${project}/
  pkg=${package#"${prefix}"}
  folder=${build}/prof/${pkg}
  mkdir -p "${folder}"
  echo "${pkg}"
  for profile in ${profiles}; do
    file=${folder}/${profile}.out
    binary=${folder}/${pkg##*/}.${profile}.test
    # shellcheck disable=SC2086
    test=$(go test ${benchmark} ./"${pkg}" \
      -"${profile}=${file}" \
      -o="${binary}" \
      -count=1) ||
      {
        echo ${test}
        exit 1
      }
    if [[ ${bench} == true && ${test[*]} != *"Benchmark"* ]]; then
      folder::clear "${folder}" benchmarks
      break
    elif [[ ${test[*]} == *"[no tests to run]"* ]]; then
      folder::clear "${folder}" tests
      break
    fi
    echo "  + ${profile} registered!"
  done
done
