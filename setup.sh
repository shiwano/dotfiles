#!/bin/bash

set -eu

readonly local_bin_dir=$HOME/bin
readonly local_dotconfig_dir=$HOME/.config
readonly dotfiles_dir=$HOME/dotfiles

function topic {
  echo -en "\033[1;30m"
  echo "$*"
  echo -en "\033[0m"
}

topic 'Clone the repository'

if [ -d $dotfiles_dir ]; then
  echo 'dotfiles repository already exists'
else
  git clone --recursive https://github.com/shiwano/dotfiles.git $dotfiles_dir
fi

topic 'Setup bin directory'

mkdir -p $local_bin_dir

for bin in `find $dotfiles_dir/bin -type f -maxdepth 1 -mindepth 1`; do
  echo 'Linking' $bin '->' $local_bin_dir
  ln -sf $bin $local_bin_dir
done

topic 'Setup .config directory'

mkdir -p $local_dotconfig_dir

for src in `find $dotfiles_dir/config -maxdepth 1 -mindepth 1`; do
  dest=$local_dotconfig_dir/`basename $src`
  echo 'Linking' $src '->' $dest
  ln -sfn $src $dest
done

topic 'Setup dotfiles'

for dotfile in `find $dotfiles_dir -maxdepth 1 -mindepth 1 -name 'dot.*' | grep -v 'example'`; do
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

topic 'Setup Vim plugins'

if [ -d $dotfiles_dir/dot.vim/bundle/neobundle.vim ]; then
  echo 'Vim plugins are already installed'
else
  if type vim > /dev/null 2>&1; then
    echo 'Installing Vim plugins'
    git clone --recursive git://github.com/Shougo/neobundle.vim $dotfiles_dir/dot.vim/bundle/neobundle.vim
    vim -c NeoBundleInstall -c quit
  else
    echo 'Not found Vim'
  fi
fi

topic 'Setup Homebrew'

if [ `uname` = "Darwin" ]; then
  if type brew > /dev/null 2>&1; then
    echo 'Homebrew is already installed'
  else
    echo 'Installing Homebrew'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    $dotfiles_dir/brew.sh
  fi
else
  echo 'This environment does not need Homebrew'
fi

topic 'Setup anyenv'

if type anyenv > /dev/null 2>&1; then
  echo 'anyenv is already installed'
else
  echo 'Installing anyenv'
  git clone https://github.com/riywo/anyenv $HOME/.anyenv
  mkdir -p $HOME/.anyenv/plugins
  git clone https://github.com/znz/anyenv-update.git $HOME/.anyenv/plugins/anyenv-update
fi
