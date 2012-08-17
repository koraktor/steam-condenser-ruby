# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/error/packet_format'
require 'steam-condenser/servers/sockets/base_socket'

module SteamCondenser::Servers::Sockets

  # This class represents a socket used to communicate with master servers
  #
  # @author Sebastian Staudt
  class MasterServerSocket

    include BaseSocket

    # Reads a single packet from the socket
    #
    # @raise [Error::PacketFormat] if the packet has the wrong format
    # @return [SteamPacket] The packet replied from the server
    def reply
      receive_packet 1500

      unless @buffer.long == 0xFFFFFFFF
        raise SteamCondenser::Error::PacketFormat, 'Master query response has wrong packet header.'
      end

      packet = SteamPacketFactory.packet_from_data @buffer.get

      puts "Got reply of type \"#{packet.class.to_s}\"." if $DEBUG

      packet
    end

  end
end
