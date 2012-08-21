# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2013, Sebastian Staudt

module SteamCondenser::Community

  # This class holds statistical information about missions played by a player
  # in Alien Swarm
  #
  # @author Sebastian Staudt
  class AlienSwarmMission

    # Returns the avarage damage taken by the player while playing a round in
    # this mission
    #
    # @return [Float] The average damage taken by the player
    attr_reader :avg_damage_taken

    # Returns the avarage damage dealt by the player to team mates while
    # playing a round in this mission
    #
    # @return [Float] The average damage dealt by the player to team mates
    attr_reader :avg_friendly_fire

    # Returns the avarage number of aliens killed by the player while playing a
    # round in this mission
    #
    # @return [Float] The avarage number of aliens killed by the player
    attr_reader :avg_kills

    # Returns the highest difficulty the player has beat this mission in
    #
    # @return [String] The highest difficulty the player has beat this mission
    #         in
    attr_reader :best_difficulty

    # Returns the total damage taken by the player in this mission
    #
    # @return [Fixnum] The total damage taken by the player
    attr_reader :damage_taken

    # Returns the total damage dealt by the player to team mates in this
    # mission
    #
    # @return [Fixnum] The total damage dealt by the player to team mates
    attr_reader :friendly_fire

    # Returns the number of successful rounds the player played in this mission
    #
    # @return [Fixnum] The number of successful rounds of this mission
    attr_reader :games_successful

    # Returns the URL to a image displaying the mission
    #
    # @return [String] The URL of the mission's image
    attr_reader :img

    # Returns the total number of aliens killed by the player in this mission
    #
    # @return [Fixnum] The total number of aliens killed by the player
    attr_reader :kills

    # Returns the file name of the mission's map
    #
    # @return [String] The file name of the mission's map
    attr_reader :map_name

    # Returns the name of the mission
    #
    # @return [String] The name of the mission
    attr_reader :name

    # Returns various statistics about the times needed to accomplish this
    # mission
    #
    # This includes the best times for each difficulty, the average time and
    # the total time spent in this mission.
    #
    # @return [Hash<Symbol, String>] Various time statistics about this mission
    attr_reader :time

    # Returns the number of games played in this mission
    #
    # @return [Fixnum] The number of games played in this mission
    attr_reader :total_games

    # Returns the percentage of successful games played in this mission
    #
    # @return [Float] The percentage of successful games played in this mission
    attr_reader :total_games_percentage

    # Creates a new mission instance of based on the given XML data
    #
    # @param [String] map_name The name of the mission's map
    # @param [Hash<String, Object>] mission_data The data representing this
    #        mission
    def initialize(map_name, mission_data)
      @avg_damage_taken       = mission_data['damagetakenavg'].to_f
      @avg_friendly_fire      = mission_data['friendlyfireavg'].to_f
      @avg_kills              = mission_data['killsavg'].to_f
      @best_difficulty        = mission_data['bestdifficulty']
      @damage_taken           = mission_data['damagetaken'].to_i
      @friendly_fire          = mission_data['friendlyfire'].to_i
      @games_successful       = mission_data['gamessuccess'].to_i
      @img                    = AlienSwarmStats::BASE_URL + mission_data['image']
      @kills                  = mission_data['kills'].to_i
      @map_name               = map_name
      @name                   = mission_data['name']
      @total_games            = mission_data['gamestotal'].to_i
      @total_games_percentage = mission_data['gamestotalpct'].to_f

      @time = {
        :average => mission_data['avgtime'],
        :brutal  => mission_data['brutaltime'],
        :easy    => mission_data['easytime'],
        :hard    => mission_data['hardtime'],
        :insane  => mission_data['insanetime'],
        :normal  => mission_data['normaltime'],
        :total   => mission_data['totaltime']
      }
    end

  end
end
