# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt

require 'steam/community/web_api'

# A module implementing basic functionality for classes representing an item in
# a game
#
# @author Sebastian Staudt
module GameItem

  # Return the attributes of this item
  #
  # @return [Hash<Symbol, Object>, nil] The attributes of this item
  attr_reader :attributes

  # Returns the position of this item in the player's inventory
  #
  # @return [Fixnum] The position of this item in the player's inventory
  attr_reader :backpack_position

  # Returns the number of items the player owns of this item
  #
  # @return [Fixnum] The quanitity of this item
  attr_reader :count

  # Returns the index where the item is defined in the schema
  #
  # @return [Fixnum] The schema index of this item
  attr_reader :defindex

  # Returns the ID of this item
  #
  # @return [Fixnum] The ID of this item
  attr_reader :id

  # Returns the inventory this items belongs to
  #
  # @return [GameInventory] The inventory this item belongs to
  attr_reader :inventory

  # Returns the class of this item
  #
  # @return [String] The class of this item
  attr_reader :item_class

  # Returns the item set this item belongs to
  #
  # @return [Hash<Symbol, Object>, nil] The set this item belongs to
  attr_reader :item_set

  # Returns the level of this item
  #
  # @return [Fixnum] The level of this item
  attr_reader :level

  # Returns the level of this item
  #
  # @return [String] The level of this item
  attr_reader :name

  # Returns the origin of this item
  #
  # @return [String] The origin of this item
  attr_reader :origin

  # Returns the original ID of this item
  #
  # @return [Fixnum] The original ID of this item
  attr_reader :original_id

  # Returns the quality of this item
  #
  # @return [String] The quality of this item
  attr_reader :quality

  # Returns the type of this item
  #
  # @return [String] The type of this item
  attr_reader :type

  # Creates a new instance of a GameItem with the given data
  #
  # @param [GameInventory] inventory The inventory this item is contained in
  # @param [Hash<Symbol, Object>] item_data The data representing this item
  def initialize(inventory, item_data)
    @inventory = inventory

    @defindex          = item_data[:defindex]
    @backpack_position = item_data[:inventory] & 0xffff
    @count             = item_data[:quantity]
    @craftable         = !!item_data[:flag_cannot_craft]
    @id                = item_data[:id]
    @item_class        = schema_data[:item_class]
    @item_set          = inventory.item_schema.item_sets[schema_data[:item_set]]
    @level             = item_data[:level]
    @name              = schema_data[:item_name]
    @original_id       = item_data[:original_id]
    @preliminary       = item_data[:inventory] & 0x40000000 != 0
    @quality           = inventory.item_schema.qualities[item_data[:quality]]
    @tradeable         = !!item_data[:flag_cannot_trade]
    @type              = schema_data[:item_type_name]

    if item_data.key? :origin
      @origin = inventory.item_schema.origins[item_data[:origin]]
    end

    attributes_data = schema_data[:attributes] || []
    attributes_data += item_data[:attributes] if item_data.key? :attributes

    @attributes = []
    attributes_data.each do |attribute_data|
      attribute_key = attribute_data[:defindex]
      attribute_key = attribute_data[:name] if attribute_key.nil?

      unless attribute_key.nil?
        schema_attribute_data = inventory.item_schema.attributes[attribute_key]
        @attributes << attribute_data.merge(schema_attribute_data)
      end
    end
  end

  # Returns whether this item is craftable
  #
  # @return [Boolean] `true` if this item is craftable
  def craftable?
    @craftable
  end

  # Returns whether this item is preliminary
  #
  # Preliminary means that this item was just found or traded and has not yet
  # been added to the inventory
  #
  # @return [Boolean] `true` if this item is preliminary
  def preliminary?
    @preliminary
  end

  # Returns the data for this item that's defined in the item schema
  #
  # @return [Hash<Symbol, Object>] The schema data for this item
  def schema_data
    inventory.item_schema.items[@defindex]
  end

  # Returns whether this item is tradeable
  #
  # @return [Boolean] `true` if this item is tradeable
  def tradeable?
    @tradeable
  end

end
