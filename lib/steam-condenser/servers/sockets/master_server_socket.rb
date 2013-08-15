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
    include SteamCondenser::Logging

    # Reads a single packet from the socket
    #
    # @raise [Error::PacketFormat] if the packet has the wrong format
    # @return [BasePacket] The packet replied from the server
    def reply
      receive_packet 1500

      unless @buffer.long == 0xFFFFFFFF
        raise SteamCondenser::Error::PacketFormat, 'Master query response has wrong packet header.'
      end

      packet = SteamCondenser::Servers::Packets::SteamPacketFactory.packet_from_data @buffer.get

      log.debug "Got reply of type \"#{packet.class.to_s}\"."

      packet
    end

  end
end
