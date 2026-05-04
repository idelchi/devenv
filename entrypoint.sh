#!/usr/bin/env bash
set -euo pipefail

uid="$(id -u)"

export HOME="/tmp/home/${uid}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

export GOPATH="${GOPATH:-${HOME}/go}"
export GOCACHE="${GOCACHE:-${XDG_CACHE_HOME}/go-build}"
export RUSTUP_HOME="${RUSTUP_HOME:-/usr/local/rustup}"
export CARGO_HOME="${CARGO_HOME:-${HOME}/.cargo}"

export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-${XDG_CACHE_HOME}/npm}"
export MYPY_CACHE_DIR="${MYPY_CACHE_DIR:-${XDG_CACHE_HOME}/mypy}"
export RUFF_CACHE_DIR="${RUFF_CACHE_DIR:-${XDG_CACHE_HOME}/ruff}"
export TASK_TEMP_DIR="${TASK_TEMP_DIR:-${XDG_CACHE_HOME}/task}"

mkdir -p \
  "${HOME}" \
  "${XDG_CONFIG_HOME}" \
  "${XDG_DATA_HOME}" \
  "${XDG_STATE_HOME}" \
  "${XDG_CACHE_HOME}" \
  "${GOPATH}" \
  "${GOCACHE}" \
  "${CARGO_HOME}" \
  "${NPM_CONFIG_CACHE}" \
  "${MYPY_CACHE_DIR}" \
  "${RUFF_CACHE_DIR}" \
  "${TASK_TEMP_DIR}"

exec "$@"
