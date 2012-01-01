# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2011, Sebastian Staudt

require 'steam/community/game_weapon'

# This abstract class is a base class for weapons in Left4Dead and Left4Dead 2
# as the weapon stats for both games are very similar
#
# @author Sebastian Staudt
module SteamCondenser
  module AbstractL4DWeapon

    include GameWeapon

    # Returns the overall accuracy of the player with this weapon
    #
    # @return [String] The accuracy of the player with this weapon
    attr_reader :accuracy

    # Returns the percentage of kills with this weapon that have been headshots
    #
    # @return [String] The percentage of headshots with this weapon
    attr_reader :headshots_percentage

    # Returns the ID of the weapon
    #
    # @return [String] The ID of the weapon
    attr_reader :id

    # Returns the percentage of overall kills of the player that have been
    # achieved with this weapon
    #
    # @return [String] The percentage of kills with this weapon
    attr_reader :kill_percentage

    # Returns the number of shots the player has fired with this weapon
    #
    # @return [Fixnum] The number of shots with this weapon
    attr_reader :shots

    # Creates a new instance of weapon from the given XML data and parses common
    # data for both, `L4DWeapon` and `L4D2Weapon`
    #
    # @param [String] weapon_name The name of this weapon
    # @param [Hash<String, Object>] weapon_data The XML data for this weapon
    def initialize(weapon_name, weapon_data)
      super weapon_data

      @accuracy             = weapon_data['accuracy'].to_f * 0.01
      @headshots_percentage = weapon_data['headshots'].to_f * 0.01
      @id                   = weapon_name
      @shots                = weapon_data['shots'].to_i
    end

  end
end
