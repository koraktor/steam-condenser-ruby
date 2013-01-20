# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt

require 'steam/community/cacheable'
require 'steam/community/game_item'
require 'steam/community/game_item_schema'
require 'steam/community/steam_id'
require 'steam/community/web_api'

module SteamCondenser
  class GameInventory
  end
end

require 'steam/community/dota2/dota2_beta_inventory'
require 'steam/community/dota2/dota2_inventory'
require 'steam/community/portal2/portal2_inventory'
require 'steam/community/tf2/tf2_beta_inventory'
require 'steam/community/tf2/tf2_inventory'

# Provides basic functionality to represent an inventory of player in a game
#
# @author Sebastian Staudt
module SteamCondenser
  class GameInventory

    include Cacheable
    cacheable_with_ids [:app_id, :steam_id64]

    # Returns the application ID of the game this inventory class belongs to
    #
    # @return [Fixnum] The application ID of the game
    attr_reader :app_id

    # Returns an array of all items in this players inventory.
    #
    # @return [Array<GameItem>] All items in the backpack
    attr_reader :items

    # Returns an array of all items that this player just found or traded
    #
    # @return [Array<GameItem>] All preliminary items of the inventory
    attr_reader :preliminary_items

    # Returns the Steam ID of the player owning this inventory
    #
    # @return [SteamId] The Steam ID of the owner of this inventory
    attr_reader :user

    @@item_class = GameItem

    @@schema_language = 'en'

    # This is a wrapper around all subclasses of `GameInventory` so that an
    # instance of correct subclass is returned for a given application ID. If
    # there's no specific subclass for an application ID exists, a generic
    # instance of `GameInventory` is created.
    #
    # @param [Fixnum] app_id The application ID of the game
    # @param [Fixnum] steam_id The 64bit Steam ID or vanity URL of the user
    # @return [GameInventory] The inventory for the given user and game
    # @raise [SteamCondenserException] if creating the inventory fails
    # @macro cacheable
    def self.new(app_id, steam_id = nil, *args)
      args = args.unshift steam_id unless steam_id.nil?
      if self == GameInventory
        raise ArgumentError, 'wrong number of arguments (1 for 2)' if args.empty?
      else
        args = args.unshift app_id
        app_id = self::APP_ID
      end

      cacheable_new = Cacheable::ClassMethods.instance_method :new

      case app_id
        when Dota2BetaInventory::APP_ID
          cacheable_new = cacheable_new.bind Dota2BetaInventory
        when Dota2Inventory::APP_ID
          cacheable_new = cacheable_new.bind Dota2Inventory
        when Portal2Inventory::APP_ID
          cacheable_new = cacheable_new.bind Portal2Inventory
        when TF2BetaInventory::APP_ID
          cacheable_new = cacheable_new.bind TF2BetaInventory
        when TF2Inventory::APP_ID
          cacheable_new = cacheable_new.bind TF2Inventory
        else
          cacheable_new = cacheable_new.bind GameInventory
          return cacheable_new.call app_id, *args
      end

      cacheable_new.call *args
    end

    # Sets the language the schema should be fetched in (default is: `'en'`)
    #
    # @param [String] language The ISO 639-1 code of the schema language
    def self.schema_language=(language)
      @@schema_language = language
    end

    # Creates a new inventory object for the given AppID and SteamID64. This
    # calls update to fetch the data and create the item instances contained in
    # this players backpack
    #
    # @param [Fixnum] app_id The application ID of the game
    # @param [Fixnum] steam_id64 The 64bit SteamID of the player to get the
    #        inventory for
    # @macro cacheable
    def initialize(app_id, steam_id64)
      unless steam_id64.is_a? Fixnum
        steam_id64 = SteamId.resolve_vanity_url steam_id64.to_s
        raise SteamCondenserError.new 'User not found' if steam_id64.nil?
      end

      @app_id     = app_id
      @items      = []
      @steam_id64 = steam_id64
      @user       = SteamId.new steam_id64, false
    end

    # Returns the item at the given position in the inventory. The positions
    # range from 1 to 100 instead of the usual array indices (0 to 99).
    #
    # @return [GameItem] The item at the given position in the inventory
    def [](index)
      @items[index - 1]
    end

    # Updates the contents of the inventory using the Steam Web API
    def fetch
      params = { :SteamID => @user.steam_id64 }
      result = WebApi.json! "IEconItems_#@app_id", 'GetPlayerItems', 1, params
      item_class = self.class.send :class_variable_get, :@@item_class

      @items = []
      @preliminary_items = []
      result[:items].each do |item_data|
        unless item_data.nil?
          item = item_class.new(self, item_data)
          if item.preliminary?
            @preliminary_items << item
          else
            @items[item.backpack_position - 1] = item
          end
        end
      end
    end

    # Returns a short, human-readable string representation of this inventory
    #
    # @return [String] A string representation of this inventory
    def inspect
      "#<#{self.class}:#@app_id #@steam_id64 (#{size} items) - " +
      "#{fetch_time || 'not fetched'}>"
    end

    # Returns the item schema for this inventory
    #
    # @return [GameItemSchema] The item schema for the game this inventory
    #         belongs to
    def item_schema
      @item_schema ||= GameItemSchema.new app_id, @@schema_language
    end

    # Returns the number of items in the user's inventory
    #
    # @return [Fixnum] The number of items in the inventory
    def size
      @items.size
    end

  end
end
