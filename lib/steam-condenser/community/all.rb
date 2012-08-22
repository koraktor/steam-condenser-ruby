# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'steam-condenser/community'

path = File.dirname __FILE__
files = Dir.glob(File.join(path, '**', '*.rb'))
(files - [__FILE__]).each do |file|
  file = file.sub(/^#{path}\//, '').sub(/\.rb$/, '')
  require "steam-condenser/community/#{file}"
end
