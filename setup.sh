#!/bin/sh

set -e # -e: exit on error

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# Make it easier to develop dotfiles in gitpod with gitpod
if [ "${GITPOD_WORKSPACE_CONTEXT_URL}.git" == $(git remote get-url origin) ]; then
  script_dir=${GITPOD_REPO_ROOT}
fi

mkdir -p "$HOME/.local/share/"
ln -s "$script_dir" "$HOME/.local/share/chezmoi"

# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply