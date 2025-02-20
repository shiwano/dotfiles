#!/bin/bash

function topic {
  echo -en "\033[1;34m"
  echo "$*"
  echo -en "\033[0m"
}

main() {
  set -euo pipefail

  local local_bin_dir=$HOME/bin
  local local_dotconfig_dir=$HOME/.config
  local dotfiles_dir=$HOME/dotfiles

  topic 'Clone the repository'

  if [ -d $dotfiles_dir ]; then
    echo 'dotfiles repository already exists'
  else
    git clone --recursive git@github.com:shiwano/dotfiles.git $dotfiles_dir
  fi

  topic 'Setup bin directory'

  mkdir -p $local_bin_dir

  for bin in $(find $dotfiles_dir/bin -type f -maxdepth 1 -mindepth 1 | grep -v '.DS_Store'); do
    echo 'Linking' $bin '->' $local_bin_dir
    ln -sf $bin $local_bin_dir
  done

  topic 'Setup .config directory'

  mkdir -p $local_dotconfig_dir

  for src in $(find $dotfiles_dir/dot.config -maxdepth 1 -mindepth 1 | grep -v '.DS_Store'); do
    echo 'Linking' $src '->' $local_dotconfig_dir
    ln -sf $src $local_dotconfig_dir
  done

  topic 'Setup dotfiles'

  for dotfile in $(find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name 'dot.*' | grep -v 'example'); do
    local dest="$HOME/$(basename $dotfile | sed -e 's/^dot\./\./')"
    echo 'Linking' $dotfile '->' $dest
    ln -sfn $dotfile $dest
  done

  for dotfile in $(find $dotfiles_dir -maxdepth 1 -mindepth 1 -type f -name 'dot.*.example'); do
    local dest="$HOME/$(basename $dotfile | sed -e 's/^dot\./\./' | sed -e 's/\.example//')"
    if [ ! -f $dest ]; then
      echo 'Copying' $dotfile '->' $dest
      cp $dotfile $dest
    else
      echo 'Already copied' $dotfile '->' $dest
    fi
  done

  topic 'Setup bat themes'

  if command -v bat 2>&1 >/dev/null; then
    cd "$(bat --config-dir)/themes"
    bat cache --build
    cd -
  fi
}

main "$@"
