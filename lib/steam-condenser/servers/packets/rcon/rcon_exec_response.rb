# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/packets/rcon/base_packet'

module SteamCondenser::Servers::Packets::RCON

  # This packet class represents a HEADER packet sent by a
  # Source server
  #
  # It is used to transport the output of a command from the server to the
  # client which requested the command execution.
  #
  # @author Sebastian Staudt
  # @see SourceServer#rcon_exec
  class RCONExecResponse < BasePacket

     # Header for packets with the output of a command execution
     HEADER = 0

    # Creates a RCON command response for the given request ID and command
    # output
    #
    # @param [Fixnum] request_id The request ID of the RCON connection
    # @param [String] command_response The output of the command executed on
    #        the server
    def initialize(request_id, command_response)
      super request_id, HEADER, command_response
    end

    # Returns the output of the command execution
    #
    # @return [String] The output of the command
    def response
      @content_data.string[0..-3]
    end

  end
end
