# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'ipaddr'
require 'socket'

require 'core_ext/stringio'
require 'steam-condenser/error/timeout'

module SteamCondenser::Servers

  module Sockets

    # This module implements common functionality for sockets used to connect to
    # game and master servers
    #
    # @author Sebastian Staudt
    module BaseSocket

      # The default socket timeout
      @@timeout = 1000

      # Sets the timeout for socket operations
      #
      # Any request that takes longer than this time will cause a
      # {Error::Timeout}.
      #
      # @param [Fixnum] timeout The amount of milliseconds before a request times
      #        out
      def self.timeout=(timeout)
        @@timeout = timeout
      end

      # Creates a new UDP socket to communicate with the server on the given IP
      # address and port
      #
      # @param [String] ip_address Either the IP address or the DNS name of the
      #        server
      # @param [Fixnum] port The port the server is listening on
      def initialize(ip_address, port = 27015)
        @socket = UDPSocket.new
        @socket.connect ip_address, port
      end

      # Closes the underlying socket
      def close
        @socket.close
      end

      # Reads the given amount of data from the socket and wraps it into the
      # buffer
      #
      # @param [Fixnum] buffer_length The data length to read from the socket
      # @raise [Error::Timeout] if no packet is received on time
      # @return [Fixnum] The number of bytes that have been read from the socket
      # @see StringIO
      def receive_packet(buffer_length = 0)
        if select([@socket], nil, nil, @@timeout / 1000.0).nil?
          raise SteamCondenser::Error::Timeout
        end

        if buffer_length == 0
          @buffer.rewind
        else
          @buffer = StringIO.alloc buffer_length
        end

        begin
          data = @socket.recv @buffer.remaining
        rescue Errno::ECONNRESET
          @socket.close
          raise $!
        end
        bytes_read = @buffer.write data
        @buffer.truncate bytes_read
        @buffer.rewind

        bytes_read
      end

      # Sends the given packet to the server
      #
      # This converts the packet into a byte stream first before writing it to
      # the socket.
      #
      # @param [Packets::BasePacket] data_packet The packet to send to the
      #        server
      # @see Packets::BasePacket#to_s
      def send_packet(data_packet)
        if log.debug?
          packet_class = data_packet.class.name[/[^:]*\z/]
          log.debug "Sending data packet of type \"#{packet_class}\"."
        end

        @socket.send data_packet.to_s, 0
      end

    end
  end
end
