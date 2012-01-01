# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'helper'
require 'steam/community/cacheable'

class TestCacheable < Test::Unit::TestCase

  class SingleCacheable
    include SteamCondenser::Cacheable
    cacheable_with_ids :first_id, :second_id

    def initialize
      @first_id, @second_id = 1, '2'
    end

    def fetch
    end
  end

  class CompoundCacheable
    include SteamCondenser::Cacheable
    cacheable_with_ids [:first_id, :second_id]

    def initialize
      @first_id, @second_id = 1, '2'
    end

    def fetch
    end
  end

  context 'A cacheable' do

    should 'know if it was fetched already' do
      item = SingleCacheable.new false
      assert_not item.fetched?
      item.fetch
      assert item.fetched?
    end

    should 'automatically update its last update time' do
      item = SingleCacheable.new false
      now1 = Time.now
      item.fetch
      assert item.fetch_time > now1
      now2 = Time.now
      item.fetch
      assert item.fetch_time > now2
    end

    should 'load new instances of the same item from cache' do
      item1 = SingleCacheable.new
      item2 = SingleCacheable.new
      assert_equal item1, item2
    end

    should 'be able to bypass the cache if requested' do
      item1 = SingleCacheable.new
      item2 = SingleCacheable.new true, true

      assert item2.fetch_time > item1.fetch_time
      assert_not_equal item1, item2
    end

    teardown do
      SingleCacheable.clear_cache
      CompoundCacheable.clear_cache
    end

  end

  context 'A cacheable with one or more single IDs' do

    should 'be cached once for each ID' do
      item = SingleCacheable.new
      cache = SingleCacheable.send :class_variable_get, :@@cache

      assert_equal item, cache[1]
      assert_equal item, cache['2']
      assert_equal 2, cache.size
    end

  end

  context 'A cacheable with compound IDs' do

    should 'be cached once for each compound ID' do
      item = CompoundCacheable.new
      cache = CompoundCacheable.send :class_variable_get, :@@cache

      assert_equal item, cache[[1, '2']]
      assert_equal 1, cache.size
    end

  end

end
