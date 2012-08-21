# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2012, Sebastian Staudt

require 'steam-condenser/community/game_weapon'

module SteamCondenser::Community

  # This class holds statistical information about weapons used by a player
  # in Alien Swarm
  #
  # @author Sebastian Staudt
  class AlienSwarmWeapon

    include GameWeapon

    # Returns the accuracy of the player with this weapon
    #
    # @return [Float] The accuracy of the player with this weapon
    attr_reader :accuracy

    # Returns the damage achieved with this weapon
    #
    # @return [Fixnum] The damage achieved with this weapon
    attr_reader :damage

    # Returns the damage dealt to team mates with this weapon
    #
    # @return [Fixnum] The damage dealt to team mates with this weapon
    attr_reader :friendly_fire

    # Returns the name of this weapon
    #
    # @return [String] The name of this weapon
    attr_reader :name

    # Creates a new weapon instance based on the assigned weapon XML data
    #
    # @param [Hash<String, Object>] weapon_data The data representing this
    #        weapon
    def initialize(weapon_data)
      super

      @accuracy      = weapon_data['accuracy'].to_f
      @damage        = weapon_data['damage'].to_i
      @friendly_fire = weapon_data['friendlyfire'].to_i
      @name          = weapon_data['name']
      @shots         = weapon_data['shotsfired'].to_i
    end

  end
end
