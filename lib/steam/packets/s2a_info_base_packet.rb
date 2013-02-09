# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam/packets/steam_packet'

# This module implements methods to generate and access server information from
# S2A_INFO_DETAILED and S2A_INFO2 response packets
#
# @author Sebastian Staudt
# @see S2A_INFO_DETAILED_Packet
# @see S2A_INFO2_Packet
module S2A_INFO_BasePacket

  include SteamPacket

  # Returns the information provided by the server
  #
  # @return [Hash<String, Object>] The information provided by the server
  def info
    @info ||= {}
  end

end
