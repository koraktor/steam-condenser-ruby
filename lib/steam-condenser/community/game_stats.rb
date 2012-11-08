# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'steam-condenser/community/cacheable'
require 'steam-condenser/community/game_achievement'
require 'steam-condenser/community/game_leaderboard'
require 'steam-condenser/community/game_stats_schema'

module SteamCondenser::Community

  # This class represents the game statistics for a single user and a specific
  # game
  #
  # @author Sebastian Staudt
  class GameStats

    include Cacheable
    cacheable_with_ids [ :app_id, :steam_id64 ]

    # Returns the achievements for this stats' user and game
    #
    # If the achievements' data hasn't been parsed yet, parsing is done now.
    #
    # @return [Array<GameAchievement::Instance>] All achievements belonging to
    #         this game
    attr_reader :achievements

    # Returns the Steam ID of the player these stats belong to
    #
    # @return [SteamId] The Steam ID instance of the player
    attr_reader :user

    # Returns the schema of the game these stats belong to
    #
    # @return [GameStatsSchema] The stats schema
    attr_reader :schema

    # @return [Array<GameStatsValue::Instance>]
    attr_reader :values

    # Creates a `GameStats` object and fetches data from the Steam Community
    # for the given user and game
    #
    # @param [String, Fixnum] user_id The custom URL or the 64bit Steam ID of
    #        the user
    # @param [String] game_id The application ID or friendly name of the game
    # @raise [Error] if the stats cannot be fetched
    def initialize(user_id, game_id)
      if user_id.is_a? String
        user_id = SteamId.resolve_vanity_url user_id
      end

      @schema = GameStatsSchema.new game_id
      @user   = SteamId.new user_id, false

      @app_id     = game_id
      @steam_id64 = @user.steam_id64

      params = { appid: @schema.app_id, steamid: @user.steam_id64 }
      data = WebApi.json 'ISteamUserStats', 'GetUserStatsForGame', 2, params

      @achievements = []
      data[:playerstats][:achievements].each do |achievement|
        api_name = achievement[:name]
        unlocked = achievement[:achieved] == 1
        @achievements << @schema.achievement(api_name).instance(@user, unlocked)
      end

      @values = []
      data[:playerstats][:stats].each do |datum|
        @values << @schema.datum(datum[:name]).instance(@user, datum[:value])
      end
    end

    # Returns the number of achievements done by this player
    #
    # @return [Fixnum] The number of achievements completed
    # @see #achievements
    def achievements_done
      @achievements.size
    end

    # Returns the percentage of achievements done by this player
    #
    # @return [Float] The percentage of achievements completed
    # @see #achievements_done
    def achievements_percentage
      @achievements.size.to_f / @schema.achievements.size
    end

    def inspect
      "#<#{self.class}:#{@user.id} \"#{@schema.app_name}\">"
    end

  end
end
