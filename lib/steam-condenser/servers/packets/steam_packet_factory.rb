# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'zlib'

require 'steam-condenser/servers/packets/s2a_info_detailed_packet'
require 'steam-condenser/servers/packets/a2s_info_packet'
require 'steam-condenser/servers/packets/s2a_info2_packet'
require 'steam-condenser/servers/packets/a2s_player_packet'
require 'steam-condenser/servers/packets/s2a_player_packet'
require 'steam-condenser/servers/packets/a2s_rules_packet'
require 'steam-condenser/servers/packets/s2a_rules_packet'
require 'steam-condenser/servers/packets/a2s_serverquery_getchallenge_packet'
require 'steam-condenser/servers/packets/s2c_challenge_packet'
require 'steam-condenser/servers/packets/a2m_get_servers_batch2_packet'
require 'steam-condenser/servers/packets/m2a_server_batch_packet'
require 'steam-condenser/servers/packets/rcon/rcon_goldsrc_response'
require 'steam-condenser/error/packet_format'

module SteamCondenser::Servers::Packets

  # This module provides functionality to handle raw packet data, including
  # data split into several UDP / TCP packets and BZIP2 compressed data. It's
  # the main utility to transform data bytes into packet objects.
  #
  # @author Sebastian Staudt
  # @see BasePacket
  module SteamPacketFactory

    # Creates a new packet object based on the header byte of the given raw
    # data
    #
    # @param [String] raw_data The raw data of the packet
    # @raise [Error::PacketFormat] if the packet header is not recognized
    # @return [BasePacket] The packet object generated from the packet data
    def self.packet_from_data(raw_data)
      header = raw_data[0].ord
      data = raw_data[1..-1]

      case header
        when S2A_INFO_DETAILED_Packet::HEADER
          return S2A_INFO_DETAILED_Packet.new(data)
        when A2S_INFO_Packet::HEADER
          return A2S_INFO_Packet.new
        when S2A_INFO2_Packet::HEADER
          return S2A_INFO2_Packet.new(data)
        when A2S_PLAYER_Packet::HEADER
          return A2S_PLAYER_Packet.new
        when S2A_PLAYER_Packet::HEADER
          return S2A_PLAYER_Packet.new(data)
        when A2S_RULES_Packet::HEADER
          return A2S_RULES_Packet
        when S2A_RULES_Packet::HEADER
          return S2A_RULES_Packet.new(data)
        when A2S_SERVERQUERY_GETCHALLENGE_Packet::HEADER
          return A2S_SERVERQUERY_GETCHALLENGE_Packet.new
        when S2C_CHALLENGE_Packet::HEADER
          return S2C_CHALLENGE_Packet.new(data)
        when A2M_GET_SERVERS_BATCH2_Packet::HEADER
          return A2M_GET_SERVERS_BATCH2_Packet.new(data)
        when M2A_SERVER_BATCH_Packet::HEADER
          return M2A_SERVER_BATCH_Packet.new(data)
        when RCON::RCONGoldSrcResponse::CHALLENGE_HEADER,
             RCON::RCONGoldSrcResponse::NO_CHALLENGE_HEADER,
             RCON::RCONGoldSrcResponse::RESPONSE_HEADER
          return RCON::RCONGoldSrcResponse.new(data)
        else
          raise SteamCondenser::Error::PacketFormat, "Unknown packet with header 0x#{header.to_s(16)} received."
      end
    end

    # Reassembles the data of a split and/or compressed packet into a single
    # packet object
    #
    # @param [Array<String>] split_packets An array of packet data
    # @param [Boolean] is_compressed whether the data of this packet is
    #        compressed
    # @param [Fixnum] packet_checksum The CRC32 checksum of the decompressed
    #        packet data
    # @raise [Error::PacketFormat] if the calculated CRC32 checksum does not
    #        match the expected value
    # @return [BasePacket] The reassembled packet
    # @see packet_from_data
    def self.reassemble_packet(split_packets, is_compressed = false, packet_checksum = 0)
      packet_data = split_packets.join ''

      if is_compressed
        begin
          require 'bzip2-ruby'
        rescue LoadError
          raise SteamCondenser::Error, 'The "bzip2-ruby" gem is not installed. Please install it, if you want to query Source servers sending compressed packets.'
        end

        packet_data = Bzip2.decompress packet_data

        unless Zlib.crc32(packet_data) == packet_checksum
          raise SteamCondenser::Error::PacketFormat, 'CRC32 checksum mismatch of uncompressed packet data.'
        end
      end

      packet_from_data packet_data[4..-1]
    end

  end
end
