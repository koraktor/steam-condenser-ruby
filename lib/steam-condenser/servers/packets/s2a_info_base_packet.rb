# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'

module SteamCondenser::Servers::Packets

  # This module implements methods to generate and access server information
  # from S2A_INFO_DETAILED and S2A_INFO2 response packets
  #
  # @author Sebastian Staudt
  # @see S2A_INFO_DETAILED_Packet
  # @see S2A_INFO2_Packet
  class S2A_INFO_BasePacket < BasePacket

    # Returns the information provided by the server
    #
    # @return [Hash<String, Object>] The information provided by the server
    def info
      @info ||= {}
    end

  end
end
