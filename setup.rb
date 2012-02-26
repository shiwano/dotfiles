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

link ".vimrc", "~/.vimrc"
link ".gvimrc", "~/.gvimrc"
link ".vim", "~/.vim"

link ".zshrc", "~/.zshrc"

link ".screenrc", "~/.screenrc"
link ".tmux.conf", "~/.tmux.conf"

link ".gitconfig", "~/.gitconfig"
link ".gitignore", "~/.gitignore"

unless "~/.vim/bundle/vundle".expand.exist?
  sh "git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle"
  sh "vim -c BundleInstall -c quit"
end

unless "~/dotfiles/refs/rubyrefm".expand.exist?
  "refs".expand.mkpath
  sh "wget http://doc.okkez.net/archives/201107/ruby-refm-1.9.2-dynamic-20110729.zip"
  sh "unzip ruby-refm-1.9.2-dynamic-20110729.zip"
  sh "rm ruby-refm-1.9.2-dynamic-20110729.zip"
  sh "mv ruby-refm-1.9.2-dynamic-20110729 ~/dotfiles/refs/rubyrefm"
end
