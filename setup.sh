#!/bin/bash

function topic {
  echo -en "\033[0;34m"
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

  for bin in `find $dotfiles_dir/bin -type f -maxdepth 1 -mindepth 1 | grep -v '.DS_Store'`; do
    echo 'Linking' $bin '->' $local_bin_dir
    ln -sf $bin $local_bin_dir
  done

  topic 'Setup .config directory'

  mkdir -p $local_dotconfig_dir

  for src in `find $dotfiles_dir/dot.config -maxdepth 1 -mindepth 1 | grep -v '.DS_Store'`; do
    dest=$local_dotconfig_dir/`basename $src`
    echo 'Linking' $src '->' $dest
    ln -sfn $src $dest
  done

  topic 'Setup dotfiles'

  for dotfile in $(find "$dotfiles_dir" -maxdepth 1 -mindepth 1 -type f -name 'dot.*' | grep -v 'example'); do
    dest=$HOME/`basename $dotfile | sed -e 's/^dot\./\./'`
    echo 'Linking' $dotfile '->' $dest
    ln -sfn $dotfile $dest
  done

  for dotfile in `find $dotfiles_dir -maxdepth 1 -mindepth 1 -type f -name 'dot.*.example'`; do
    dest=$HOME/`basename $dotfile | sed -e 's/^dot\./\./' | sed -e 's/\.example//'`
    if [ ! -f $dest ]; then
      echo 'Copying' $dotfile '->' $dest
      cp $dotfile $dest
    fi
  done
}

main "$@"
