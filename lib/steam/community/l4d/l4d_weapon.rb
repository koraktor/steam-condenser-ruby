# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2012, Sebastian Staudt

require 'steam/community/l4d/abstract_l4d_weapon'

module SteamCondenser

  # This class represents the statistics of a single weapon for a user in
  # Left4Dead
  #
  # @author Sebastian Staudt
  class L4DWeapon

    include AbstractL4DWeapon

    # Creates a new instance of a weapon based on the given XML data
    #
    # @param [String] weapon_name The name of this weapon
    # @param [Hash<String, Object>] weapon_data The XML data of this weapon
    def initialize(weapon_name, weapon_data)
      super

      @kill_percentage = weapon_data['killpct'].to_f * 0.01
    end

  end
end
