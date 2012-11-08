# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2013, Sebastian Staudt

require 'steam-condenser/community/game_stats_schema'

module SteamCondenser::Community

  class GameStatsDatum

    attr_reader :api_name

    attr_reader :default_value

    attr_reader :schema

    # @param [GameStatsSchema] schema
    # @param [Hash<Symbol, Object>] data
    def initialize(schema, data)
      @api_name      = data[:name]
      @default_value = data[:defaultvalue]
      @schema        = schema
      @name          = data[:displayName]
    end

    def inspect
      "#<#{self.class}: #@api_name (#@default_value)>"
    end

    def instance(user, value)
      Instance.new user, self, value
    end

    def name(language = GameStatsSchema.default_language)
      @schema.datum_names(language)[@api_name]
    end

    class Instance

      attr_reader :datum

      attr_reader :user

      attr_reader :value

      def initialize(user, datum, value)
        @datum = datum
        @user  = user
        @value = value
      end

      def inspect
        "#<#{self.class}: #{@datum.api_name} (#@value)>"
      end

    end

  end
end
