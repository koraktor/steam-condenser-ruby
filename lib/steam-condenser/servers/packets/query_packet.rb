# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2020, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'

module SteamCondenser::Servers::Packets

  # This is used as a wrapper to create padding of request packets to a minimum
  # size of 1200 bytes. This was introduced in November 2020 as a counter-measure
  # to DoS attacks on game servers.
  #
  # @author Sebastian Staudt
  module QueryPacket

    include BasePacket

    # The minimum package size as defined by Valve
    STEAM_GAMESERVER_MIN_CONNECTIONLESS_PACKET_SIZE = 1200

    # Creates a new query packet including data padding
    #
    # @param [Fixnum] header The packet header
    # @param [String] content The raw data of the packet
    def initialize(header, content)
      super header, content.to_s.ljust(STEAM_GAMESERVER_MIN_CONNECTIONLESS_PACKET_SIZE - 5, "\0")
    end

  end
end