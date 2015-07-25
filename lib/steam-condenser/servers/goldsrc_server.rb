# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam-condenser/servers/game_server'
require 'steam-condenser/servers/master_server'
require 'steam-condenser/servers/sockets/goldsrc_socket'

module SteamCondenser

  module Servers

    # This class represents a GoldSrc game server and can be used to query
    # information about and remotely execute commands via RCON on the server
    #
    # A GoldSrc game server is an instance of the Half-Life Dedicated Server
    # (HLDS) running games using Valve's GoldSrc engine, like Half-Life
    # Deathmatch, Counter-Strike 1.6 or Team Fortress Classic.
    #
    # @author Sebastian Staudt
    # @see SourceServer
    class GoldSrcServer

      include GameServer
      include SteamCondenser::Logging

      # Returns a master server instance for the default master server for
      # GoldSrc games
      #
      # @return [MasterServer] The GoldSrc master server
      def self.master
        MasterServer.new *MasterServer::GOLDSRC_MASTER_SERVER
      end

      # Creates a new instance of a GoldSrc server object
      #
      # @param [String] address Either an IP address, a DNS name or one of them
      #        combined with the port number. If a port number is given, e.g.
      #        'server.example.com:27016' it will override the second argument.
      # @param [Fixnum] port The port the server is listening on
      # @raise [Error] if an host name cannot be resolved
      # @param [Boolean] is_hltv HLTV servers need special treatment, so this
      #        is used to determine if the server is a HLTV server
      def initialize(address, port = 27015, is_hltv = false)
        super address, port

        @is_hltv = is_hltv
      end

      # Initializes the socket to communicate with the GoldSrc server
      #
      # @see GoldSrcSocket
      def init_socket
        @socket = Sockets::GoldSrcSocket.new @ip_address, @port, @is_hltv
      end

      # Tries to establish RCON authentication with the server with the given
      # password
      #
      # This will send an empty command that will ensure the given password was
      # correct. If successful, the password is stored for future use.
      #
      # @param [String] password The RCON password of the server
      # @return [Boolean] `true` if authentication was successful
      # @see #rcon_exec
      def rcon_auth(password)
        @rcon_authenticated = true
        @rcon_password = password

        begin
          rcon_exec ''
        rescue Error::RCONNoAuth
          @rcon_password = nil
        end

        @rcon_authenticated
      end

      # Remotely executes a command on the server via RCON
      #
      # @param [String] command The command to execute on the server via RCON
      # @return [String] The output of the executed command
      # @see #rcon_auth
      def rcon_exec(command)
        raise Error::RCONNoAuth unless @rcon_authenticated

        begin
          @socket.rcon_exec(@rcon_password, command).strip
        rescue Error::RCONNoAuth
          @rcon_authenticated = false
          raise
        end
      end

    end
  end
end
