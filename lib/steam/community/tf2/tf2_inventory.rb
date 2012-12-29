# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2012, Sebastian Staudt

require 'steam/community/game_inventory'
require 'steam/community/tf2/tf2_item'

# Represents the inventory (aka. Backpack) of a Team Fortress 2 player
#
# @author Sebastian Staudt
class TF2Inventory < GameInventory

  # The Steam application ID of Team Fortress 2
  APP_ID = 440

  # Creates a new inventory object for the given SteamID64 in Team Fortress 2
  # (App ID 440)
  #
  # @param [Fixnum] steam_id64 The 64bit SteamID of the player to get the
  #        inventory for
  # @macro cacheable
  def initialize(steam_id64)
    super APP_ID, steam_id64
  end

  # The class representing Team Fortress 2 items
  @@item_class = TF2Item

end
