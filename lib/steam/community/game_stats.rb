# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'steam/community/game_achievement'
require 'steam/community/game_leaderboard'
require 'steam/community/xml_data'

# This class represents the game statistics for a single user and a specific
# game
#
# It is subclassed for individual games if the games provide special statistics
# that are unique to this game.
#
# @author Sebastian Staudt
class GameStats

  include XMLData

  # Returns the game these stats belong to
  #
  # @return [SteamGame] The game object
  attr_reader :game

  # Returns the number of hours this game has been played by the player
  #
  # @return [String] The number of hours this game has been played
  attr_reader :hours_played

  # Returns the privacy setting of the Steam ID profile
  #
  # @return [String] The privacy setting of the Steam ID
  attr_reader :privacy_state

  # Returns the Steam ID of the player these stats belong to
  #
  # @return [SteamId] The Steam ID instance of the player
  attr_reader :user

  # Returns the base Steam Communtiy URL for the given player and game IDs
  #
  # @param [Fixnum, String] user_id The 64bit SteamID or custom URL of the user
  # @param [Fixnum, String] game_id The application ID or short name of the
  #        game
  # @return The base URL used for the given stats IDs
  def self.base_url(user_id, game_id)
    game_url = game_id.is_a?(Fixnum) ? "appid/#{game_id}" : game_id

    if user_id.is_a? Fixnum
      "http://steamcommunity.com/profiles/#{user_id}/stats/#{game_url}"
    else
      "http://steamcommunity.com/id/#{user_id}/stats/#{game_url}"
    end
  end

  # Creates a `GameStats` (or one of its subclasses) instance for the given
  # user and game
  #
  # @param [String, Fixnum] steam_id The custom URL or the 64bit Steam ID of
  #        the user
  # @param [String] game_name The friendly name of the game
  # @return [GameStats] The game stats object for the given user and game
  def self.create_game_stats(steam_id, game_name)
    case game_name
      when 'alienswarm'
        require 'steam/community/alien_swarm/alien_swarm_stats'
        AlienSwarmStats.new(steam_id)
      when 'cs:s'
        require 'steam/community/css/css_stats'
        CSSStats.new(steam_id)
      when 'defensegrid:awakening'
        require 'steam/community/defense_grid/defense_grid_stats'
        DefenseGridStats.new(steam_id)
      when 'dod:s'
        require 'steam/community/dods/dods_stats'
        DoDSStats.new(steam_id)
      when 'l4d'
        require 'steam/community/l4d/l4d_stats'
        L4DStats.new(steam_id)
      when 'l4d2'
        require 'steam/community/l4d/l4d2_stats'
        L4D2Stats.new(steam_id)
      when 'portal2'
        require 'steam/community/portal2/portal2_stats'
        Portal2Stats.new steam_id
      when 'tf2'
        require 'steam/community/tf2/tf2_stats'
        TF2Stats.new(steam_id)
      else
        new(steam_id, game_name)
    end
  end

  # Creates a `GameStats` object and fetches data from the Steam Community for
  # the given user and game
  #
  # @param [String, Fixnum] user_id The custom URL or the 64bit Steam ID of the
  #        user
  # @param [String] game_id The application ID or friendly name of the game
  # @raise [SteamCondenserError] if the stats cannot be fetched
  def initialize(user_id, game_id)
    @xml_data = parse "#{self.class.base_url(user_id, game_id)}?xml=all"

    @user = SteamId.new user_id, false

    error = @xml_data['error']
    raise SteamCondenserError, error unless error.nil?

    @privacy_state = @xml_data['privacyState']
    if public?
      app_id        = @xml_data['game']['gameLink'].match(/http:\/\/+store\.steampowered\.com\/+app\/+([1-9][0-9]*)/)[1].to_i
      @game         = SteamGame.new app_id, @xml_data['game']
      @hours_played = @xml_data['stats']['hoursPlayed'] unless @xml_data['stats']['hoursPlayed'].nil?
    end
  end

  # Returns the achievements for this stats' user and game
  #
  # If the achievements' data hasn't been parsed yet, parsing is done now.
  #
  # @return [Array<GameAchievement>] All achievements belonging to this game
  def achievements
    return unless public?

    if @achievements.nil?
      @achievements = Array.new
      @xml_data['achievements']['achievement'].each do |achievement|
        @achievements << GameAchievement.new(@user, @game, achievement)
      end

      @achievements_done = @achievements.reject{ |a| !a.unlocked? }.size
    end

    @achievements
  end

  # Returns the number of achievements done by this player
  #
  # If achievements haven't been parsed yet for this player and this game,
  # parsing is done now.
  #
  # @return [Fixnum] The number of achievements completed
  # @see #achievements
  def achievements_done
    achievements if @achievements_done.nil?
    @achievements_done
  end

  # Returns the percentage of achievements done by this player
  #
  # If achievements haven't been parsed yet for this player and this game,
  # parsing is done now.
  #
  # @return [Float] The percentage of achievements completed
  # @see #achievements_done
  def achievements_percentage
    achievements_done.to_f / @achievements.size
  end

  # Returns the base Steam Communtiy URL for the stats contained in this object
  #
  # @return [String] The base URL used for queries on these stats
  def base_url
    self.class.base_url @user.id, @game.id
  end

  # Returns whether this Steam ID is publicly accessible
  #
  # @return [Boolean] `true` if this Steam ID is publicly accessible
  def public?
    @privacy_state == 'public'
  end

end
