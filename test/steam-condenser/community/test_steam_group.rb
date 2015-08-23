# encoding: utf-8
#
# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt

require 'helper'

class TestSteamGroup < Test::Unit::TestCase

  context 'A Steam group' do

    should 'be correctly cached' do
      assert_not Community::SteamGroup.cached? 103582791429521412

      group = Community::SteamGroup.new 103582791429521412, false

      assert group.cache
      assert Community::SteamGroup.cached? 103582791429521412
    end

    should 'be correctly cached with its custom URL' do
      assert_not Community::SteamGroup.cached? 'valve'

      group = Community::SteamGroup.new 'valve', false

      assert group.cache
      assert Community::SteamGroup.cached? 'valve'
    end

    should 'be able to fetch its members and properties' do
      url = fixture_io 'valve-members.xml'
      Community::SteamGroup.any_instance.expects(:open).with('http://steamcommunity.com/gid/103582791429521412/memberslistxml?p=1', proxy: true).returns url

      group = Community::SteamGroup.new 103582791429521412
      members = group.members

      assert_equal 'http://media.steampowered.com/steamcommunity/public/images/avatars/1d/1d8baf5a2b5968ae5ca65d7a971c02e222c9a17e_full.jpg', group.avatar_full_url
      assert_equal 'http://media.steampowered.com/steamcommunity/public/images/avatars/1d/1d8baf5a2b5968ae5ca65d7a971c02e222c9a17e.jpg', group.avatar_icon_url
      assert_equal 'http://media.steampowered.com/steamcommunity/public/images/avatars/1d/1d8baf5a2b5968ae5ca65d7a971c02e222c9a17e_medium.jpg', group.avatar_medium_url
      assert_equal 'Valve', group.custom_url
      assert_equal 'VALVE', group.headline
      assert_equal 239, group.member_count
      assert_equal 'Valve', group.name
      assert_equal 'In addition to producing best-selling entertainment titles, Valve is a developer of leading-edge technologies such as the Source™ game engine and Steam™, a broadband platform for the delivery and management of digital content.', group.summary

      assert_equal 76561197985607672, members.first.steam_id64
      assert_not members.first.fetched?
      assert_equal 76561198086572943, members.last.steam_id64

      assert group.fetched?
    end

    should 'be found by the group ID' do
      group = Community::SteamGroup.new 103582791429521412, false

      assert_equal 103582791429521412, group.group_id64
      assert_equal 'http://steamcommunity.com/gid/103582791429521412', group.base_url
    end

    should 'be found by the group\'s custom URL' do
      group = Community::SteamGroup.new 'valve', false

      assert_equal 'valve', group.custom_url
      assert_equal 'http://steamcommunity.com/groups/valve', group.base_url
    end

    should 'raise an exception when parsing invalid XML' do
      error = assert_raises Error do
        url = fixture_io 'invalid.xml'
        Community::SteamGroup.any_instance.expects(:open).with('http://steamcommunity.com/groups/valve/memberslistxml?p=1', proxy: true).returns url

        Community::SteamGroup.new 'valve'
      end
      assert_equal 'XML data could not be parsed.', error.message
    end

    should 'be able to parse just the member count' do
      url = fixture_io 'valve-members.xml'
      Community::SteamGroup.any_instance.expects(:open).with('http://steamcommunity.com/groups/valve/memberslistxml?p=1', proxy: true).returns url

      group = Community::SteamGroup.new 'valve', false
      assert_equal 239, group.member_count
    end

    teardown do
      Community::SteamGroup.clear_cache
    end

  end

end
