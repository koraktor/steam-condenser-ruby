# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

module SteamCondenser::Servers::Packets

  # This module implements a method to generate raw packet data used by request
  # packets which send a challenge number
  #
  # @author Sebastian Staudt
  module RequestInfoWithChallenge

    # Returns the raw data representing this packet
    #
    # @return [String] A string containing the raw data of this request packet
    def to_s
      [0xFF, 0xFF, 0xFF, 0xFF, @header_data, "Source Engine Query\0", @content_data.string.to_i].pack('c5a*l')
    end

  end
end
