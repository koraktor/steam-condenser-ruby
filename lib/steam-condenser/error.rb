# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam-condenser'

# This error class is used as a base class for all errors related to Steam
# Condenser's operation
#
# @author Sebastian Staudt
class SteamCondenser::Error < StandardError

  # Returns the exception that caused this error
  #
  # @return [Exception] The exception that caused this error
  attr_reader :cause

  # Creates a new `Error` instance
  #
  # @param [String] message The message to attach to the error
  # @param [Exception] cause The exception that caused this error
  def initialize(message, cause = nil)
    super message
    @cause = cause
  end

end
