# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'steam/community/game_item'

# Represents a Portal 2 item
#
# @author Sebastian Staudt
class Dota2Item

  include GameItem

  # Creates a new instance of a Dota 2 item with the given data
  #
  # @param [Dota2Inventory] inventory The inventory this item is contained in
  # @param [Hash<Symbol, Object>] item_data The data specifying this item
  # @raise [WebApiError] on Web API errors
  def initialize(inventory, item_data)
    super
  end

end
