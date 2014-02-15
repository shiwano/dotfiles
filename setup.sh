#!/bin/bash

BIN_DIR=$HOME/bin
DOTFILES_DIR=$HOME/dotfiles

# clone repository
if [ -d $DOTFILES_DIR ]; then
  echo 'dotfiles repository already exists!'
else
  git clone --recursive git@github.com:shiwano/dotfiles.git $DOTFILES_DIR
fi

# setup bin
if [ ! -d $BIN_DIR ]; then
  mkdir $BIN_DIR
fi

for BIN in `find $DOTFILES_DIR/bin -type f -maxdepth 1`; do
  echo 'Linking' $BIN '->' $BIN_DIR
  ln -sf $BIN $BIN_DIR
done

# setup dotfiles
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

# setup vim plugins
if [ -d $DOTFILES_DIR/dot.vim/bundle/neobundle.vim ]; then
  echo 'vim plugins already exist!'
else
  if type vim > /dev/null 2>&1; then
    echo 'Installing Vim plugins'
    git clone --recursive git://github.com/Shougo/neobundle.vim $DOTFILES_DIR/dot.vim/bundle/neobundle.vim
    vim -c NeoBundleInstall -c quit
  fi
fi
