#!/usr/bin/env ruby

require "pathname"
require "fileutils"
include FileUtils::Verbose

class String
  def expand
    ret = Pathname.new(self).expand_path
    ret.parent.mkpath unless ret.parent.exist?
    ret
  end
end

def sh(*args)
  puts args.join(" ")
  system(*args)
end

def link(src, dst)
  puts "#{src} =>\n\t#{dst}"
  src = Pathname.new(src).expand_path
  dst = Pathname.new(dst).expand_path
  dst.parent.mkpath unless dst.parent.exist?
  remove_file dst if dst.symlink?
  remove_file dst if dst.file?
  ln_sf src.to_s, dst.to_s
end


cd "~".expand

if "dotfiles".expand.exist?
  cd "dotfiles"
else
  sh "git clone git@github.com:shiwano/dotfiles.git dotfiles"
  cd "dotfiles"
end

"bin".expand.mkpath

Dir["bin/*"].each do |f|
  link f, "~/bin"
end

link "dot.vimrc", "~/.vimrc"
link "dot.gvimrc", "~/.gvimrc"
link "dot.vim", "~/.vim"
link "dot.zshrc", "~/.zshrc"
link "dot.screenrc", "~/.screenrc"
link "dot.tmux.conf", "~/.tmux.conf"
link "dot.gitconfig", "~/.gitconfig"
link "dot.gitignore", "~/.gitignore"

unless "~/.vim/bundle/vundle".expand.exist?
  sh "git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle"
  sh "vim -c BundleInstall -c quit"
end

unless "~/dotfiles/refs/rubyrefm".expand.exist?
  sh "wget http://doc.okkez.net/archives/201107/ruby-refm-1.9.2-dynamic-20110729.zip"
  sh "unzip ruby-refm-1.9.2-dynamic-20110729.zip"
  sh "rm ruby-refm-1.9.2-dynamic-20110729.zip"
  sh "mv ruby-refm-1.9.2-dynamic-20110729 ~/dotfiles/refs/rubyrefm"
end

unless "~/dotfiles/refs/jqapi".expand.exist?
  sh "wget http://jqapi.com/jqapi-latest.zip"
  sh "unzip jqapi-latest.zip -d jqapi"
  sh "rm jqapi-latest.zip"
  sh "mv jqapi ~/dotfiles/refs/jqapi"
end

unless "~/dotfiles/refs/jsref".expand.exist?
  sh "git clone https://github.com/tokuhirom/jsref.git ~/dotfiles/refs/jsref"
end
