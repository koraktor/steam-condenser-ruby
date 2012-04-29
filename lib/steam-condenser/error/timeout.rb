# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/error'

module SteamCondenser

  # This error class indicates that an operation could not be finished within a
  # reasonable amount of time
  #
  # This usually indicates that a server could not be contacted because of
  # network problems.
  #
  # @author Sebastian Staudt
  # @note {SteamSocket.timeout=} allows to set a custom timeout for socket
  #       operations
  class Error::Timeout < Error

    # Creates a new `Error::Timeout` instance
    def initialize
      super 'The operation timed out.'
    end

  end

end
