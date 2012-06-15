# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'steam/community/dota2/dota2_item'
require 'steam/community/game_inventory'

# Represents the inventory of a player of the DotA 2 beta
#
# @author Sebastian Staudt
class Dota2BetaInventory

  include Cacheable
  cacheable_with_ids :steam_id64

  include GameInventory

  # The Steam Application ID of the DotA 2 beta
  @@app_id = 205790

  # The class representing DotA 2 items
  @@item_class = Dota2Item

end
