#!/usr/bin/env ruby
#server.rb

require "webrick"
require 'optparse'

PORT = 8080

opts = OptionParser.new

opts.on("-p", "--port HTTP Server port.", Integer) do |port|
  PORT = port
end

opts.parse!(ARGV)

document_root = ARGV[0] || "./"

srv = WEBrick::HTTPServer.new( :DocumentRoot => document_root,
                               :BindAddress => '127.0.0.1',
                               :Port => PORT
                               )

%w(HUP INT TERM KILL).each {|signal|
  Signal.trap(signal){ srv.shutdown }
}

srv.start
