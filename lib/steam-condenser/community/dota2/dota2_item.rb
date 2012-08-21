# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'steam-condenser/community/game_item'

module SteamCondenser::Community

  # Represents a DotA 2 item
  #
  # @author Sebastian Staudt
  class Dota2Item

    include GameItem

    # Creates a new instance of a DotA 2 item with the given data
    #
    # @param [Dota2Inventory] inventory The inventory this item is contained in
    # @param [Hash<Symbol, Object>] item_data The data specifying this item
    # @raise [WebApiError] on Web API errors
    def initialize(inventory, item_data)
      super

      @equipped = !item_data[:equipped].nil?
    end

    # Returns whether this item is equipped by this player at all
    #
    # @return [Boolean] Whether this item is equipped by this player at all
    def equipped?
      @equipped
    end

  end

end
