# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2015, Sebastian Staudt

require 'rake/testtask'
require 'rubygems/package_task'
require 'yard'

task :default => :test

Gem::PackageTask.new Gem::Specification.load 'steam-condenser.gemspec' do |pkg|
end

# Rake task for running the test suite
Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.test_files = Dir.glob 'test/**/test_*.rb'
  t.verbose = true
end

# Create a rake task +:doc+ to build the documentation using YARD
YARD::Rake::YardocTask.new do |yardoc|
  yardoc.name    = 'doc'
  yardoc.files   = [ 'lib/steam/community/cacheable.rb', 'lib/**/*.rb', 'LICENSE', 'README.md' ]
  yardoc.options = [ '--private', '--title', 'Steam Condenser — API Documentation' ]
end

# Task for cleaning documentation and package directories
desc 'Clean documentation and package directories'
task :clean do
  FileUtils.rm_rf 'coverage'
  FileUtils.rm_rf 'doc'
  FileUtils.rm_rf 'pkg'
end
