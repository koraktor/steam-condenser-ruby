# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'

module SteamCondenser::Servers::Packets

  # This packet class represents a A2S_SERVERQUERY_GETCHALLENGE request send to
  # a game server
  #
  # It is used to retrieve a challenge number from the game server, which helps
  # to identify the requesting client.
  #
  # @author Sebastian Staudt
  # @see GameServer#update_challenge_number
  class A2S_SERVERQUERY_GETCHALLENGE_Packet

    include BasePacket

    HEADER = 0x57

    # Creates a new A2S_SERVERQUERY_GETCHALLENGE request object
    def initialize
      super HEADER
    end

  end
end
