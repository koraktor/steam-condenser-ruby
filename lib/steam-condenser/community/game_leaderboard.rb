# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2014, Sebastian Staudt

require 'multi_xml'

require 'steam-condenser/community/game_leaderboard_entry'
require 'steam-condenser/community/steam_id'
require 'steam-condenser/community/xml_data'

module SteamCondenser::Community

  # The GameLeaderboard class represents a single leaderboard for a specific
  # game
  #
  # @author Sebastian Staudt
  class GameLeaderboard

    include XMLData

    DISPLAY_TYPE_NONE         = 0
    DISPLAY_TYPE_NUMERIC      = 1
    DISPLAY_TYPE_SECONDS      = 2
    DISPLAY_TYPE_MILLISECONDS = 3

    SORT_METHOD_NONE = 0
    SORT_METHOD_ASC  = 1
    SORT_METHOD_DESC = 2

    @@leaderboards = {}

    # Returns the display type of the scores on this leaderboard
    #
    # @return [Fixnum] The display type of the scores
    attr_reader :display_type

    # Returns the number of entries on this leaderboard
    #
    # @return [Fixnum] The number of entries on this leaderboard
    attr_reader :entry_count

    # Returns the ID of the leaderboard
    #
    # @return [Fixnum] The ID of the leaderboard
    attr_reader :id

    # Returns the name of the leaderboard
    #
    # @return [String] The name of the leaderboard
    attr_reader :name

    # Returns the method that is used to sort the entries on the leaderboard
    #
    # @return [Fixnum] The sort method
    attr_reader :sort_method

    # Returns the leaderboard for the given game and leaderboard ID or name
    #
    # @param [Fixnum] app_id The application ID of the game
    # @param [Fixnum, String] id The ID or name of the leaderboard to return
    # @return [GameLeaderboard] The matching leaderboard if available
    def self.leaderboard(app_id, id)
      leaderboards = self.leaderboards app_id

      if id.is_a? Fixnum
        leaderboards[id]
      else
        leaderboards.each_value do |board|
          return board if board.name == id
        end
      end
    end

    # Returns an array containing all of a game's leaderboards
    #
    # @param [Fixnum] app_id The application ID of the game
    # @return [Array<GameLeaderboard>] The leaderboards for this game
    def self.leaderboards(app_id)
      self.load_leaderboards app_id unless @@leaderboards.key? app_id

      @@leaderboards[app_id]
    end

    # Returns the entry on this leaderboard for the user with the given SteamID
    #
    # @param [Fixnum, SteamId] steam_id The 64bit SteamID or the `SteamId`
    #        object of the user
    # @return [GameLeaderboardEntry] The entry of the user if available
    # raise [SteamCondenserException] if an error occurs while fetching the
    #         leaderboard
    def entry_for_steam_id(steam_id)
      steam_id = steam_id.steam_id64 if steam_id.is_a? SteamId

      parse "#@url&steamid=#{steam_id}"

      error = @xml_data['error']
      raise SteamCondenser::Error, error unless error.nil?

      @xml_data['entries']['entry'].each do |entry_data|
        if entry_data['steamid'].to_i == steam_id
          return GameLeaderboardEntry.new entry_data, self
        end
      end

      nil
    end

    # Returns an array of entries on this leaderboard for the user with the
    # given SteamID and his/her friends
    #
    # @param [Fixnum, SteamId] steam_id The 64bit SteamID or the `SteamId`
    #        object of the user
    # @return [Array<GameLeaderboardEntry>] The entries of the user and his/her
    #         friends
    # raise [SteamCondenserException] if an error occurs while fetching the
    #         leaderboard
    def entry_for_steam_id_friends(steam_id)
      steam_id = steam_id.steam_id64 if steam_id.is_a? SteamId

      parse "#@url&steamid=#{steam_id}"

      error = @xml_data['error']
      raise SteamCondenser::Error, error unless error.nil?

      parse_entries
    end

    # Returns the entries on this leaderboard for a given rank range
    #
    # The range is inclusive and a maximum of 5001 entries can be returned in a
    # single request.
    #
    # @param [Fixnum] first The first entry to return from the leaderboard
    # @param [Fixnum] last The last entry to return from the leaderboard
    # @return [Array<GameLeaderboardEntry>] The entries that match the given
    #         rank range
    # raise [SteamCondenserException] if an error occurs while fetching the
    #         leaderboard
    def entry_range(first, last)
      if last < first
        raise SteamCondenser::Error,
          'First entry must be prior to last entry for leaderboard entry lookup.'
      end

      if (last - first) > 5000
        raise SteamCondenser::Error,
          'Leaderboard entry lookup is currently limited to a maximum of 5001 entries per request.'
      end

      parse "#@url&start=#{first}&end=#{last}"

      error = @xml_data['error']
      raise SteamCondenser::Error, error unless error.nil?

      entries = []
      @xml_data['entries']['entry'].each do |entry_data|
        rank = entry_data['rank'].to_i
        entries[rank] = GameLeaderboardEntry.new entry_data, self
      end

      parse_entries
    end

    private

    # Creates a new leaderboard instance with the given XML data
    #
    # @param [Hash<String, Object>] board_data The XML data of the leaderboard
    def initialize(board_data)
      @url          = board_data['url']
      @id           = board_data['lbid'].to_i
      @name         = board_data['name']
      @entry_count  = board_data['entries'].to_i
      @sort_method  = board_data['sortmethod'].to_i
      @display_type = board_data['displaytype'].to_i
    end

    # Parses all entries available in the XML data
    #
    # @return [Array<GameLeaderboardEntry>] All available entries
    def parse_entries
      entries = []
      @xml_data['entries']['entry'].each do |entry_data|
        entries[entry_data['rank'].to_i] =
          GameLeaderboardEntry.new entry_data, self
      end

      entries
    end

    # Loads the leaderboards of the specified games into the cache
    #
    # @param [Fixnum] app_id The application ID of the game
    # @raise [SteamCondenserException] if an error occurs while fetching the
    #         leaderboards
    def self.load_leaderboards(app_id)
      begin
        url = "http://steamcommunity.com/stats/#{app_id}/leaderboards/?xml=1"
        boards_data = MultiXml.parse(open(url, {:proxy => true})).values.first
      rescue
        raise SteamCondenser::Error.new 'XML data could not be parsed.', $!
      end

      error = boards_data['error']
      raise SteamCondenser::Error, error unless error.nil?

      @@leaderboards[app_id] = {}
      boards_data['leaderboard'].each do |board_data|
        leaderboard = GameLeaderboard.new board_data
        @@leaderboards[app_id][leaderboard.id] = leaderboard
      end
    end

  end
end
