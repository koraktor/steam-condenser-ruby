# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2011, Sebastian Staudt

require 'steam/community/game_stats'

# This module is a base for statistics for Left4Dead and Left4Dead 2. As both
# games have more or less the same statistics available in the Steam Community
# the code for both is pretty much the same.
#
# @author Sebastian Staudt
module AbstractL4DStats

  # The names of the special infected in Left4Dead
  SPECIAL_INFECTED = %w(boomer hunter smoker tank)

  # Returns a hash of statistics for this user's most recently played game
  #
  # @return [Hash<String, Object>] The most recent statistics for this user
  attr_reader :most_recent_game

  # Creates a new instance of statistics for both, Left4Dead and Left4Dead 2
  # parsing basic common data
  #
  # @param [String] steam_id The custom URL or 64bit Steam ID of the user
  # @param [String] game_name The name of the game
  def initialize(steam_id, game_name)
    super steam_id, game_name

    if public?
      @most_recent_game = {}
      unless @xml_data['stats']['mostrecentgame'].nil?
        @most_recent_game[:difficulty]  = @xml_data['stats']['mostrecentgame']['difficulty']
        @most_recent_game[:escaped]     = (@xml_data['stats']['mostrecentgame']['bEscaped'] == 1)
        @most_recent_game[:movie]       = @xml_data['stats']['mostrecentgame']['movie']
        @most_recent_game[:time_played] = @xml_data['stats']['mostrecentgame']['time']
      end
    end
  end

  # Returns a hash of favorites for this user like weapons and character
  #
  # If the favorites haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, Object>] The favorites of this user
  def favorites
    return unless public?

    if @favorites.nil?
      @favorites = {}
      @favorites[:campaign]                 = @xml_data['stats']['favorites']['campaign']
      @favorites[:campaign_percentage]      = @xml_data['stats']['favorites']['campaignpct'].to_i
      @favorites[:character]                = @xml_data['stats']['favorites']['character']
      @favorites[:character_percentage]     = @xml_data['stats']['favorites']['characterpct'].to_i
      @favorites[:level1_weapon]            = @xml_data['stats']['favorites']['weapon1']
      @favorites[:level1_weapon_percentage] = @xml_data['stats']['favorites']['weapon1pct'].to_i
      @favorites[:level2_weapon]            = @xml_data['stats']['favorites']['weapon2']
      @favorites[:level2_weapon_percentage] = @xml_data['stats']['favorites']['weapon2pct'].to_i
    end

    @favorites
  end

  # Returns a hash of lifetime statistics for this user like the time played
  #
  # If the lifetime statistics haven't been parsed already, parsing is done
  # now.
  #
  # @return [Hash<String, Object>] The lifetime statistics for this user
  def lifetime_stats
    return unless public?

    if @lifetime_stats.nil?
      @lifetime_stats = {}
      @lifetime_stats[:finales_survived] = @xml_data['stats']['lifetime']['finales'].to_i
      @lifetime_stats[:games_played]     = @xml_data['stats']['lifetime']['gamesplayed'].to_i
      @lifetime_stats[:infected_killed]  = @xml_data['stats']['lifetime']['infectedkilled'].to_i
      @lifetime_stats[:kills_per_hour]   = @xml_data['stats']['lifetime']['killsperhour'].to_f
      @lifetime_stats[:avg_kits_shared]  = @xml_data['stats']['lifetime']['kitsshared'].to_f
      @lifetime_stats[:avg_kits_used]    = @xml_data['stats']['lifetime']['kitsused'].to_f
      @lifetime_stats[:avg_pills_shared] = @xml_data['stats']['lifetime']['pillsshared'].to_f
      @lifetime_stats[:avg_pills_used]   = @xml_data['stats']['lifetime']['pillsused'].to_f
      @lifetime_stats[:time_played]      = @xml_data['stats']['lifetime']['timeplayed']

      @lifetime_stats[:finales_survived_percentage] = @lifetime_stats[:finales_survived].to_f / @lifetime_stats[:games_played]
    end

    @lifetime_stats
  end

  # Returns a hash of Survival statistics for this user like revived teammates
  #
  # If the Survival statistics haven't been parsed already, parsing is done
  # now.
  #
  # @return [Hash<String, Object>] The Survival statistics for this user
  def survival_stats
    return unless public?

    if @survival_stats.nil?
      @survival_stats = {}
      @survival_stats[:gold_medals]   = @xml_data['stats']['survival']['goldmedals'].to_i
      @survival_stats[:silver_medals] = @xml_data['stats']['survival']['silvermedals'].to_i
      @survival_stats[:bronze_medals] = @xml_data['stats']['survival']['bronzemedals'].to_i
      @survival_stats[:rounds_played] = @xml_data['stats']['survival']['roundsplayed'].to_i
      @survival_stats[:best_time]     = @xml_data['stats']['survival']['besttime'].to_f
    end

    @survival_stats
  end

  # Returns a hash of teamplay statistics for this user like revived teammates
  #
  # If the teamplay statistics haven't been parsed already, parsing is done
  # now.
  #
  # @return [Hash<String, Object>] The teamplay statistics for this
  def teamplay_stats
    return unless public?

    if @teamplay_stats.nil?
      @teamplay_stats = {}
      @teamplay_stats[:revived]                       = @xml_data['stats']['teamplay']['revived'].to_i
      @teamplay_stats[:most_revived_difficulty]       = @xml_data['stats']['teamplay']['reviveddiff']
      @teamplay_stats[:avg_revived]                   = @xml_data['stats']['teamplay']['revivedavg'].to_f
      @teamplay_stats[:avg_was_revived]               = @xml_data['stats']['teamplay']['wasrevivedavg'].to_f
      @teamplay_stats[:protected]                     = @xml_data['stats']['teamplay']['protected'].to_i
      @teamplay_stats[:most_protected_difficulty]     = @xml_data['stats']['teamplay']['protecteddiff']
      @teamplay_stats[:avg_protected]                 = @xml_data['stats']['teamplay']['protectedavg'].to_f
      @teamplay_stats[:avg_was_protected]             = @xml_data['stats']['teamplay']['wasprotectedavg'].to_f
      @teamplay_stats[:friendly_fire_damage]          = @xml_data['stats']['teamplay']['ffdamage'].to_i
      @teamplay_stats[:most_friendly_fire_difficulty] = @xml_data['stats']['teamplay']['ffdamagediff']
      @teamplay_stats[:avg_friendly_fire_damage]      = @xml_data['stats']['teamplay']['ffdamageavg'].to_f
    end

    @teamplay_stats
  end

  # Returns a hash of Versus statistics for this user like percentage of rounds
  # won
  #
  # If the Versus statistics haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, Object>] The Versus statistics for this user
  def versus_stats
    return unless public?

    if @versus_stats.nil?
      @versus_stats = {}
      @versus_stats[:games_played]                = @xml_data['stats']['versus']['gamesplayed'].to_i
      @versus_stats[:games_completed]             = @xml_data['stats']['versus']['gamescompleted'].to_i
      @versus_stats[:finales_survived]            = @xml_data['stats']['versus']['finales'].to_i
      @versus_stats[:points]                      = @xml_data['stats']['versus']['points'].to_i
      @versus_stats[:most_points_infected]        = @xml_data['stats']['versus']['pointsas']
      @versus_stats[:games_won]                   = @xml_data['stats']['versus']['gameswon'].to_i
      @versus_stats[:games_lost]                  = @xml_data['stats']['versus']['gameslost'].to_i
      @versus_stats[:highest_survivor_score]      = @xml_data['stats']['versus']['survivorscore'].to_i

      @versus_stats[:finales_survived_percentage] = @versus_stats[:finales_survived].to_f / @versus_stats[:games_played]

      self.class.const_get(:SPECIAL_INFECTED).each do |infected|
        @versus_stats[infected] = {}
        @versus_stats[infected][:special_attacks] = @xml_data['stats']['versus']["#{infected}special"].to_i
        @versus_stats[infected][:most_damage]     = @xml_data['stats']['versus']["#{infected}dmg"].to_i
        @versus_stats[infected]['avg_lifespan']    = @xml_data['stats']['versus']["#{infected}lifespan"].to_i
      end
    end

    @versus_stats
  end

end
