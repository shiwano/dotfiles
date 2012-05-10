#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'
include FileUtils::Verbose

class String
  def expand
    ret = Pathname.new(self).expand_path
    ret.parent.mkpath unless ret.parent.exist?
    ret
  end
end

def link(src, dst)
  src = Pathname.new(src).expand_path
  dst = Pathname.new(dst).expand_path
  dst.parent.mkpath unless dst.parent.exist?
  remove_file dst if dst.directory? and dst.symlink?
  ln_sf src.to_s, dst.to_s
end

cd '~'.expand
'bin'.expand.mkpath unless 'bin'.expand.exist?
system 'git clone git@github.com:shiwano/dotfiles.git dotfiles' unless 'dotfiles'.expand.exist?
cd 'dotfiles'

Dir['bin/*'].each do |f|
  link f, '~/bin'
end

Dir['./dot\.*'].each do |f|
  link f, '~/' + f.sub('dot', '')
end

unless '~/.vim/bundle/vundle'.expand.exist?
  system 'git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle'
  system 'vim -c BundleInstall -c quit'
end

unless '~/dotfiles/refs/rubyrefm'.expand.exist?
  system 'wget http://doc.okkez.net/archives/201107/ruby-refm-1.9.2-dynamic-20110729.zip'
  system 'unzip ruby-refm-1.9.2-dynamic-20110729.zip'
  system 'rm ruby-refm-1.9.2-dynamic-20110729.zip'
  system 'mv ruby-refm-1.9.2-dynamic-20110729 ~/dotfiles/refs/rubyrefm'
end

unless '~/dotfiles/refs/jqapi'.expand.exist?
  system 'wget http://jqapi.com/jqapi-latest.zip'
  system 'unzip jqapi-latest.zip -d jqapi'
  system 'rm jqapi-latest.zip'
  system 'mv jqapi ~/dotfiles/refs/jqapi'
end

unless '~/dotfiles/refs/jsref'.expand.exist?
  system 'git clone https://github.com/tokuhirom/jsref.git ~/dotfiles/refs/jsref'
end
