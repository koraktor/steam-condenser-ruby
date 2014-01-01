# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'steam-condenser/community/cacheable'
require 'steam-condenser/community/game_leaderboard'
require 'steam-condenser/community/game_stats'
require 'steam-condenser/community/web_api'

module SteamCondenser::Community

  # This class represents a game available on Steam
  #
  # @author Sebastian Staudt
  class SteamGame

    include Cacheable
    cacheable_with_ids :app_id

    # Returns the Steam application ID of this game
    #
    # @return [Fixnum] The Steam application ID of this game
    attr_reader :app_id
    alias_method :id, :app_id

    # Returns the full name of this game
    #
    # @return [String] The full name of this game
    attr_reader :name

    # Returns the short name of this game (also known as "friendly name")
    #
    # @return [String] The short name of this game
    attr_reader :short_name

    # Checks if a game is up-to-date by reading information from a `steam.inf`
    # file and comparing it using the Web API
    #
    # @param [String] path The file system path of the `steam.inf` file
    # @return [Boolean] `true` if the game is up-to-date
    def self.check_steam_inf(path)
      steam_inf = File.read path
      begin
        app_id = steam_inf.match(/^\s*appID=(\d+)\s*$/im)[1].to_i
        version = steam_inf.match(/^\s*PatchVersion=([\d\.]+)\s*$/im)[1].gsub('.', '').to_i
      rescue
        raise SteamCondenser::Error, "The steam.inf file at \"#{path}\" is invalid."
      end
      uptodate? app_id, version
    end

    # Creates a new instance of a game with the given data and caches it
    #
    # @param [Fixnum] app_id The application ID of the game
    # @param [Hash<String, Object>] game_data The XML data of the game
    def self.new(app_id, game_data = nil)
      if cached? app_id
        class_variable_get(:@@cache)[app_id]
      else
        game = SteamGame.allocate
        game.send :initialize, app_id, game_data
        game
      end
    end

    # Returns whether the given version of the game with the given application
    # ID is up-to-date
    #
    # @param [Fixnum] app_id The application ID of the game to check
    # @param [Fixnum] version The version to check against the Web API
    # @return [Boolean] `true` if the given version is up-to-date
    def self.uptodate?(app_id, version)
      params = { :appid => app_id, :version => version }
      result = WebApi.json 'ISteamApps', 'UpToDateCheck', 1, params
      result = result[:response]
      raise SteamCondenser::Error, result[:error] unless result[:success]
      result[:up_to_date]
    end

    # Returns whether this game has statistics available
    #
    # @return [Boolean] `true` if this game has stats
    def has_stats?
      !@short_name.nil?
    end

    # Returns the URL for the icon image of this game
    #
    # @return [String] The URL for the game icon
    def icon_url
      return nil if @icon_hash.nil?
      "http://media.steampowered.com/steamcommunity/public/images/apps/#@app_id/#@icon_hash.jpg"
    end

    # Returns a unique identifier for this game
    #
    # This is either the numeric application ID or the unique short name
    #
    # @return [Fixnum, String] The application ID or short name of the game
    def id
      @short_name == @app_id.to_s ? @app_id : @short_name
    end

    # Returns the leaderboard for this game and the given leaderboard ID or
    # name
    #
    # @param [Fixnum, String] id The ID or name of the leaderboard to return
    # @return [GameLeaderboard] The matching leaderboard if available
    def leaderboard(id)
      GameLeaderboard.leaderboard @short_name, id
    end

    # Returns an array containing all of this game's leaderboards
    #
    # @return [Array<GameLeaderboard>] The leaderboards for this game
    def leaderboards
      GameLeaderboard.leaderboards @short_name
    end

    # Returns the URL for the logo image of this game
    #
    # @return [String] The URL for the game logo
    def logo_url
      return nil if @logo_hash.nil?
      "http://media.steampowered.com/steamcommunity/public/images/apps/#@app_id/#@logo_hash.jpg"
    end

    # Returns the URL for the logo thumbnail image of this game
    #
    # @return [String] The URL for the game logo thumbnail
    def logo_thumbnail_url
      return nil if @logo_hash.nil?
      "http://media.steampowered.com/steamcommunity/public/images/apps/#@app_id/##{@logo_hash}_thumb.jpg"
    end

    # Returns the overall number of players currently playing this game
    #
    # @return [Fixnum] The number of players playing this game
    def player_count
      params = { :appid => @app_id }
      result = WebApi.json 'ISteamUserStats', 'GetNumberOfCurrentPlayers', 1, params
      result[:response][:player_count]
    end

    # Returns the URL of this game's page in the Steam Store
    #
    # @return [String] This game's store page
    def store_url
      "http://store.steampowered.com/app/#@app_id"
    end

    # Returns whether the given version of this game is up-to-date
    #
    # @param [Fixnum] version The version to check against the Web API
    # @return [Boolean] `true` if the given version is up-to-date
    def uptodate?(version)
      self.class.uptodate? @app_id, version
    end

    # Creates a stats object for the given user and this game
    #
    # @param [String, Fixnum] steam_id The custom URL or the 64bit Steam ID of
    #        the user
    # @return [GameStats] The stats of this game for the given user
    def user_stats(steam_id)
      return unless has_stats?

      GameStats.create_game_stats steam_id, @short_name
    end

    private

    # Creates a new instance of a game with the given data and caches it
    #
    # @note The real constructor of `SteamGame` is {.new}
    # @param [Fixnum] app_id The application ID of the game
    # @param [Hash<Symbol, Object>, Hash<String, Object>] game_data The JSON or
    #        XML data of the game
    def initialize(app_id, game_data)
      @app_id   = app_id

      if game_data.key? :name
        @icon_hash = game_data[:img_icon_url]
        @logo_hash = game_data[:img_logo_url]
        @name      = game_data[:name]
      else
        url_regex   = /\/#{app_id}\/([0-9a-f]+).jpg/
        @icon_hash  = game_data['gameIcon'].match(url_regex)[1]
        @logo_hash  = game_data['gameLogo'].match(url_regex)[1]
        @name       = game_data['gameName']
        @short_name = game_data['gameFriendlyName'].downcase
        @short_name = nil if @short_name == @app_id.to_s
      end
    end

  end
end
