# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2011, Sebastian Staudt

require 'steam/community/game_class'

# Represents the stats for a Day of Defeat: Source class for a specific user
#
# @author Sebastian Staudt
module SteamCondenser
  class DoDSClass

    include GameClass

    # Returns the blocks achieved by the player with this class
    #
    # @return [Fixnum] The blocks achieved by the player
    attr_reader :blocks

    # Returns the bombs defused by the player with this class
    #
    # @return [Fixnum] The bombs defused by the player
    attr_reader :bombs_defused

    # Returns the bombs planted by the player with this class
    #
    # @return [Fixnum] the bombs planted by the player
    attr_reader :bombs_planted

    # Returns the number of points captured by the player with this class
    #
    # @return [Fixnum] The number of points captured by the player
    attr_reader :captures

    # Returns the number of times the player died with this class
    #
    # @return [Fixnum] The number of deaths by the player
    attr_reader :deaths

    # Returns the dominations achieved by the player with this class
    #
    # @return [Fixnum] The dominations achieved by the player
    attr_reader :dominations

    # Returns the ID of this class
    #
    # @return [String] The ID of this class
    attr_reader :key

    # Returns the number of enemies killed by the player with this class
    #
    # @return [Fixnum] The number of enemies killed by the player
    attr_reader :kills

    # Returns the number of rounds lost with this class
    #
    # @return [Fixnum] The number of rounds lost with this class
    attr_reader :rounds_lost

    # Returns the revenges achieved by the player with this class
    #
    # @return [Fixnum] The revenges achieved by the player
    attr_reader :revenges

    # Returns the number of rounds won with this class
    #
    # @return [Fixnum] The number of rounds won with this class
    attr_reader :rounds_won

    # Creates a new instance of a Day of Defeat: Source class based on the given
    # XML data
    #
    # @param [Hash<String, Object>] class_data The XML data of the class
    def initialize(class_data)
      @blocks        = class_data['blocks'].to_i
      @bombs_defused = class_data['bombsdefused'].to_i
      @bombs_planted = class_data['bombsplanted'].to_i
      @captures      = class_data['captures'].to_i
      @deaths        = class_data['deaths'].to_i
      @dominations   = class_data['dominations'].to_i
      @key           = class_data['key']
      @kills         = class_data['kills'].to_i
      @name          = class_data['name']
      @play_time     = class_data['playtime'].to_i
      @rounds_lost   = class_data['roundslost'].to_i
      @rounds_won    = class_data['roundswon'].to_i
      @revenges      = class_data['revenges'].to_i
    end

  end
end
