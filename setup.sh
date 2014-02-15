#!/bin/bash

UNAME=`uname`
LOCAL_BIN_DIR=$HOME/bin
DOTFILES_DIR=$HOME/dotfiles

topic() {
  echo -en "\033[1;30m"
  echo "$*"
  echo -en "\033[0m"
}

topic 'Clone the repository'

if [ -d $DOTFILES_DIR ]; then
  echo 'dotfiles repository already exists'
else
  git clone --recursive git@github.com:shiwano/dotfiles.git $DOTFILES_DIR
fi

topic 'Setup local bin files'

if [ ! -d $LOCAL_BIN_DIR ]; then
  mkdir $LOCAL_BIN_DIR
fi

for BIN in `find $DOTFILES_DIR/bin -type f -maxdepth 1`; do
  echo 'Linking' $BIN '->' $LOCAL_BIN_DIR
  ln -sf $BIN $LOCAL_BIN_DIR
done

topic 'Setup dotfiles'

for DOTFILE in `find $DOTFILES_DIR -type f -maxdepth 1 -name 'dot.*' -regex '.*[^(example)]$'`; do
  DEST=$HOME/`basename $DOTFILE | sed -e 's/^dot\./\./'`
  echo 'Linking' $DOTFILE '->' $DEST
  ln -sf $DOTFILE $DEST
done

for DOTFILE in `find $DOTFILES_DIR -type f -maxdepth 1 -name 'dot.*.example'`; do
  DEST=$HOME/`basename $DOTFILE | sed -e 's/^dot\./\./' | sed -e 's/\.example//'`
  if [ ! -f $DEST ]; then
    echo 'Copying' $DOTFILE '->' $DEST
    cp $DOTFILE $DEST
  fi
done

topic 'Setup Vim plugins'

if [ -d $DOTFILES_DIR/dot.vim/bundle/neobundle.vim ]; then
  echo 'Vim plugins already exist'
else
  if type vim > /dev/null 2>&1; then
    echo 'Installing Vim plugins'
    git clone --recursive git://github.com/Shougo/neobundle.vim $DOTFILES_DIR/dot.vim/bundle/neobundle.vim
    vim -c NeoBundleInstall -c quit
  fi
fi

topic 'Setup Homebrew'

if [ $UNAME = "Darwin" ]; then
  if type brew > /dev/null 2>&1; then
    echo 'Homebrew is already installed'
  else
    echo 'Installing Homebrew'
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew bundle $DOTFILES_DIR
  fi
else
  echo 'This environment does not need homebrew'
fi

topic 'Setup anyenv'

if type anyenv > /dev/null 2>&1; then
  echo 'anyenv is already installed'
else
  echo 'Installing anyenv'
  git clone https://github.com/riywo/anyenv $HOME/.anyenv
fi
