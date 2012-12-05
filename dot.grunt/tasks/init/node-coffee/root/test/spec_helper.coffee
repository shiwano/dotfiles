fs = require 'fs'
path = require 'path'

global.expect = require('chai').expect

exports.require = (path) =>
  require "#{__dirname}/../src/#{path}"
