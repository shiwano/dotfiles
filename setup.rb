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

Dir['dot\.*'].each do |f|
  link f, '~/' + f.sub('dot', '')
end

unless 'dot.vim/bundle/neobundle.vim'.expand.exist?
  system 'git clone https://github.com/Shougo/neobundle.vim dot.vim/bundle/neobundle.vim'
  system 'vim -c NeoBundleInstall -c quit'
  cp 'settings/vimproc/post-merge'.expand, 'dot.vim/bundle/vimproc/.git/hooks/post-merge'.expand
  chmod 0755, 'dot.vim/bundle/vimproc/.git/hooks/post-merge'.expand
  system 'dot.vim/bundle/vimproc/.git/hooks/post-merge'
end

unless 'refs/rubyrefm'.expand.exist?
  system 'wget http://doc.okkez.net/archives/201107/ruby-refm-1.9.2-dynamic-20110729.zip'
  system 'unzip ruby-refm-1.9.2-dynamic-20110729.zip'
  rm 'ruby-refm-1.9.2-dynamic-20110729.zip'.expand
  mv 'ruby-refm-1.9.2-dynamic-20110729'.expand, 'refs/rubyrefm'.expand
end

unless '~/dotfiles/refs/jqapi'.expand.exist?
  system 'wget http://jqapi.com/jqapi-latest.zip'
  system 'unzip jqapi-latest.zip -d jqapi'
  rm 'jqapi-latest.zip'.expand
  mv 'jqapi'.expand, 'refs/jqapi'.expand
end

unless '~/dotfiles/refs/jsref'.expand.exist?
  system 'git clone https://github.com/tokuhirom/jsref.git refs/jsref'
end
