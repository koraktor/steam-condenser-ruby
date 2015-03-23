# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/packets/rcon/base_packet'

module SteamCondenser::Servers::Packets
  module RCON

    # This packet class represents a HEADER request sent to a Source
    # server
    #
    # It is used to authenticate the client for RCON communication.
    #
    # @author Sebastian Staudt
    # @see SourceServer#rcon_auth
    class RCONAuthRequest < BasePacket

      # Header for authentication requests
      HEADER = 3

      # Creates a RCON authentication request for the given request ID and RCON
      # password
      #
      # @param [Fixnum] request_id The request ID of the RCON connection
      # @param [String] rcon_password The RCON password of the server
      def initialize(request_id, rcon_password)
        super request_id, HEADER, rcon_password
      end

    end
  end
end
