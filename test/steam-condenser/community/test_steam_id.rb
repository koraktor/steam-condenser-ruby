# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestSteamId < Test::Unit::TestCase

  context 'The Community::SteamId class' do

    should 'be able to resolve vanity URLs' do
      Community::WebApi.expects(:json).
        with('ISteamUser', 'ResolveVanityURL', 1, { :vanityurl => 'koraktor' }).
        returns({ response: { success: 1, steamid: 76561197961384956 } })

      steam_id64 = Community::SteamId.resolve_vanity_url 'koraktor'
      assert_equal 76561197961384956, steam_id64
    end

    should 'be return nil when not able to resolve a vanity URL' do
      Community::WebApi.expects(:json).
        with('ISteamUser', 'ResolveVanityURL', 1, { :vanityurl => 'unknown' }).
        returns({ response: { success: 42 } })

      assert_nil Community::SteamId.resolve_vanity_url 'unknown'
    end

    should 'provide a conversion between 64bit Steam IDs and STEAM_IDs' do
      steam_id = Community::SteamId.community_id_to_steam_id 76561197960290418
      assert_equal 'STEAM_0:0:12345', steam_id
    end

    should 'provide a conversion between 64bit Steam IDs and STEAM_ID_3s' do
      steam_id = Community::SteamId.community_id_to_steam_id3 76561197960497430
      assert_equal '[U:1:231702]', steam_id

      steam_id = Community::SteamId.community_id_to_steam_id3 76561197998273743
      assert_equal '[U:1:38008015]', steam_id

      steam_id = Community::SteamId.community_id_to_steam_id3 76561198000009691
      assert_equal '[U:1:39743963]', steam_id
    end

    should 'provide a conversion between STEAM_IDs and 64bit Steam IDs' do
      steam_id64 = Community::SteamId.steam_id_to_community_id 'STEAM_0:0:12345'
      assert_equal 76561197960290418, steam_id64
    end

    should 'provide a conversion between U_IDs and 64bit Steam IDs' do
      steam_id64 = Community::SteamId.steam_id_to_community_id '[U:1:12345]'
      assert_equal 76561197960278073, steam_id64

      steam_id64 = Community::SteamId.steam_id_to_community_id '[U:1:39743963]'
      assert_equal 76561198000009691, steam_id64
    end

  end

  context 'A Steam ID' do

    should 'be correctly cached' do
      assert_not Community::SteamId.cached? 76561197983311154

      steam_id = Community::SteamId.new 76561197983311154, false

      assert steam_id.cache
      assert Community::SteamId.cached? 76561197983311154
    end

    should 'be correctly cached with its custom URL' do
      assert_not Community::SteamId.cached? 'Son_of_Thor'

      steam_id = Community::SteamId.new 'Son_of_Thor', false

      assert steam_id.cache
      assert Community::SteamId.cached? 'son_of_Thor'
    end

    should 'have an ID' do
      steam_id1 = Community::SteamId.new 76561197983311154, false
      steam_id2 = Community::SteamId.new 'Son_of_Thor', false

      assert_equal 76561197983311154, steam_id1.id
      assert_equal 'son_of_thor', steam_id2.id
    end

    should 'be able to fetch its data' do
      url = fixture_io 'sonofthor.xml'
      Community::SteamId.any_instance.expects(:open).with('http://steamcommunity.com/id/son_of_thor?xml=1', { :proxy => true }).returns url

      steam_id = Community::SteamId.new 'Son_of_Thor'

      assert_equal 76561197983311154, steam_id.steam_id64
      assert_equal 'son_of_thor', steam_id.custom_url
      assert_equal 'Bellevue, Washington, United States', steam_id.location
      assert_equal 'Dad serious.', steam_id.head_line
      assert_equal 'Son of Thor', steam_id.nickname
      assert_equal 'Torsten Zabka', steam_id.real_name
      assert_equal 'Last Online: 3 days ago', steam_id.state_message
      assert_equal 'We jump that fence when we get to it.', steam_id.summary
      assert_equal 'None', steam_id.trade_ban_state

      assert_equal 'http://media.steampowered.com/steamcommunity/public/images/avatars/b8/b8438d91481295b7cc8da9578004cd63a2c3b2e4_full.jpg', steam_id.full_avatar_url
      assert_equal 'http://media.steampowered.com/steamcommunity/public/images/avatars/b8/b8438d91481295b7cc8da9578004cd63a2c3b2e4.jpg', steam_id.icon_url
      assert_equal 'http://media.steampowered.com/steamcommunity/public/images/avatars/b8/b8438d91481295b7cc8da9578004cd63a2c3b2e4_medium.jpg', steam_id.medium_avatar_url

      assert_not steam_id.banned?
      assert_not steam_id.limited?
      assert_not steam_id.online?
      assert steam_id.fetched?

      assert steam_id.public?
    end

    should 'be able to query its Steam level' do
      steam_id = Community::SteamId.new 76561197983311154, false

      steam_id.expects(:update_steam_level).returns 10

      assert_equal 10, steam_id.steam_level
    end

    should 'be able to return its Steam level' do
      steam_id = Community::SteamId.new 76561197983311154, false

      steam_id.instance_variable_set :@steam_level, 10
      steam_id.expects(:update_steam_level).never

      assert_equal 10, steam_id.steam_level
    end

    should 'be able to update its Steam level' do
      steam_id = Community::SteamId.new 76561197983311154, false

      Community::WebApi.expects(:json).
        with('IPlayerService', 'GetSteamLevel', 1, { :steamid => 76561197983311154 }).
        returns({ :response => { :player_level => 10 }})

      assert_equal 10, steam_id.update_steam_level
      assert_equal 10, steam_id.instance_variable_get(:@steam_level)
    end

    should 'be found by the 64bit Community::SteamId' do
      steam_id = Community::SteamId.new 76561197983311154, false

      assert_equal 76561197983311154, steam_id.steam_id64
      assert_equal 'http://steamcommunity.com/profiles/76561197983311154', steam_id.base_url
    end

    should 'be found by the Community::SteamId\'s custom URL' do
      steam_id = Community::SteamId.new 'Son_of_Thor', false

      assert_equal 'son_of_thor', steam_id.custom_url
      assert_equal 'http://steamcommunity.com/id/son_of_thor', steam_id.base_url
    end

    should 'raise an exception when parsing invalid XML' do
      error = assert_raises Error do
        url = fixture_io 'invalid.xml'
        Community::SteamId.any_instance.expects(:open).with('http://steamcommunity.com/id/son_of_thor?xml=1', { :proxy => true }).returns url

        Community::SteamId.new 'Son_of_Thor'
      end
      assert_equal 'XML data could not be parsed.', error.message
    end

    should 'not cache an empty hash when an error is encountered on steam' do
      Community::WebApi.expects(:json).raises SteamCondenser::Error::WebApi.new('tesst')
      steam_id = Community::SteamId.new 76561197983311154, false

      assert_raises SteamCondenser::Error::WebApi do
        steam_id.games
      end

      assert_equal nil, steam_id.instance_variable_get(:@games)
    end

    teardown do
      Community::SteamId.clear_cache
    end

  end

end
