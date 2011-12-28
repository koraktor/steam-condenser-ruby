# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'steam/community/steam_group'

class TestSteamGroup < Test::Unit::TestCase

  context 'A Steam group' do

    should 'be correctly cached' do
      assert_not SteamGroup.cached? 103582791429521412

      group = SteamGroup.new 103582791429521412, false

      assert group.cache
      assert SteamGroup.cached? 103582791429521412
    end

    should 'be correctly cached with its custom URL' do
      assert_not SteamGroup.cached? 'valve'

      group = SteamGroup.new 'valve', false

      assert group.cache
      assert SteamGroup.cached? 'valve'
    end

    should 'be able to fetch its members' do
      url = mock :read => fixture('valve-members.xml')
      SteamGroup.any_instance.expects(:open).with('http://steamcommunity.com/groups/valve/memberslistxml?p=1', { :proxy => true }).returns url

      group = SteamGroup.new 'valve'
      members = group.members

      assert_equal 221, group.member_count
      assert_equal 76561197960265740, members.first.steam_id64
      assert_not members.first.fetched?
      assert_equal 76561197970323416, members.last.steam_id64
      assert group.fetched?
    end

    should 'be found by the group ID' do
      group = SteamGroup.new 103582791429521412, false

      assert_equal 103582791429521412, group.group_id64
      assert_equal 'http://steamcommunity.com/gid/103582791429521412', group.base_url
    end

    should 'be found by the group\'s custom URL' do
      group = SteamGroup.new 'valve', false

      assert_equal 'valve', group.custom_url
      assert_equal 'http://steamcommunity.com/groups/valve', group.base_url
    end

    should 'raise an exception when parsing invalid XML' do
      error = assert_raises SteamCondenserError do
        url = mock :read => fixture('invalid.xml')
        SteamGroup.any_instance.expects(:open).with('http://steamcommunity.com/groups/valve/memberslistxml?p=1', { :proxy => true }).returns url

        SteamGroup.new 'valve'
      end
      assert_equal 'XML data could not be parsed.', error.message
    end

    should 'be able to parse just the member count' do
      url = mock :read => fixture('valve-members.xml')
      SteamGroup.any_instance.expects(:open).with('http://steamcommunity.com/groups/valve/memberslistxml?p=1', { :proxy => true }).returns url

      group = SteamGroup.new 'valve', false
      assert_equal 221, group.member_count
    end

    teardown do
      SteamGroup.clear_cache
    end

  end

end
