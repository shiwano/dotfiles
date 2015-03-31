#!/bin/bash -u

readonly LOCAL_BIN_DIR=$HOME/bin
readonly DOTFILES_DIR=$HOME/dotfiles

function topic {
  echo -en "\033[1;30m"
  echo "$*"
  echo -en "\033[0m"
}

topic 'Clone the repository'

if [ -d $DOTFILES_DIR ]; then
  echo 'dotfiles repository already exists'
else
  git clone --recursive https://github.com/shiwano/dotfiles.git $DOTFILES_DIR
fi

topic 'Setup local bin files'

mkdir -p $LOCAL_BIN_DIR

for bin in `find $DOTFILES_DIR/bin -type f -maxdepth 1`; do
  echo 'Linking' $bin '->' $LOCAL_BIN_DIR
  ln -sf $bin $LOCAL_BIN_DIR
done

topic 'Setup dotfiles'

for dotfile in `find $DOTFILES_DIR -maxdepth 1 -type f -name 'dot.*' -regex '.*[^(example)]$'`; do
  dest=$HOME/`basename $dotfile | sed -e 's/^dot\./\./'`
  echo 'Linking' $dotfile '->' $dest
  ln -sf $dotfile $dest
done

for dotfile in `find $DOTFILES_DIR -maxdepth 1 -type d -name 'dot.*'`; do
  dest=$HOME/`basename $dotfile | sed -e 's/^dot\./\./'`
  echo 'Linking' $dotfile '->' $dest
  ln -sfn $dotfile $dest
done

for dotfile in `find $DOTFILES_DIR -maxdepth 1 -type f -name 'dot.*.example'`; do
  dest=$HOME/`basename $dotfile | sed -e 's/^dot\./\./' | sed -e 's/\.example//'`
  if [ ! -f $dest ]; then
    echo 'Copying' $dotfile '->' $dest
    cp $dotfile $dest
  fi
done

topic 'Setup Vim plugins'

if [ -d $DOTFILES_DIR/dot.vim/bundle/neobundle.vim ]; then
  echo 'Vim plugins are already installed'
else
  if type vim > /dev/null 2>&1; then
    echo 'Installing Vim plugins'
    git clone --recursive git://github.com/Shougo/neobundle.vim $DOTFILES_DIR/dot.vim/bundle/neobundle.vim
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
    $DOTFILES_DIR/brew.sh
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
