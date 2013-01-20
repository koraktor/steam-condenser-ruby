# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2011, Sebastian Staudt

require 'steam/community/game_class'

# Represents the stats for a Team Fortress 2 class for a specific user
#
# @author Sebastian Staudt
module SteamCondenser
  class TF2Class

    include GameClass

    # Returns the maximum number of buildings the player has destroyed in a
    # single life with this class
    #
    # @return [Fixnum] Maximum number of buildings destroyed
    attr_reader :max_buildings_destroyed

    # Returns the maximum number of points captured by the player in a single
    # life with this class
    #
    # @return [Fixnum] Maximum number of points captured
    attr_reader :max_captures

    # Returns the maximum damage dealt by the player in a single life with this
    # class
    #
    # @return [Fixnum] Maximum damage dealt
    attr_reader :max_damage

    # Returns the maximum number of defenses by the player in a single life with
    # this class
    #
    # @return [Fixnum] Maximum number of defenses
    attr_reader :max_defenses

    # Returns the maximum number of dominations by the player in a single life
    # with this class
    #
    # @return [Fixnum] Maximum number of dominations
    attr_reader :max_dominations

    # Returns the maximum number of times the the player assisted a teammate with
    # killing an enemy in a single life with this class
    #
    # @return [Fixnum] Maximum number of kill assists
    attr_reader :max_kill_assists

    # Returns the maximum number of enemies killed by the player in a single life
    # with this class
    #
    # @return [Fixnum] Maximum number of kills
    attr_reader :max_kills

    # Returns the maximum number of revenges by the player in a single life with
    # this class
    #
    # @return [Fixnum] Maximum number of revenges
    attr_reader :max_revenges

    # Returns the maximum number score achieved by the player in a single life
    # with this class
    #
    # @return [Fixnum] Maximum score
    attr_reader :max_score

    # Returns the maximum lifetime by the player in a single life with this class
    #
    # @return [Fixnum] Maximum lifetime
    attr_reader :max_time_alive

    # Creates a new TF2 class instance based on the assigned XML data
    #
    # @param [Hash<String, Object>] class_data The XML data for this class
    def initialize(class_data)
      @name                    = class_data['className']
      @max_buildings_destroyed = class_data['ibuildingsdestroyed'].to_i
      @max_captures            = class_data['ipointcaptures'].to_i
      @max_damage              = class_data['idamagedealt'].to_i
      @max_defenses            = class_data['ipointdefenses'].to_i
      @max_dominations         = class_data['idominations'].to_i
      @max_kill_assists        = class_data['ikillassists'].to_i
      @max_kills               = class_data['inumberofkills'].to_i
      @max_revenges            = class_data['irevenge'].to_i
      @max_score               = class_data['ipointsscored'].to_i
      @max_time_alive          = class_data['iplaytime'].to_i
      @play_time               = class_data['playtimeSeconds'].to_i
    end

  end
end
