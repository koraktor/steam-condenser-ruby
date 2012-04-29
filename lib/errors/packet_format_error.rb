# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'errors/steam_condenser_error'

module SteamCondenser

  # This error class indicates a problem when parsing packet data from the
  # responses received from a game or master server
  #
  # @author Sebastian Staudt
  class PacketFormatError < SteamCondenserError
  end
end
