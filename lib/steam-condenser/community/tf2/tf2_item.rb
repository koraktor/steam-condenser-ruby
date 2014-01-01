# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2012, Sebastian Staudt

require 'steam-condenser/community/game_item'

module SteamCondenser::Community

  # Represents a Team Fortress 2 item
  #
  # @author Sebastian Staudt
  class TF2Item

    include GameItem

    # The names of the classes available in Team Fortress 2
    CLASSES = [ :scout, :sniper, :soldier, :demoman, :medic, :heavy, :pyro, :spy ]

    # Returns the slot where this item can be equipped in or `nil` if this item
    # cannot be equipped
    #
    # @return [String, nil] The slot where this item can be equipped in
    attr_reader :slot

    # Creates a new instance of a TF2 item with the given data
    #
    # @param [TF2Inventory] inventory The inventory this item is contained in
    # @param [Hash<Symbol, Object>] item_data The data specifying this item
    # @raise [Error::WebApi] on Web API errors
    def initialize(inventory, item_data)
      super

      @slot = schema_data[:item_slot]

      @equipped = {}
      CLASSES.each_index do |class_id|
        @equipped[CLASSES[class_id]] = (item_data[:inventory] & (1 << 16 + class_id) != 0)
      end
    end

    # Returns the class symbols for each class this player has equipped this item
    #
    # @return [Array<String>] The names of the classes this player has equipped
    #         this item
    def classes_equipped?
      @equipped.reject { |_, equipped| !equipped }
    end

    # Returns whether this item is equipped by this player at all
    #
    # @return [Boolean] `true` if the player has equipped this item at all
    def equipped?
      @equipped.has_value? true
    end

  end
end
