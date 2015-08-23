# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2012, Sebastian Staudt

# @macro [new] cacheable
#   @overload $0(${1--1}, fetch = true, bypass_cache = false)
#   @param [Boolean] fetch if `true` the object's data is fetched after
#          creation
#   @param [Boolean] bypass_cache if `true` the object's data is fetched again
#          even if it has been cached already

module SteamCondenser::Community

  # This module implements caching functionality to be used in any object class
  # having one or more unique object identifier (i.e. ID) and using a `fetch`
  # method to fetch data, e.g. using a HTTP download.
  #
  # @author Sebastian Staudt
  module Cacheable

    # When this module is included in another class it is initialized to make
    # use of caching
    #
    # The original `initialize` method of the including class will be wrapped,
    # relaying all instantiations to the `new` method defined in {ClassMethods}.
    # Additionally the class variable to save the attributes to cache (i.e. cache
    # IDs) and the cache class variable itself are initialized.
    #
    # @param [Class] base The class to extend with caching functionality
    # @see ClassMethods
    def self.included(base)
      base.extend ClassMethods
      base.send :class_variable_set, :@@cache, {}
      base.send :class_variable_set, :@@cache_ids, []

      class << base
        def method_added(name)
          if name == :fetch && !(@@in_method_added ||= false)
            @@in_method_added = true
            alias_method :original_fetch, :fetch

            define_method :fetch do
              original_fetch
              @fetch_time = Time.now
            end
            @@in_method_added = false
          end
        end
      end
    end

    # This module implements functionality to access the cache of a class that
    # includes the {Cacheable} module as class methods
    #
    # @author Sebastian Staudt
    module ClassMethods

      # Defines wich instance variables which should be used to index the
      # cached objects
      #
      # @note A call to this method is needed if you want a class including
      #       this module to really use the cache.
      # @param [Array<Symbol>] ids The symbolic names of the instance variables
      #        representing a unique identifier for this object class
      def cacheable_with_ids(*ids)
        class_variable_set :@@cache_ids, ids
      end

      # Returns whether an object with the given ID is already cached
      #
      # @param [Object] id The ID of the desired object
      # @return [Boolean] `true` if the object with the given ID is already
      #         cached
      def cached?(id)
        id.downcase! if id.is_a? String
        cache.key?(id)
      end

      # Clears the object cache for the class this method is called on
      def clear_cache
        class_variable_set :@@cache, {}
      end

      # This checks the cache for an existing object. If it exists it is
      # returned, otherwise a new object is created.
      # Overrides the default `new` method of the cacheable object class.
      #
      # @param [Array<Object>] args The parameters of the object that should be
      #        created and if possible loaded from cache
      # @see #cached?
      # @see #fetch
      def new(*args)
        arity = self.instance_method(:initialize).arity.abs
        args += [nil] * (arity - args.size) if args.size < arity
        bypass_cache = args.size > arity + 1 ? !!args.pop : false
        fetch = args.size > arity ? !!args.pop : true

        object = self.allocate
        object.send :initialize, *args
        cached_object = object.send :cached_instance
        object = cached_object unless cached_object.nil? || bypass_cache

        if fetch && (bypass_cache || !object.fetched?)
          object.fetch
          object.cache
        end

        object
      end

      private

      # Returns the current cache for the cacheable class
      #
      # @return [Hash<Object, Cacheable>] The cache for cacheable class
      def cache
        class_variable_get :@@cache
      end

      # Returns the list of IDs used for caching objects
      #
      # @return [Array<Symbol, Array<Symbol>>] The IDs used for caching objects
      def cache_ids
        class_variable_get :@@cache_ids
      end

    end

    # Returns the time the object's data has been fetched the last time
    #
    # @return [Time] The time the object has been updated the last time
    attr_reader :fetch_time

    # Saves this object in the cache
    #
    # This will use the ID attributes selected for caching
    def cache
      cache = self.class.send :cache
      cache_ids.each do |cache_id|
        cache[cache_id] = self if cache_id
      end

      true
    end

    # Fetches the object from some data source
    #
    # @note This method should be overridden in cacheable object classes and
    #       should implement the logic to retrieve the object's data. Updating
    #       the time is handled dynamically and does not need to be implemented
    #       separately.
    def fetch
    end

    # Returns whether the data for this object has already been fetched
    #
    # @return [Boolean] `true` if this object's data is available
    def fetched?
      !@fetch_time.nil?
    end

    private

    # If available, returns the cached instance for the object it is called on
    #
    # This may be used to either replace an initial object with a completely
    # cached instance of the same ID or to compare a modified object with the
    # copy that was cached before.
    #
    # @see #cache_ids
    def cached_instance
      ids = cache_ids
      cached = self.class.send(:cache).find { |id, object| ids.include? id}
      cached.nil? ? nil : cached.last
    end

    # Returns a complete list of all values for the cache IDs of the cacheable
    # object
    #
    # @return [Array<Object, Array<Object>>] The values for the cache IDs
    # @see #cache_id_value
    def cache_ids
      values = lambda do |id|
        id.is_a?(Array) ? id.map(&values) : cache_id_value(id)
      end

      self.class.send(:cache_ids).map &values
    end

    # Returns the value for the ID
    #
    # @param [Symbol] id The name of an instance variable
    # @return [Object] The value of the given instance variable
    def cache_id_value(id)
      instance_variable_get "@#{id}".to_sym
    end

  end
end
