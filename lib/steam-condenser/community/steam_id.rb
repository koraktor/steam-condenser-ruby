# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2013, Sebastian Staudt

require 'cgi'
require 'time'

require 'steam-condenser/community/cacheable'
require 'steam-condenser/community/game_stats'
require 'steam-condenser/community/steam_game'
require 'steam-condenser/community/steam_group'
require 'steam-condenser/community/web_api'
require 'steam-condenser/community/xml_data'
require 'steam-condenser/error'

module SteamCondenser::Community

  # The SteamId class represents a Steam Community profile (also called Steam
  # ID)
  #
  # @author Sebastian Staudt
  class SteamId

    include Cacheable
    cacheable_with_ids :custom_url, :steam_id64

    include XMLData

    # Returns the custom URL of this Steam ID
    #
    # The custom URL is a user specified unique string that can be used instead
    # of the 64bit SteamID as an identifier for a Steam ID.
    #
    # @note The custom URL is not necessarily the same as the user's nickname.
    # @return [String] The custom URL of this Steam ID
    attr_reader :custom_url

    # Returns the groups this user is a member of
    #
    # @return [Array<SteamGroup>] The groups this user is a member of
    attr_reader :groups

    # Returns the headline specified by the user
    #
    # @return [String] The headline specified by the user
    attr_reader :head_line

    # Returns the number of hours that this user played a game in the last two
    # weeks
    #
    # @return [Float] The number of hours the user has played recently
    attr_reader :hours_played

    # Returns the links that this user has added to his/her Steam ID
    #
    # The keys of the hash contain the titles of the links while the values
    # contain the corresponding URLs.
    #
    # @return [Hash<String, String>] The links of this user
    attr_reader :links

    # Returns the location of the user
    #
    # @return [String] The location of the user
    attr_reader :location

    # Returns the date of registration for the Steam account belonging to this
    # SteamID
    #
    # @return [Time] The date of the Steam account registration
    attr_reader :member_since

    # Returns the games this user has played the most in the last two weeks
    #
    # The keys of the hash contain the names of the games while the values
    # contain the number of hours the corresponding game has been played by the
    # user in the last two weeks.
    #
    # @return [Hash<String, Float>] The games this user has played the most
    #         recently
    attr_reader :most_played_games

    # Returns the Steam nickname of the user
    #
    # @return [String] The Steam nickname of the user
    attr_reader :nickname

    # Returns the privacy state of this Steam ID
    #
    # @return [String] The privacy state of this Steam ID
    attr_reader :privacy_state

    # Returns the real name of this user
    #
    # @return [String] The real name of this user
    attr_reader :real_name

    # Returns the message corresponding to this user's online state
    #
    # @return [String] The message corresponding to this user's online state
    # @see #ingame?
    # @see #online?
    attr_reader :state_message

    # Returns this user's 64bit SteamID
    #
    # @return [Fixnum] This user's 64bit SteamID
    attr_reader :steam_id64

    # Returns the Steam rating calculated over the last two weeks' activity
    #
    # @return [Float] The Steam rating of this user
    attr_reader :steam_rating

    # Returns the summary this user has provided
    #
    # @return [String] This user's summary
    attr_reader :summary

    # Returns this user's ban state in Steam's trading system
    #
    # @return [String] This user's trading ban state
    attr_reader :trade_ban_state

    # Returns the visibility state of this Steam ID
    #
    # @return [Fixnum] This Steam ID's visibility State
    attr_reader :visibility_state

    # Converts a 64bit numeric SteamID as used by the Steam Community to a
    # SteamID as reported by game servers
    #
    # @param [Fixnum] community_id The SteamID string as used by the Steam
    #        Community
    # @raise [Error] if the community ID is to small
    # @return [String] The converted SteamID, like `STEAM_0:0:12345`
    def self.community_id_to_steam_id(community_id)
      steam_id1 = community_id % 2
      steam_id2 = community_id - 76561197960265728

      unless steam_id2 > 0
        raise SteamCondenser::Error, "SteamID #{community_id} is too small."
      end

      steam_id2 = (steam_id2 - steam_id1) / 2

      "STEAM_0:#{steam_id1}:#{steam_id2}"
    end

    def self.community_id_to_steam_id3(community_id)
      #First part of Steam ID 3 is always 1
      steam_id1 = 1
      steam_id2 = community_id - 76561197960265728

      unless steam_id2 > 0
        raise SteamCondenser::Error, "SteamID #{community_id} is too small."
      end

      "[U:#{steam_id1}:#{steam_id2}]"
    end

    # Resolves a vanity URL of a Steam Community profile to a 64bit numeric
    # SteamID
    #
    # @param [String] vanity_url The vanity URL of a Steam Community profile
    # @return [Fixnum] The 64bit numeric SteamID
    def self.resolve_vanity_url(vanity_url)
      params = { :vanityurl => vanity_url }
      json = WebApi.json 'ISteamUser', 'ResolveVanityURL', 1, params
      result = json[:response]

      return nil if result[:success] != 1

      result[:steamid].to_i
    end

    # Converts a SteamID as reported by game servers to a 64bit numeric SteamID
    # as used by the Steam Community
    #
    # @param [String] steam_id The SteamID string as used on servers, like
    #        `STEAM_0:0:12345`
    # @raise [Error] if the SteamID doesn't have the correct format
    # @return [Fixnum] The converted 64bit numeric SteamID
    def self.steam_id_to_community_id(steam_id)
      if steam_id == 'STEAM_ID_LAN' || steam_id == 'BOT'
        raise SteamCondenser::Error, "Cannot convert SteamID \"#{steam_id}\" to a community ID."
      elsif steam_id =~ /^STEAM_[0-1]:([0-1]:[0-9]+)$/
        steam_id = $1.split(':').map! { |s| s.to_i }
        steam_id[0] + steam_id[1] * 2 + 76561197960265728
      elsif steam_id =~ /^\[U:([0-1]:[0-9]+)\]$/
        steam_id = $1.split(':').map { |s| s.to_i }
        steam_id[0] + steam_id[1] + 76561197960265727
      else
        raise SteamCondenser::Error, "SteamID \"#{steam_id}\" doesn't have the correct format."
      end
    end

    # Creates a new `SteamId` instance using a SteamID as used on servers
    #
    # The SteamID from the server is converted into a 64bit numeric SteamID
    # first before this is used to retrieve the corresponding Steam Community
    # profile.
    #
    # @param [String] steam_id The SteamID string as used on servers, like
    #        `STEAM_0:0:12345`
    # @return [SteamId] The `SteamId` belonging to the given SteamID
    # @see .convert_steam_id_to_community_id
    # @see #initialize
    def self.from_steam_id(steam_id)
      new(steam_id_to_community_id steam_id)
    end

    # Creates a new `SteamId` instance for the given Steam ID
    #
    # @param [String, Fixnum] id The custom URL of the Steam ID specified by the
    #        user or the 64bit SteamID
    # @macro cacheable
    def initialize(id)
      if id.is_a? Numeric
        @steam_id64 = id
      else
        if id =~ /^STEAM_[0-1]:[0-1]:[0-9]+$/ || id =~ /\[U:[0-1]:[0-9]+\]/
          @steam_id64 = SteamId.steam_id_to_community_id id
        else
          @custom_url = id.downcase
        end
      end
    end

    # Returns whether the owner of this SteamID is VAC banned
    #
    # @return [Boolean] `true` if the user has been banned by VAC
    def banned?
      @vac_banned
    end
    alias_method :is_banned?, :banned?

    # Returns the base URL for this Steam ID
    #
    # This URL is different for Steam IDs having a custom URL.
    #
    # @return [String] The base URL for this SteamID
    def base_url
      if @custom_url.nil?
        "http://steamcommunity.com/profiles/#@steam_id64"
      else
        "http://steamcommunity.com/id/#@custom_url"
      end
    end

    # Fetches data from the Steam Community by querying the XML version of the
    # profile specified by the ID of this Steam ID
    #
    # @raise [Error] if the Steam ID data is not available, e.g. when it is
    #        private
    # @see Cacheable#fetch
    def fetch
      profile = parse "#{base_url}?xml=1"

      raise SteamCondenser::Error, profile['error'] unless profile['error'].nil?

      unless profile['privacyMessage'].nil?
        raise SteamCondenser::Error, profile['privacyMessage']
      end

      @nickname         = CGI.unescapeHTML profile['steamID']
      @steam_id64       = profile['steamID64'].to_i
      @limited          = (profile['isLimitedAccount'].to_i == 1)
      @trade_ban_state  = profile['tradeBanState']
      @vac_banned       = (profile['vacBanned'].to_i == 1)

      @image_url        = profile['avatarIcon'][0..-5]
      @online_state     = profile['onlineState']
      @privacy_state    = profile['privacyState']
      @state_message    = profile['stateMessage']
      @visibility_state = profile['visibilityState'].to_i

      if public?
        @custom_url = (profile['customURL'] || '').downcase
        @custom_url = nil if @custom_url.empty?

        @head_line    = CGI.unescapeHTML profile['headline'] || ''
        @hours_played = profile['hoursPlayed2Wk'].to_f
        @location     = profile['location']
        @member_since = Time.parse profile['memberSince']
        @real_name    = CGI.unescapeHTML profile['realname'] || ''
        @steam_rating = profile['steamRating'].to_f
        @summary      = CGI.unescapeHTML profile['summary'] || ''

        @most_played_games = {}
        [(profile['mostPlayedGames'] || {})['mostPlayedGame']].compact.flatten.each do |most_played_game|
          @most_played_games[most_played_game['gameName']] = most_played_game['hoursPlayed'].to_f
        end

        @groups = []
        [(profile['groups'] || {})['group']].compact.flatten.each do |group|
          @groups << SteamGroup.new(group['groupID64'].to_i, false)
        end

        @links = {}
        [(profile['weblinks'] || {})['weblink']].compact.flatten.each do |link|
          @links[CGI.unescapeHTML link['title']] = link['link']
        end
      end
    rescue
      raise $! if $!.is_a? SteamCondenser::Error
      raise SteamCondenser::Error, 'XML data could not be parsed.'
    end

    # Fetches the friends of this user
    #
    # This creates a new `SteamId` instance for each of the friends without
    # fetching their data.
    #
    # @see #friends
    # @see #initialize
    def fetch_friends
      params = { :relationship => 'friend', :steamid => @steam_id64 }

      friends_data = WebApi.json 'ISteamUser', 'GetFriendList', 1, params
      @friends = friends_data[:friendslist][:friends].map do |friend|
        SteamId.new(friend[:steamid].to_i, false)
      end
    end

    # Fetches the games this user owns
    #
    # This fills the game hash with the names of the games as keys. The values
    # will either be `false` if the game does not have stats or the game's
    # "friendly name".
    #
    # @see #games
    def fetch_games
      params = {
        :include_appinfo           => 1,
        :include_played_free_games => 1,
        :steamId                   => @steam_id64
      }
      games_data = WebApi.json 'IPlayerService', 'GetOwnedGames', 1, params
      @games            = {}
      @recent_playtimes = {}
      @total_playtimes  = {}
      games_data[:response][:games].each do |game_data|
        app_id = game_data[:appid]
        @games[app_id] = SteamGame.new app_id, game_data

        @recent_playtimes[app_id] = game_data[:playtime_2weeks] || 0
        @total_playtimes[app_id]  = game_data[:playtime_forever] || 0
      end

      @games
    end

    # Returns the URL of the full-sized version of this user's avatar
    #
    # @return [String] The URL of the full-sized avatar
    def full_avatar_url
      "#{@image_url}_full.jpg"
    end

    # Returns the stats for the given game for the owner of this SteamID
    #
    # @param [Fixnum] app_id The application ID of the game stats should be
    #        fetched for
    # @return [GameStats] The statistics for the game with the given name
    # @raise [Error] if the user does not own this game or it does not have any
    #        stats
    def game_stats(app_id)
      GameStats.new @custom_url || @steam_id64, app_id
    end

    # Returns the Steam Community friends of this user
    #
    # If the friends haven't been fetched yet, this is done now.
    #
    # @return [Array<SteamId>] The friends of this user
    # @see #fetch_friends
    def friends
      @friends || fetch_friends
    end

    # Returns the games this user owns
    #
    # The keys of the hash are the games' application IDs and the values are
    # the corresponding game instances.
    #
    # If the friends haven't been fetched yet, this is done now.
    #
    # @return [Hash<Fixnum, SteamGame>] The games this user owns
    # @see #fetch_games
    def games
      @games || fetch_games
    end

    # Returns the URL of the icon version of this user's avatar
    #
    # @return [String] The URL of the icon-sized avatar
    def icon_url
      "#@image_url.jpg"
    end

    # Returns a unique identifier for this Steam ID
    #
    # This is either the 64bit numeric SteamID or custom URL
    #
    # @return [Fixnum, String] The 64bit numeric SteamID or the custom URL
    def id
      @custom_url || @steam_id64
    end

    # Returns whether the owner of this SteamId is playing a game
    #
    # @return [Boolean] `true` if the user is in-game
    def in_game?
      @online_state == 'in-game'
    end

    # Returns whether this Steam account is limited
    #
    # @return [Boolean] `true` if this account is limited
    def limited?
      @limited
    end

    # Returns the URL of the medium-sized version of this user's avatar
    #
    # @return [String] The URL of the medium-sized avatar
    def medium_avatar_url
      "#{@image_url}_medium.jpg"
    end

    # Returns whether the owner of this SteamID is currently logged into Steam
    #
    # @return [Boolean] `true` if the user is online
    def online?
      @online_state != 'offline'
    end

    # Returns whether this Steam ID is publicly accessible
    #
    # @return [Boolean] `true` if this Steam ID is public
    def public?
      @privacy_state == 'public'
    end

    # Returns the time in minutes this user has played this game in the last
    # two weeks
    #
    # @param [Fixnum] app_id The application ID of the game
    # @return [Fixnum] The number of minutes this user played the given game in
    #         the last two weeks
    def recent_playtime(app_id)
      @recent_playtimes[app_id]
    end

    # Returns the current Steam level of this user
    #
    # If the Steam level hasn't been updated yet, this is done now.
    #
    # @return [Fixnum] The current Steam level of this user
    # @see #update_steam_level
    def steam_level
      @steam_level || update_steam_level
    end

    # Returns the total time in minutes this user has played this game
    #
    # @param [Fixnum] app_id The application ID of the game
    # @return [Fixnum] The total number of minutes this user played the given
    #         game
    def total_playtime(app_id)
      @total_playtimes[app_id]
    end

    # Updates the Steam level of this user using the Web API
    #
    # @return [Fixnum] The current Steam level of this user
    # @see #steam_level
    def update_steam_level
      data = WebApi.json 'IPlayerService', 'GetSteamLevel', 1, { :steamid => @steam_id64 }
      @steam_level = data[:response][:player_level]
    end

  end
end
