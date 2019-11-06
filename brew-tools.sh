#!/bin/bash

set -eu

# Make sure using latest Homebrew
brew update

# Update already-installed formula (takes too much time, I will do it manually later)
# brew upgrade

# Add Repository
brew tap caskroom/cask
brew tap caskroom/versions
brew tap shiwano/formulas
brew tap delphinus/macvim-kaoriya
brew tap cosmo0920/mingw_w64
brew tap mscharley/homebrew

# Packages
brew install zsh
brew install git
brew install the_silver_searcher
brew install reattach-to-user-namespace
brew install lua
brew install ctags
brew install cmake
brew install tmux
brew install coreutils
brew install wget
brew install tree
brew install ack
brew install mcrypt
brew install jpeg
brew install pstree
brew install gnu-sed
brew install curl
brew install openssl
brew install libxml2
brew install imagemagick
brew install lv
brew install nkf
brew install md5sha1sum
brew install hub
brew install peco
brew install mercurial
brew install mysql
brew install android-sdk
brew install ant
brew install watch
brew install musta
brew install misakura
brew install multitail
brew install iproute2mac
brew install clang-format
brew install wireshark --with-qt
brew install mingw-w64
brew install neovim
brew install direnv
brew install --HEAD libimobiledevice
brew install ideviceinstaller
brew install cocoapods
brew install ios-deploy
brew install jq
breq install stern

# .dmg
brew install caskroom/cask/alfred
brew install caskroom/cask/google-chrome
brew install caskroom/cask/firefox
brew install caskroom/cask/iterm2
brew install caskroom/cask/appcleaner
brew install caskroom/cask/dropbox
brew install caskroom/cask/skype
brew install caskroom/cask/jeromelebel-mongohub
brew install caskroom/cask/keepassx
brew install caskroom/cask/virtualbox
brew install caskroom/cask/vagrant
brew install caskroom/cask/growlnotify
brew install caskroom/cask/quicklook-csv
brew install caskroom/cask/quicklook-json
brew install caskroom/cask/webpquicklook
brew install caskroom/cask/sequel-pro
brew install caskroom/cask/libreoffice
brew install caskroom/cask/macvim-kaoriya
brew install caskroom/cask/trailer
brew install caskroom/cask/tiled
brew install caskroom/cask/5kplayer
brew install caskroom/cask/steam
brew install caskroom/cask/heroku-toolbelt
brew install caskroom/cask/licecap
brew install caskroom/cask/mono-mdk
brew install caskroom/cask/elmarkdown
brew install caskroom/cask/rdm
brew install caskroom/cask/wireshark-chmodbpf
brew linkapps wireshark
brew install caskroom/cask/gyazo
brew install caskroom/cask/db-browser-for-sqlite
brew install delphinus/macvim-kaoriya/macvim-kaoriya
brew install caskroom/cask/spectacle
brew install caskroom/cask/cmd-eikana

# Remove outdated versions
brew cleanup