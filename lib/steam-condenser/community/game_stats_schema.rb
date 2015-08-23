# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2015, Sebastian Staudt

require 'steam-condenser/community/cacheable'
require 'steam-condenser/community/game_achievement'
require 'steam-condenser/community/game_stats_datum'
require 'steam-condenser/community/web_api'

module SteamCondenser::Community

  class GameStatsSchema

    @@default_language = :english

    include Cacheable
    cacheable_with_ids :app_id

    # @return [Hash<String, GameAchievement>]
    attr_reader :achievements

    attr_reader :app_id

    attr_reader :app_name

    attr_reader :app_version

    attr_reader :data

    def self.default_language
      @@default_language
    end

    def self.default_language=(language)
      @@default_language = language.to_sym
    end

    # @macro cacheable
    def initialize(app_id)
      @app_id = app_id
    end

    def achievement(api_name)
      @achievements[api_name]
    end

    def fetch
      add_language self.class.default_language
    end

    def achievement_translations(language)
      add_language(language) unless @achievement_translations.key? language
      @achievement_translations[language]
    end

    def datum(api_name)
      @data[api_name]
    end

    def datum_names(language)
      add_language(language) unless @datum_names.key? language
      @datum_names[language]
    end

    def inspect
      "#<#{self.class}:#@app_id \"#@app_name\" (#@app_version)>"
    end

    protected

    def add_language(language)
      schema = fetch_language language

      initial = false
      if @data.nil?
        @achievements = {}
        @app_name = schema[:gameName]
        @app_version = schema[:gameVersion].to_i
        @data = {}
        initial = true
      end

      @datum_names[language] = {}
      schema[:availableGameStats][:stats].each do |data|
        @datum_names[language][data[:name]] = data[:displayName]
        @data[data[:name]] = GameStatsDatum.new self, data if initial
      end

      @achievement_translations[language] = {}
      schema[:availableGameStats][:achievements].each do |data|
        @achievement_translations[language][data[:name]] = {
          description: data[:description],
          name: data[:displayName]
        }
        @achievements[data[:name]] = GameAchievement.new self, data if initial
      end
    end

    def fetch_language(language)
      params = { appid: @app_id, l: language }
      WebApi.json('ISteamUserStats', 'GetSchemaForGame', 2, params)[:game]
    end

  end
end
