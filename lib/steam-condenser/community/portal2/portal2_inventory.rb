# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2014, Sebastian Staudt

require 'steam-condenser/community/game_inventory'
require 'steam-condenser/community/portal2/portal2_item'

module SteamCondenser::Community

  # Represents the inventory (a.k.a. Robot Enrichment) of a Portal 2 player
  #
  # @author Sebastian Staudt
  class Portal2Inventory < GameInventory

    # The Steam application ID of Portal 2
    APP_ID = 620

    # Creates a new inventory object for the given SteamID64 in Portal 2 (App ID
    # 620)
    #
    # @param [Fixnum] steam_id64 The 64bit SteamID of the player to get the
    #        inventory for
    # @macro cacheable
    def initialize(steam_id64)
      super APP_ID, steam_id64
    end

    # The class representing Portal 2 items
    @item_class = Portal2Item

  end
end
