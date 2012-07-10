# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'steam/community/dota2/dota2_item'
require 'steam/community/game_inventory'

# Represents the inventory of a DotA 2 player
#
# @author Sebastian Staudt
class Dota2Inventory < GameInventory

  # Creates a new inventory object for the given SteamID64 in DotA 2
  # (App ID 570)
  #
  # @param [Fixnum] steam_id64 The 64bit SteamID of the player to get the
  #        inventory for
  # @macro cacheable
  def initialize(steam_id64)
    super 570, steam_id64
  end

  # The class representing DotA 2 items
  @@item_class = Dota2Item

end
