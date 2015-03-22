# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam-condenser/servers/packets/base_packet'
require 'steam-condenser/error/packet_format'

module SteamCondenser::Servers::Packets

  # This class represents a S2A_PLAYER response sent by a game server
  #
  # It is used to transfer a list of players currently playing on the server.
  #
  # @author Sebastian Staudt
  # @see GameServer#update_player_info
  class S2A_PLAYER_Packet < BasePacket

    HEADER = 0x44

    # Returns the list of active players provided by the server
    #
    # @return [Hash<String, SteamPlayer>] All active players on the server
    attr_reader :player_hash

    # Creates a new S2A_PLAYER response object based on the given data
    #
    # @param [String] content_data The raw packet data sent by the server
    # @raise [Error::PacketFormat] if the packet data is not well formatted
    def initialize(content_data)
      if content_data.nil?
        raise SteamCondenser::Error::PacketFormat, 'Wrong formatted S2A_PLAYER packet.'
      end

      super HEADER, content_data

      @content_data.getbyte
      @player_hash = {}

      while @content_data.remaining > 0
        player_data = @content_data.getbyte, @content_data.cstring, @content_data.signed_long, @content_data.float
        @player_hash[player_data[1]] = SteamCondenser::Servers::SteamPlayer.new(*player_data[0..3])
      end
    end

  end
end
