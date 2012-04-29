# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'steam/packets/steam_packet'

module SteamCondenser

  # This class represents a S2A_LOGSTRING packet used to transfer log messages
  #
  # @author Sebastian Staudt
  class S2A_LOGSTRING_Packet

    include SteamPacket

    # Returns the log message contained in this packet
    #
    # @return [String] The log message
    attr_reader :message

    # Creates a new S2A_LOGSTRING object based on the given data
    #
    # @param [String] data The raw packet data sent by the server
    def initialize(data)
      super S2A_LOGSTRING_HEADER, data

      @content_data.getbyte
      @message = @content_data.string
    end

  end
end
