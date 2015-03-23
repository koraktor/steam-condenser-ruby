# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'
require 'steam-condenser/servers/packets/request_with_challenge'

module SteamCondenser::Servers::Packets

  # This packet class represents a A2S_PLAYER request send to a game server
  #
  # It is used to request the list of players currently playing on the server.
  #
  # This packet type requires the client to challenge the server in advance,
  # which is done automatically if required.
  #
  # @author Sebastian Staudt
  # @see GameServer#update_player_info
  class A2S_PLAYER_Packet < BasePacket
    include RequestWithChallenge

    HEADER = 0x55

    # Creates a new A2S_PLAYER request object including the challenge number
    #
    # @param [Numeric] challenge_number The challenge number received from the
    #        server
    def initialize(challenge_number = -1)
      super HEADER, challenge_number
    end

  end
end
