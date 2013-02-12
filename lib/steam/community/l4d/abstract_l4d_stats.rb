# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2013, Sebastian Staudt

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
      most_recent_game_data = @xml_data['stats']['mostrecentgame']

      @most_recent_game = {}
      unless most_recent_game_data.nil?
        @most_recent_game[:difficulty]  = most_recent_game_data['difficulty']
        @most_recent_game[:escaped]     = (most_recent_game_data['bEscaped'] == 1)
        @most_recent_game[:movie]       = most_recent_game_data['movie']
        @most_recent_game[:time_played] = most_recent_game_data['time']
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
      favorites_data = @xml_data['stats']['favorites']

      @favorites = {}
      @favorites[:campaign]                 = favorites_data['campaign']
      @favorites[:campaign_percentage]      = favorites_data['campaignpct'].to_i
      @favorites[:character]                = favorites_data['character']
      @favorites[:character_percentage]     = favorites_data['characterpct'].to_i
      @favorites[:level1_weapon]            = favorites_data['weapon1']
      @favorites[:level1_weapon_percentage] = favorites_data['weapon1pct'].to_i
      @favorites[:level2_weapon]            = favorites_data['weapon2']
      @favorites[:level2_weapon_percentage] = favorites_data['weapon2pct'].to_i
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
      lifetime_data = @xml_data['stats']['lifetime']

      @lifetime_stats = {}
      @lifetime_stats[:finales_survived] = lifetime_data['finales'].to_i
      @lifetime_stats[:games_played]     = lifetime_data['gamesplayed'].to_i
      @lifetime_stats[:infected_killed]  = lifetime_data['infectedkilled'].to_i
      @lifetime_stats[:kills_per_hour]   = lifetime_data['killsperhour'].to_f
      @lifetime_stats[:avg_kits_shared]  = lifetime_data['kitsshared'].to_f
      @lifetime_stats[:avg_kits_used]    = lifetime_data['kitsused'].to_f
      @lifetime_stats[:avg_pills_shared] = lifetime_data['pillsshared'].to_f
      @lifetime_stats[:avg_pills_used]   = lifetime_data['pillsused'].to_f
      @lifetime_stats[:time_played]      = lifetime_data['timeplayed']

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
      survival_data = @xml_data['stats']['survival']

      @survival_stats = {}
      @survival_stats[:gold_medals]   = survival_data['goldmedals'].to_i
      @survival_stats[:silver_medals] = survival_data['silvermedals'].to_i
      @survival_stats[:bronze_medals] = survival_data['bronzemedals'].to_i
      @survival_stats[:rounds_played] = survival_data['roundsplayed'].to_i
      @survival_stats[:best_time]     = survival_data['besttime'].to_f
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
      teamplay_data = @xml_data['stats']['teamplay']

      @teamplay_stats = {}
      @teamplay_stats[:revived]                       = teamplay_data['revived'].to_i
      @teamplay_stats[:most_revived_difficulty]       = teamplay_data['reviveddiff']
      @teamplay_stats[:avg_revived]                   = teamplay_data['revivedavg'].to_f
      @teamplay_stats[:avg_was_revived]               = teamplay_data['wasrevivedavg'].to_f
      @teamplay_stats[:protected]                     = teamplay_data['protected'].to_i
      @teamplay_stats[:most_protected_difficulty]     = teamplay_data['protecteddiff']
      @teamplay_stats[:avg_protected]                 = teamplay_data['protectedavg'].to_f
      @teamplay_stats[:avg_was_protected]             = teamplay_data['wasprotectedavg'].to_f
      @teamplay_stats[:friendly_fire_damage]          = teamplay_data['ffdamage'].to_i
      @teamplay_stats[:most_friendly_fire_difficulty] = teamplay_data['ffdamagediff']
      @teamplay_stats[:avg_friendly_fire_damage]      = teamplay_data['ffdamageavg'].to_f
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
      versus_data = @xml_data['stats']['versus']

      @versus_stats = {}
      @versus_stats[:games_played]                = versus_data['gamesplayed'].to_i
      @versus_stats[:games_completed]             = versus_data['gamescompleted'].to_i
      @versus_stats[:finales_survived]            = versus_data['finales'].to_i
      @versus_stats[:points]                      = versus_data['points'].to_i
      @versus_stats[:most_points_infected]        = versus_data['pointsas']
      @versus_stats[:games_won]                   = versus_data['gameswon'].to_i
      @versus_stats[:games_lost]                  = versus_data['gameslost'].to_i
      @versus_stats[:highest_survivor_score]      = versus_data['survivorscore'].to_i

      @versus_stats[:finales_survived_percentage] = @versus_stats[:finales_survived].to_f / @versus_stats[:games_played]

      self.class.const_get(:SPECIAL_INFECTED).each do |infected|
        @versus_stats[infected] = {}
        @versus_stats[infected][:special_attacks] = versus_data["#{infected}special"].to_i
        @versus_stats[infected][:most_damage]     = versus_data["#{infected}dmg"].to_i
        @versus_stats[infected]['avg_lifespan']    = versus_data["#{infected}lifespan"].to_i
      end
    end

    @versus_stats
  end

end
