# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2011, Sebastian Staudt

require 'steam/community/tf2/tf2_class'

# Represents the stats for the Team Fortress 2 Spy class for a specific user
#
# @author Sebastian Staudt
module SteamCondenser
  class TF2Spy < TF2Class

    # Returns the maximum number enemies killed with a backstab by the player in
    # a single life as a Spy
    #
    # @return [Fixnum] Maximum number of buildings built
    attr_reader :max_backstabs

    # Returns the head shots by the player in a single life as a Spy
    #
    # @return [Fixnum] Maximum number of head shots
    attr_reader :max_head_shots

    # Returns the maximum health leeched from enemies by the player in a single
    # life as a Spy
    #
    # @return [Fixnum] Maximum health leeched
    attr_reader :max_health_leeched

    # Creates a new instance of the Spy class based on the given XML data
    #
    # @param [Hash<String, Object>] class_data The XML data for this Spy
    def initialize(class_data)
      super class_data

      @max_backstabs      = class_data['ibackstabs'].to_i
      @max_head_shots     = class_data['iheadshots'].to_i
      @max_health_leeched = class_data['ihealthpointsleached'].to_i
    end

  end
end
