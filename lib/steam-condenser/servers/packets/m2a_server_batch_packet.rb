# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam-condenser/error/packet_format'
require 'steam-condenser/servers/packets/base_packet'

module SteamCondenser::Servers::Packets

  # This packet class represents a M2A_SERVER_BATCH response replied by a master
  # server
  #
  # It contains a list of IP addresses and ports of game servers matching the
  # requested criteria.
  #
  # @author Sebastian Staudt
  # @see MasterServer#servers
  class M2A_SERVER_BATCH_Packet < BasePacket

    HEADER = 0x66

    # Returns the list of servers returned from the server in this packet
    #
    # @return [Array<String>] An array of server addresses (i.e. IP addresses +
    #         port numbers)
    attr_reader :servers

    # Creates a new M2A_SERVER_BATCH response object based on the given data
    #
    # @param [String] data The raw packet data replied from the server
    # @raise [Error::PacketFormat] if the packet data is not well formatted
    def initialize(data)
      super HEADER, data

      unless @content_data.getbyte == 0x0A
        raise SteamCondenser::Error::PacketFormat, 'Master query response is missing additional 0x0A byte.'
      end

      @servers = []

      begin
        first_octet = @content_data.getbyte
        second_octet = @content_data.getbyte
        third_octet = @content_data.getbyte
        fourth_octet = @content_data.getbyte
        port_number = @content_data.short
        port_number = ((port_number & 0xFF) << 8) + (port_number >> 8)

        @servers << "#{first_octet}.#{second_octet}.#{third_octet}.#{fourth_octet}:#{port_number}"
      end while @content_data.remaining > 0
    end

  end
end
