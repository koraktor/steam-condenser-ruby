# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2014, Sebastian Staudt

require 'steam-condenser/community/dota2/dota2_item'
require 'steam-condenser/community/game_inventory'

module SteamCondenser::Community

  # Represents the inventory of a DotA 2 player
  #
  # @author Sebastian Staudt
  class Dota2Inventory < GameInventory

    # The Steam application ID of DotA 2
    APP_ID = 570

    # Creates a new inventory object for the given SteamID64 in DotA 2
    # (App ID 570)
    #
    # @param [Fixnum] steam_id64 The 64bit SteamID of the player to get the
    #        inventory for
    # @macro cacheable
    def initialize(steam_id64)
      super APP_ID, steam_id64
    end

    # The class representing DotA 2 items
    @item_class = Dota2Item

  end

end
