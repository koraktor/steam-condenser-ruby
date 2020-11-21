# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2020, Sebastian Staudt

require 'steam/packets/query_packet'

# This packet class class represents a A2S_INFO request send to a game server
#
# It will cause the server to send some basic information about itself, e.g.
# the running game, map and the number of players.
#
# @author Sebastian Staudt
# @see GameServer#update_server_info
class A2S_INFO_Packet

  include QueryPacket

  # Creates a new A2S_INFO request object
  def initialize
    super A2S_INFO_HEADER, "Source Engine Query\0"
  end

end
