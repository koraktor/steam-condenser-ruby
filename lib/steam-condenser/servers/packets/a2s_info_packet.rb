# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'
require 'steam-condenser/servers/packets/request_info_with_challenge'

module SteamCondenser::Servers::Packets

  # This packet class class represents a A2S_INFO request send to a game server
  #
  # It will cause the server to send some basic information about itself, e.g.
  # the running game, map and the number of players.
  #
  # @author Sebastian Staudt
  # @see GameServer#update_server_info
  class A2S_INFO_Packet

    include BasePacket
    include RequestInfoWithChallenge

    # Creates a new A2S_INFO request object including the challenge number
    #
    # @param [Numeric] challenge_number The challenge number received from the
    #        server
    def initialize(challenge_number = -1)
      super A2S_INFO_HEADER, challenge_number
    end

  end
end
