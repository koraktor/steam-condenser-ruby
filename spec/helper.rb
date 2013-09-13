# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt

require 'rubygems'

require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'steam-condenser'
include SteamCondenser

require 'rspec/autorun'
RSpec.configure do |config|
  config.formatter = :documentation
  config.mock_with :mocha
end

# Reads the contents of a fixture file from `./test/`
#
# @param [String] name The name of the fixtures file
# @return [String] The contents of the file
def fixture(name)
  fixture_io(name).read
end

# Opens a file with fixtures from `./test/`
#
# @param [String] name The name of the fixtures file
# @return [File] The file handle
def fixture_io(name)
  File.open File.join(File.dirname(__FILE__), 'fixtures', name)
end
