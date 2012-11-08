# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'steam/community/web_api'

# A module implementing basic functionality for classes representing an item in
# a game
#
# @author Sebastian Staudt
module GameItem

  # Return the attributes of this item
  #
  # @return [Hash<Symbol, Object>] The attributes of this item
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

  # Returns the level of this item
  #
  # @return [Fixnum] The level of this item
  attr_reader :level

  # Returns the level of this item
  #
  # @return [String] The level of this item
  attr_reader :name

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
    @id                = item_data[:id]
    @item_class        = schema_data[:item_class]
    @level             = item_data[:level]
    @name              = inventory.item_schema[@defindex][:item_name]
    @quality           = inventory.qualities[item_data[:quality]]
    @tradeable         = !(item_data[:flag_cannot_trade] == true)
    @type              = inventory.item_schema[@defindex][:item_type_name]

    unless inventory.item_schema[@defindex][:attributes].nil?
      @attributes = inventory.item_schema[@defindex][:attributes]
    end
  end

  # Returns whether this item is tradeable
  #
  # @return [Boolean] `true` if this item is tradeable
  def tradeable?
    @tradeable
  end

end
