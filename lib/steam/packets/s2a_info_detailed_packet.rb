# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam/packets/s2a_info_base_packet'

# This class represents a S2A_INFO_DETAILED response packet sent by a GoldSrc
# server
#
# @author Sebastian Staudt
# @deprecated Only outdated GoldSrc servers (before 10/24/2008) use this
#             format. Newer ones use the same format as Source servers now (see
#             {S2A_INFO2_Packet}).
# @see GameServer#update_server_info
module SteamCondenser
  class S2A_INFO_DETAILED_Packet

    include S2A_INFO_BasePacket

    # Creates a new S2A_INFO_DETAILED response object based on the given data
    #
    # @param [String] data The raw packet data replied from the server
    # @see S2A_INFO_BasePacket#generate_info_hash
    def initialize(data)
      super S2A_INFO_DETAILED_HEADER, data

      info.merge!({
        :game_ip => @content_data.cstring,
        :server_name => @content_data.cstring,
        :map_name => @content_data.cstring,
        :game_directory => @content_data.cstring,
        :game_description => @content_data.cstring,
        :number_of_players => @content_data.getbyte,
        :max_players => @content_data.getbyte,
        :network_version => @content_data.getbyte,
        :dedicated => @content_data.getc,
        :operating_system => @content_data.getc,
        :password_needed => @content_data.getbyte == 1,
        :is_mod => @content_data.getbyte == 1
      })

      if info[:is_mod]
        info[:mod_info] = {
          :url_info => @content_data.cstring,
          :url_dl => @content_data.cstring
        }
        @content_data.getbyte
        if @content_data.remaining == 12
          info[:mod_info].merge!({
            :mod_version => @content_data.long,
            :mod_size => @content_data.long,
            :sv_only => @content_data.getbyte == 1,
            :cl_dll => @content_data.getbyte == 1,
          })
          info[:secure] = @content_data.getbyte == 1
          info[:number_of_bots] = @content_data.getbyte
        end
      else
        info[:secure] = @content_data.getbyte == 1
        info[:number_of_bots] = @content_data.getbyte
      end
    end

  end
end
