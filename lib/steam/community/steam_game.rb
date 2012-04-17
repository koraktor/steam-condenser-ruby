# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'steam/community/cacheable'
require 'steam/community/game_leaderboard'
require 'steam/community/game_stats'
require 'steam/community/web_api'

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

  # Returns the URL for the icon image of this game
  #
  # @return [String] The URL for the game icon
  attr_reader :icon_url

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
      raise SteamCondenserError, "The steam.inf file at \"#{path}\" is invalid."
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

  # Returns whether the given version of the game with the given application ID
  # is up-to-date
  #
  # @param [Fixnum] app_id The application ID of the game to check
  # @param [Fixnum] version The version to check against the Web API
  # @return [Boolean] `true` if the given version is up-to-date
  def self.uptodate?(app_id, version)
    params = { :appid => app_id, :version => version }
    result = WebApi.json 'ISteamApps', 'UpToDateCheck', 1, params
    result = MultiJson.load(result, { :symbolize_keys => true})[:response]
    raise SteamCondenserError, result[:error] unless result[:success]
    result[:up_to_date]
  end

  # Returns whether this game has statistics available
  #
  # @return [Boolean] `true` if this game has stats
  def has_stats?
    !@short_name.nil?
  end

  # Returns a unique identifier for this game
  #
  # This is either the numeric application ID or the unique short name
  #
  # @return [Fixnum, String] The application ID or short name of the game
  def id
    @short_name == @app_id.to_s ? @app_id : @short_name
  end

  # Returns the leaderboard for this game and the given leaderboard ID or name
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
    "http://media.steampowered.com/steamcommunity/public/images/apps/#@app_id/#@logo_hash.jpg"
  end

  # Returns the URL for the logo thumbnail image of this game
  #
  # @return [String] The URL for the game logo thumbnail
  def logo_thumbnail_url
    "http://media.steampowered.com/steamcommunity/public/images/apps/#@app_id/#@logo_hash_thumb.jpg"
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
  # @param [Hash<String, Object>] game_data The XML data of the game
  def initialize(app_id, game_data)
    @app_id   = app_id

    if game_data.key? 'name'
      @logo_hash = game_data['logo'].match(/\/#{app_id}\/([0-9a-f]+).jpg/)[1]
      @name      = game_data['name']

      if game_data.key? 'globalStatsLink'
        @short_name = game_data['globalStatsLink'].match(/http:\/\/steamcommunity.com\/stats\/([^?\/]+)\/achievements\//)[1].downcase
      end
    else
      @icon_url   = game_data['gameIcon']
      @logo_hash  = game_data['gameLogo'].match(/\/#{app_id}\/([0-9a-f]+).jpg/)[1]
      @name       = game_data['gameName']
      @short_name = game_data['gameFriendlyName'].downcase
      @short_name = @app_id if @short_name == @app_id.to_s
    end

    super()
  end

end
