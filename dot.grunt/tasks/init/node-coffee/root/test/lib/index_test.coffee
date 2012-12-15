helper = require '../test_helper'

lib = helper.require "index"

describe 'lib', ->
  describe '#awesome', ->
    it 'should return the awesome string', ->
      expect(lib.awesome()).to.be.equal 'nyan'
