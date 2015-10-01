#!/bin/bash -eu

# Make sure using latest Homebrew
brew update

# Update already-installed formula (takes too much time, I will do it manually later)
# brew upgrade

# Add Repository
brew tap homebrew/versions
brew tap homebrew/binary
brew tap caskroom/versions
brew tap shiwano/formulas

# Packages
brew install caskroom/cask/brew-cask
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
brew install subversion17 --with-unicode-path
brew install md5sha1sum
brew install hub
brew install peco
brew install mercurial
brew install google-japanese-ime
brew install mysql
brew install android-sdk
brew install ant
brew install musta
brew install misakura

# .dmg
brew cask install alfred
brew cask install google-chrome
brew cask install firefox
brew cask install iterm2
brew cask install xtrafinder
brew cask install appcleaner
brew cask install dropbox
brew cask install skype
brew cask install jeromelebel-mongohub
brew cask install keepassx
brew cask install virtualbox
brew cask install vagrant
brew cask install simple-comic
brew cask install growlnotify
brew cask install quicklook-csv
brew cask install quicklook-json
brew cask install webpquicklook
brew cask install sequel-pro
brew cask install libreoffice
brew cask install macvim-kaoriya
brew cask install trailer
brew cask install tiled
brew cask install mplayerx
brew cask install steam
brew cask install heroku-toolbelt
brew cask install licecap
brew cask install karabiner
brew cask install xamarin-studio
brew cask install mono-mdk
brew cask install qlmarkdown

# Remove outdated versions
brew cleanup
brew cask cleanup
