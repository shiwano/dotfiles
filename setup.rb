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
  system 'git clone --recursive git://github.com/shiwano/dotfiles.git dotfiles'
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
  system 'git clone --recursive git://github.com/Shougo/neobundle.vim dot.vim/bundle/neobundle.vim'
  system 'vim -c NeoBundleInstall -c quit'
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
end
