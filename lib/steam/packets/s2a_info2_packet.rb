# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam/packets/s2a_info_base_packet'

# This class represents a S2A_INFO_DETAILED response packet sent by a Source or
# GoldSrc server
#
# Out-of-date (before 10/24/2008) GoldSrc servers use an older format (see
# {S2A_INFO_DETAILED_Packet}).
#
# @author Sebastian Staudt
# @see GameServer#update_server_info
class S2A_INFO2_Packet

  include S2A_INFO_BasePacket

  EDF_GAME_ID     = 0x01
  EDF_GAME_PORT   = 0x80
  EDF_SERVER_ID   = 0x10
  EDF_SERVER_TAGS = 0x20
  EDF_SOURCE_TV   = 0x40

  # Creates a new S2A_INFO2 response object based on the given data
  #
  # @param [String] data The raw packet data replied from the server
  # @see S2A_INFO_BasePacket#generate_info_hash
  def initialize(data)
    super S2A_INFO2_HEADER, data

    info.merge!({
      :protocol_version => @content_data.getbyte,
      :server_name => @content_data.cstring,
      :map_name => @content_data.cstring,
      :game_directory => @content_data.cstring,
      :game_description => @content_data.cstring,
      :app_id => @content_data.short,
      :number_of_players => @content_data.getbyte,
      :max_players => @content_data.getbyte,
      :number_of_bots => @content_data.getbyte,
      :dedicated => @content_data.getc,
      :operating_system => @content_data.getc,
      :password_needed => @content_data.getbyte == 1,
      :secure => @content_data.getbyte == 1,
      :game_version => @content_data.cstring
    })

    if @content_data.remaining > 0
      extra_data_flag = @content_data.getbyte

      if extra_data_flag & EDF_GAME_PORT != 0
        info[:server_port] = @content_data.short
      end

      if extra_data_flag & EDF_SERVER_ID != 0
        info[:server_id] = @content_data.long | (@content_data.long << 32)
      end

      if extra_data_flag & EDF_SOURCE_TV != 0
        info[:tv_port] = @content_data.short
        info[:tv_name] = @content_data.cstring
      end

      if extra_data_flag & EDF_SERVER_TAGS != 0
        info[:server_tags] = @content_data.cstring
      end

      if extra_data_flag & EDF_GAME_ID != 0
        info[:game_id] = @content_data.long | (@content_data.long << 32)
      end
    end
  end

end
