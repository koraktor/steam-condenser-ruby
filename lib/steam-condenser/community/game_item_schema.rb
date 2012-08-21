# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'steam-condenser/community/cacheable'

module SteamCondenser::Community

  # Provides item definitions and related data that specify the items of a game
  #
  # @author Sebastian Staudt
  class GameItemSchema

    include Cacheable
    cacheable_with_ids [ :app_id, :language ]

    # Returns the application ID of the game this item schema belongs to
    #
    # @return [Fixnum] The application ID of the game
    attr_reader :app_id

    # The attributes defined for this game's items
    #
    # @return [Hash<Symbol, Object>] This item schema's attributes
    attr_reader :attributes

    # The effects defined for this game's items
    #
    # @return [Hash<Symbol, Object>] This item schema's effects
    attr_reader :effects

    # The levels defined for this game's items
    #
    # @return [Hash<Symbol, Object>] This item schema's item levels
    attr_reader :item_levels

    # A mapping from the item name to the item's defindex
    #
    # @return [Hash<Symbol, Object>] The item name mapping
    attr_reader :item_names

    # The item sets defined for this game's items
    #
    # @return [Hash<Symbol, Object>] This item schema's item sets
    attr_reader :item_sets

    # The items defined for this game
    #
    # @return [Hash<Symbol, Object>] The items in this schema
    attr_reader :items

    # The language of this item schema
    #
    # @return [Symbol] The language of this item schema
    attr_reader :language

    # The item origins defined for this game's items
    #
    # @return [Array<String>] This item schema's origins
    attr_reader :origins

    # The item qualities defined for this game's items
    #
    # @return [Array<String>] This item schema's qualities
    attr_reader :qualities

    # Creates a new item schema for the game with the given application ID and
    # with descriptions in the given language
    #
    # @param [Fixnum] app_id The application ID of the game
    # @param [Symbol] language The language of description strings
    # @macro cacheable
    def initialize(app_id, language = nil)
      @app_id   = app_id
      @language = language
    end

    # Updates the item definitions of this schema using the Steam Web API
    def fetch
      params = { :language => language }
      data = WebApi.json!("IEconItems_#{app_id}", 'GetSchema', 1, params)

      @attributes = {}
      data[:attributes].each do |attribute|
        @attributes[attribute[:defindex]] = attribute
        @attributes[attribute[:name]]     = attribute
      end

      @effects = {}
      data[:attribute_controlled_attached_particles].each do |effect|
        @effects[effect[:id]] = effect[:name]
      end

      @items = {}
      @item_names = {}
      data[:items].each do |item|
        @items[item[:defindex]] = item
        @item_names[item[:name]] = item[:defindex]
      end

      @item_levels = {}
      data[:item_levels].each do |item_level_type|
        @item_levels[item_level_type[:name]] = {}
        item_level_type[:levels].each do |level|
          @item_levels[item_level_type[:name]][level[:level]] = level[:name]
        end
      end if data.key? :item_levels

      @item_sets = {}
      data[:item_sets].each do |item_set|
        @item_sets[item_set[:item_set]] = item_set
      end

      @origins = []
      data[:originNames].each do |origin|
        @origins[origin[:origin]] = origin[:name]
      end

      @qualities = []
      data[:qualities].keys.each_with_index do |key, index|
        @qualities[index] = data[:qualityNames][key] || key.to_s.capitalize
      end
    end

    # Returns a short, human-readable string representation of this item schema
    #
    # @return [String] A string representation of this item schema
    def inspect
      "#<#{self.class}:#@app_id (#@language) - #{fetch_time || 'not fetched'}>"
    end

  end
end
