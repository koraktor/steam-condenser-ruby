# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'steam/community/steam_id'

class TestSteamId < Test::Unit::TestCase

  context 'The SteamId class' do

    should 'provide a conversion between 64bit Steam IDs and STEAM_IDs' do
      steam_id = SteamId.convert_community_id_to_steam_id 76561197960290418
      assert_equal 'STEAM_0:0:12345', steam_id
    end

    should 'provide a conversion between STEAM_IDs and 64bit Steam IDs' do
      steam_id64 = SteamId.convert_steam_id_to_community_id 'STEAM_0:0:12345'
      assert_equal 76561197960290418, steam_id64
    end

  end

  context 'A Steam ID' do

    should 'be correctly cached' do
      assert_not SteamId.cached? 76561197983311154

      steam_id = SteamId.new 76561197983311154, false

      assert steam_id.cache
      assert SteamId.cached? 76561197983311154
    end

    should 'be correctly cached with its custom URL' do
      assert_not SteamId.cached? 'Son_of_Thor'

      steam_id = SteamId.new 'Son_of_Thor', false

      assert steam_id.cache
      assert SteamId.cached? 'son_of_Thor'
    end

    should 'be able to fetch its data' do
      url = mock :read => fixture('sonofthor.xml')
      SteamId.any_instance.expects(:open).with('http://steamcommunity.com/id/son_of_thor?xml=1', { :proxy => true }).returns url

      steam_id = SteamId.new 'Son_of_Thor'

      assert_equal 76561197983311154, steam_id.steam_id64
      assert steam_id.fetched?
    end

    should 'be found by the 64bit SteamID' do
      steam_id = SteamId.new 76561197983311154, false

      assert_equal 76561197983311154, steam_id.steam_id64
      assert_equal 'http://steamcommunity.com/profiles/76561197983311154', steam_id.base_url
    end

    should 'be found by the SteamID\'s custom URL' do
      steam_id = SteamId.new 'Son_of_Thor', false

      assert_equal 'son_of_thor', steam_id.custom_url
      assert_equal 'http://steamcommunity.com/id/son_of_thor', steam_id.base_url
    end

    should 'raise an exception when parsing invalid XML' do
      error = assert_raises SteamCondenserError do
        url = mock :read => fixture('invalid.xml')
        SteamId.any_instance.expects(:open).with('http://steamcommunity.com/id/son_of_thor?xml=1', { :proxy => true }).returns url

        SteamId.new 'Son_of_Thor'
      end
      assert_equal 'XML data could not be parsed.', error.message
    end

    teardown do
      SteamId.clear_cache
    end

  end

end
