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
class S2A_INFO_DETAILED_Packet

  include S2A_INFO_BasePacket

  # Creates a new S2A_INFO_DETAILED response object based on the given data
  #
  # @param [String] data The raw packet data replied from the server
  # @see S2A_INFO_BasePacket#generate_info_hash
  def initialize(data)
    super S2A_INFO_DETAILED_HEADER, data

    info[:game_ip] = @content_data.cstring
    info[:server_name] = @content_data.cstring
    info[:map_name] = @content_data.cstring
    info[:game_directory] = @content_data.cstring
    info[:game_description] = @content_data.cstring
    info[:number_of_players] = @content_data.byte
    info[:max_players] = @content_data.byte
    info[:network_version] = @content_data.byte
    info[:dedicated] = @content_data.byte.chr
    info[:operating_system] = @content_data.byte.chr
    info[:password_needed] = @content_data.byte == 1
    info[:is_mod] = @content_data.byte == 1

    if info[:is_mod]
      info[:mod_info] = {}
      info[:mod_info][:url_info] = @content_data.cstring
      info[:mod_info][:url_dl] = @content_data.cstring
      @content_data.byte
      if @content_data.remaining == 12
        info[:mod_info][:mod_version] = @content_data.long
        info[:mod_info][:mod_size] = @content_data.long
        info[:mod_info][:sv_only] = @content_data.byte == 1
        info[:mod_info][:cl_dll] = @content_data.byte == 1
        info[:secure] = @content_data.byte == 1
        info[:number_of_bots] = @content_data.byte
      end
    else
      info[:secure] = @content_data.byte == 1
      info[:number_of_bots] = @content_data.byte
    end
  end

end
