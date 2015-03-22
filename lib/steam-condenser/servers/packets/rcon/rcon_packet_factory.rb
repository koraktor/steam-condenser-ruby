# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'core_ext/stringio'
require 'steam-condenser/servers//packets/steam_packet_factory'
require 'steam-condenser/servers//packets/rcon/rcon_auth_response'
require 'steam-condenser/servers/packets/rcon/rcon_exec_response'
require 'steam-condenser/error/packet_format'

module SteamCondenser::Servers::Packets::RCON

  # This module provides functionality to handle raw packet data for Source
  # RCON
  #
  # It's is used to transform data bytes into packet objects for RCON
  # communication with Source servers.
  #
  # @author Sebastian Staudt
  # @see BasePacket
  module RCONPacketFactory

    # Creates a new packet object based on the header byte of the given raw
    # data
    #
    # @param [String] raw_data The raw data of the packet
    # @raise [Error::PacketFormat] if the packet header is not recognized
    # @return [BasePacket] The packet object generated from the packet data
    def self.packet_from_data(raw_data)
      byte_buffer = StringIO.new raw_data

      request_id = byte_buffer.long
      header = byte_buffer.long
      data = byte_buffer.cstring

      case header
        when RCONAuthResponse::HEADER
          RCONAuthResponse.new(request_id)
        when RCONExecResponse::HEADER
          RCONExecResponse.new(request_id, data)
        else
          raise SteamCondenser::Error::PacketFormat, "Unknown packet with header #{header.to_s(16)} received."
      end
    end

  end
end
