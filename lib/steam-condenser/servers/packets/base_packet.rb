# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'core_ext/stringio'

module SteamCondenser::Servers

  module Packets

    # This class implements the basic functionality used by most of the packets
    # used in communication with master, Source or GoldSrc servers.
    #
    # @author Sebastian Staudt
    # @see SteamPacketFactory
    class BasePacket

      # Creates a new packet object based on the given data
      #
      # @param [Fixnum] header_data The packet header
      # @param [String] content_data The raw data of the packet
      def initialize(header_data, content_data = '')
        @content_data = StringIO.new content_data.to_s
        @header_data  = header_data
      end

      # Returns the raw data representing this packet
      #
      # @return [String] A string containing the raw data of this request packet
      def to_s
        [0xFF, 0xFF, 0xFF, 0xFF, @header_data, @content_data.string].pack('c5a*')
      end

    end
  end
end
