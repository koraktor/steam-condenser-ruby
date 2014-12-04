# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2014, Sebastian Staudt

require 'steam/community/game_inventory'
require 'steam/community/tf2/tf2_item'

# Represents the inventory (aka. Backpack) of a player of the public Team
# Fortress 2 beta
class TF2BetaInventory < GameInventory

  # The Steam application ID of the Team Fortress 2 beta
  APP_ID = 520

  # Creates a new inventory object for the given SteamID64 in the Team Fortress
  # 2 beta (App ID 520)
  #
  # @param [Fixnum] steam_id64 The 64bit SteamID of the player to get the
  #        inventory for
  # @macro cacheable
  def initialize(steam_id64)
    super APP_ID, steam_id64
  end

  @item_class = TF2Item

end
