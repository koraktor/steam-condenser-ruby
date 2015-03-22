# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'

module SteamCondenser::Servers::Packets

  # This packet class represents a S2C_CHALLENGE response replied by a game
  # server
  #
  # It is used to provide a challenge number to a client requesting information
  # from the game server.
  #
  # @author Sebastian Staudt
  # @see GameServer#update_challenge_number
  class S2C_CHALLENGE_Packet

    include BasePacket

    HEADER = 0x41
    # Creates a new S2C_CHALLENGE response object based on the given data
    #
    # @param [String] challenge_number The raw packet data replied from the
    #        server
    def initialize(challenge_number)
      super HEADER, challenge_number
    end

    # Returns the challenge number received from the game server
    #
    # @return [Fixnum] The challenge number provided by the game server
    def challenge_number
      @content_data.rewind
      @content_data.long
    end
  end
end
