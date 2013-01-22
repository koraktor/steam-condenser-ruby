# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2011, Sebastian Staudt

require 'steam/community/game_weapon'

# Represents the stats for a Day of Defeat: Source weapon for a specific user
#
# @author Sebastian Staudt
module SteamCondenser
  class DoDSWeapon

    include GameWeapon

    # Returns the number of headshots achieved with this weapon
    #
    # @return [Fixnum] The number of headshots achieved
    attr_reader :headshots

    # Returns the name of this weapon
    #
    # @return [String] The name of this weapon
    attr_reader :name

    # Returns the number of hits achieved with this weapon
    #
    # @return [Fixnum] The number of hits achieved
    attr_reader :hits

    # Creates a new instance of a Day of Defeat: Source weapon based on the
    # given XML data
    #
    # @param [Hash<String, Object>] weapon_data The XML data of the class
    def initialize(weapon_data)
      super weapon_data

      @headshots = weapon_data['headshots'].to_i
      @id        = weapon_data['key']
      @name      = weapon_data['name']
      @shots     = weapon_data['shotsfired'].to_i
      @hits      = weapon_data['shotshit'].to_i
    end

    # Returns the average number of hits needed for a kill with this weapon
    #
    # @return [Float] The average number of hits needed for a kill
    def avg_hits_per_kill
      @hits.to_f / @kill
    end

    # Returns the percentage of headshots relative to the shots hit with this
    # weapon
    #
    # @return [Float] The percentage of headshots
    def headshot_percentage
      @headshots.to_f / @hits
    end

    # Returns the percentage of hits relative to the shots fired with this
    # weapon
    #
    # @return [Float] The percentage of hits
    def hit_percentage
      @hits.to_f / @shots
    end

  end
end
