#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'
include FileUtils::Verbose

class String
  def expand
    result = Pathname.new(self).expand_path
    result.parent.mkpath unless result.parent.exist?
    result
  end
end

def put_file(src, dst)
  src = Pathname.new(src).expand_path
  dst = Pathname.new(dst).expand_path
  dst.parent.mkpath unless dst.parent.exist?

  if src.extname == '.example'
    dst = Pathname.new dst.to_s.gsub(/\.example$/, '')
    return puts "#{dst} already exists!" if dst.exist?
    cp src.to_s, dst.to_s
  else
    remove_file dst if dst.directory? and dst.symlink?
    ln_sf src.to_s, dst.to_s
  end
end

def puts_separator(string)
  puts "\n#{'#' * 25} [#{string}] #{'#' * 25}"
end

def clone_repository
  cd '~'.expand
  return puts 'dotfiles repository already exists!' if 'dotfiles'.expand.exist?
  system 'git clone git://github.com/shiwano/dotfiles.git dotfiles'
end

def setup_bin
  '~/bin'.expand.mkpath unless '~/bin'.expand.exist?
  cd '~/dotfiles'.expand
  Dir['bin/*'].each{ |path| put_file path, '~/bin' }
end

def setup_dotfiles
  cd '~/dotfiles'.expand
  Dir['dot\.*'].each { |f| put_file f, '~/' + f.sub('dot', '') }
end

def setup_vim_plugins
  cd '~/dotfiles'.expand
  return puts "vim plugins already exists!" if 'dot.vim/bundle/neobundle.vim'.expand.exist?
  system 'git clone https://github.com/Shougo/neobundle.vim dot.vim/bundle/neobundle.vim'
  system 'vim -c NeoBundleInstall -c quit'
  cp 'settings/vimproc/post-merge'.expand, 'dot.vim/bundle/vimproc/.git/hooks/post-merge'.expand
  chmod 0755, 'dot.vim/bundle/vimproc/.git/hooks/post-merge'.expand
  system 'dot.vim/bundle/vimproc/.git/hooks/post-merge'
end

def download_ruby_ref
  cd '~/dotfiles'.expand
  return puts 'ruby ref already exists!' if 'refs/rubyrefm'.expand.exist?
  system 'wget http://doc.okkez.net/archives/201208/ruby-refm-1.9.3-dynamic-20120829.zip'
  system 'unzip ruby-refm-1.9.3-dynamic-20120829.zip'
  rm 'ruby-refm-1.9.3-dynamic-20120829.zip'.expand
  mv 'ruby-refm-1.9.3-dynamic-20120829'.expand, 'refs/rubyrefm'.expand
end

def download_jquery_ref
  cd '~/dotfiles'.expand
  return puts 'jquery ref already exists!' if '~/dotfiles/refs/jqapi'.expand.exist?
  system 'wget http://jqapi.com/jqapi.zip'
  system 'unzip jqapi.zip -d jqapi'
  rm 'jqapi.zip'.expand
  mv 'jqapi'.expand, 'refs/jqapi'.expand
end

def download_javascript_ref
  cd '~/dotfiles'.expand
  return puts 'javascript ref already exists!' if '~/dotfiles/refs/jsref'.expand.exist?
  system 'git clone https://github.com/tokuhirom/jsref.git refs/jsref'
end

if $0 == __FILE__
  puts_separator 'git repo'
  clone_repository
  puts_separator 'bin'
  setup_bin
  puts_separator 'dotfiles'
  setup_dotfiles
  puts_separator 'vim plugins'
  setup_vim_plugins
  puts_separator 'referencies'
  download_ruby_ref
  download_jquery_ref
  download_javascript_ref
end
