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

topic 'Setup Vim'

if [ ! -d $HOME/.config/nvim ]; then
  echo 'Linking neovim config'
  mkdir -p $HOME/.config
  ln -sfn $dotfiles_dir/dot.vim $HOME/.config/nvim
  ln -sfn $dotfiles_dir/dot.vimrc $HOME/.config/nvim/init.vim
fi

if [ -f $dotfiles_dir/dot.vim/autoload/plug.vim ]; then
  echo 'vim-plug is already installed'
else
  if type vim > /dev/null 2>&1; then
    echo 'Installing vim-plug'
    curl -fLo $dotfiles_dir/dot.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
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
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
else
  echo 'This environment does not need Homebrew'
fi
