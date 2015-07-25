# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'core_ext/stringio'
require 'steam-condenser/servers/packets/rcon/rcon_goldsrc_request'
require 'steam-condenser/servers/packets/steam_packet_factory'
require 'steam-condenser/error/rcon_ban'
require 'steam-condenser/error/rcon_no_auth'
require 'steam-condenser/error/timeout'
require 'steam-condenser/servers/sockets/base_socket'

module SteamCondenser::Servers::Sockets

  # This class represents a socket used to communicate with game servers based
  # on the GoldSrc engine (e.g. Half-Life, Counter-Strike)
  #
  # @author Sebastian Staudt
  class GoldSrcSocket

    include BaseSocket

    include SteamCondenser::Logging

    # Creates a new socket to communicate with the server on the given IP
    # address and port
    #
    # @param [String] ipaddress Either the IP address or the DNS name of the
    #        server
    # @param [Fixnum] port_number The port the server is listening on
    # @param [Boolean] is_hltv `true` if the target server is a HTLV instance.
    #        HLTV behaves slightly different for RCON commands, this flag
    #        increases compatibility.
    def initialize(ipaddress, port_number = 27015, is_hltv = false)
      super ipaddress, port_number

      @is_hltv = is_hltv
    end

    # Reads a packet from the socket
    #
    # The Source query protocol specifies a maximum packet size of 1,400 bytes.
    # Bigger packets will be split over several UDP packets. This method
    # reassembles split packets into single packet objects.
    #
    # @return [BasePacket] The packet replied from the server
    def reply
      receive_packet 1400

      if @buffer.long == 0xFFFFFFFE
        split_packets = []
        begin
          request_id = @buffer.long
          packet_number_and_count = @buffer.getbyte
          packet_count = packet_number_and_count & 0xF
          packet_number = (packet_number_and_count >> 4) + 1

          split_packets[packet_number - 1] = @buffer.get

          log.debug "Received packet #{packet_number} of #{packet_count} for request ##{request_id}"

          if split_packets.size < packet_count
            begin
              bytes_read = receive_packet
            rescue SteamCondenser::Error::Timeout
              bytes_read = 0
            end
          else
            bytes_read = 0
          end
        end while bytes_read > 0 && @buffer.long == 0xFFFFFFFE

        packet = SteamCondenser::Servers::Packets::SteamPacketFactory.reassemble_packet(split_packets)
      else
        packet = SteamCondenser::Servers::Packets::SteamPacketFactory.packet_from_data(@buffer.get)
      end

      log.debug "Got reply of type \"#{packet.class.to_s}\"."

      packet
    end

    # Executes the given command on the server via RCON
    #
    # @param [String] password The password to authenticate with the server
    # @param [String] command The command to execute on the server
    # @raise [Error::RCONBan] if the IP of the local machine has been banned on
    #        the game server
    # @raise [Error::RCONNoAuth] if the password is incorrect
    # @return [RCONGoldSrcResponse] The response replied by the server
    # @see #rcon_challenge
    # @see #rcon_send
    def rcon_exec(password, command)
      rcon_challenge if @rcon_challenge.nil? || @is_hltv

      rcon_send "rcon #@rcon_challenge #{password} #{command}"
      if @is_hltv
        begin
          response = reply.response
        rescue SteamCondenser::Error::Timeout
          response = ''
        end
      else
        response = reply.response
      end

      if response.strip == 'Bad rcon_password.'
        raise SteamCondenser::Error::RCONNoAuth
      elsif response.strip == 'You have been banned from this server.'
        raise SteamCondenser::Error::RCONBan
      end

      rcon_send "rcon #@rcon_challenge #{password}"

      begin
        response_part = reply.response
        response << response_part
      end while response_part.size > 0

      response
    end

    # Requests a challenge number from the server to be used for further
    # requests
    #
    # @raise [Error::RCONBan] if the IP of the local machine has been banned on
    #        the game server
    # @see #rcon_send
    def rcon_challenge
      rcon_send 'challenge rcon'
      response = reply.response.strip

      if response.strip == 'You have been banned from this server.'
        raise SteamCondenser::Error::RCONBan
      end

      @rcon_challenge = response[14..-1]
    end

    # Wraps the given command in a RCON request packet and send it to the
    # server
    #
    # @param [String] command The RCON command to send to the server
    def rcon_send(command)
      send SteamCondenser::Servers::Packets::RCON::RCONGoldSrcRequest.new(command)
    end

  end
end
