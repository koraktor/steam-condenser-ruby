# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2015, Sebastian Staudt

require 'multi_json'

require 'steam-condenser/community/web_api'

module SteamCondenser::Community

  # The GameAchievement class represents a specific achievement for a single
  # game and for a single user
  #
  # It also provides the ability to load the global unlock percentages of all
  # achievements of a specific game.
  #
  # @author Sebastian Staudt
  class GameAchievement

    # Returns the symbolic API name of this achievement
    #
    # @return [String] The API name of this achievement
    attr_reader :api_name

    # Returns whether this achievement is hidden
    #
    # @return [Boolean] `true` if this achievement is hidden
    attr_reader :hidden

    # Returns the url for the closed icon of this achievement
    #
    # @return [String] The url of the closed achievement icon
    attr_reader :icon_closed_url

    # Returns the url for the open icon of this achievement
    #
    # @return [String] The url of the open achievement icon
    attr_reader :icon_open_url

    # Return the stats schema of the game this achievement belongs to
    #
    # @return [GameStatsSchema] The stats schema of game this achievement
    #         belongs to
    attr_reader :schema

    # Loads the global unlock percentages of all achievements for the game with
    # the given Steam Application ID
    #
    # @param [Fixnum] app_id The unique Steam Application ID of the game (e.g.
    #        `440` for Team Fortress 2). See
    #         http://developer.valvesoftware.com/wiki/Steam_Application_IDs for
    #         all application IDs
    # @raise [Error::WebApi] if the request to Steam's Web API fails
    # @return [Hash<Symbol, Float>] The symbolic achievement names with their
    #         corresponding unlock percentages
    def self.global_percentages(app_id)
      percentages = {}

      data = WebApi.json 'ISteamUserStats', 'GetGlobalAchievementPercentagesForApp', 2, gameid: app_id
      data[:achievementpercentages][:achievements].each do |percentage|
        percentages[percentage[:name].to_sym] = percentage[:percent]
      end

      percentages
    end

    # Creates the achievement with the given name for the given user and game
    # and achievement data
    #
    # @param [GameStatsSchema] schema The game this achievement belongs to
    # @param [Hash<String, Object>] data The achievement data extracted from
    #        the game schema
    def initialize(schema, data)
      @api_name        = data[:name]
      @schema          = schema
      @hidden          = data[:hidden] == 1
      @icon_closed_url = data[:icon]
      @icon_open_url   = data[:icongray]
    end

    # Returns the description of this achievement
    #
    # @param [Symbol] language
    # @return [String] The description of this achievement
    def description(language = GameStatsSchema.default_language)
      @schema.achievement_translations(language)[@api_name][:description]
    end

    def inspect
      "#<#{self.class}:#@api_name>"
    end

    # Returns an instance of this achievement for the given user and the given
    # unlock state
    #
    # @param [SteamId] user The user the instance should be returned for
    # @param [Boolean] unlocked The state of the achievement for this user
    # @return [Instance] The achievement instance for this user
    def instance(user, unlocked)
      Instance.new self, user, unlocked
    end

    # Returns the name of this achievement
    #
    # @param [Symbol] language
    # @return [String] The name of this achievement
    def name(language = GameStatsSchema.default_language)
      @schema.achievement_translations(language)[@api_name][:name]
    end

    class Instance

      attr_reader :achievement

      attr_reader :user

      def initialize(achievement, user, unlocked)
        @achievement = achievement
        @unlocked    = unlocked
        @user        = user
      end

      def inspect
        "#<#{self.class}: #{@achievement.api_name} unlocked=#@unlocked>"
      end

      # Returns whether this achievement has been unlocked by its owner
      #
      # @return [Boolean] `true` if the achievement has been unlocked by the
      #         user
      def unlocked?
        @unlocked
      end

    end

  end
end
