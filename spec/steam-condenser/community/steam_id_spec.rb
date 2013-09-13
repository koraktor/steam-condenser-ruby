# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt

require 'helper'

describe Community::SteamId do

  it 'should be able to resolve vanity URLs' do
    Community::WebApi.expects(:json).
      with('ISteamUser', 'ResolveVanityURL', 1, { :vanityurl => 'koraktor' }).
      returns({ response: { success: 1, steamid: 76561197961384956 } })

    steam_id64 = Community::SteamId.resolve_vanity_url 'koraktor'
    steam_id64.should eq(76561197961384956)
  end

  it 'should return nil when not able to resolve a vanity URL' do
    Community::WebApi.expects(:json).
      with('ISteamUser', 'ResolveVanityURL', 1, { :vanityurl => 'unknown' }).
      returns({ response: { success: 42 } })

    Community::SteamId.resolve_vanity_url('unknown').should be_nil
  end

  it 'should provide a conversion between 64bit Steam IDs and STEAM_IDs' do
    steam_id = Community::SteamId.community_id_to_steam_id 76561197960290418
    steam_id.should eq('STEAM_0:0:12345')
  end

  it 'should provide a conversion between STEAM_IDs and 64bit Steam IDs' do
    steam_id64 = Community::SteamId.steam_id_to_community_id 'STEAM_0:0:12345'
    steam_id64.should eq(76561197960290418)
  end

  it 'should provide a conversion between U_IDs and 64bit Steam IDs' do
    steam_id64 = Community::SteamId.steam_id_to_community_id '[U:1:12345]'
    steam_id64.should eq(76561197960278073)
  end

  it 'should be correctly cached' do
    Community::SteamId.cached?(76561197983311154).should be_false

    steam_id = Community::SteamId.new 76561197983311154, false

    steam_id.cache.should be_true
    Community::SteamId.cached?(76561197983311154).should be_true
  end

  it 'should be correctly cached with its custom URL' do
    Community::SteamId.cached?('Son_of_Thor').should be_false

    steam_id = Community::SteamId.new 'Son_of_Thor', false

    steam_id.cache.should be_true
    Community::SteamId.cached?('son_of_Thor').should be_true
  end

  it 'should have an ID' do
    steam_id1 = Community::SteamId.new 76561197983311154, false
    steam_id2 = Community::SteamId.new 'Son_of_Thor', false

    steam_id1.id.should eq(76561197983311154)
    steam_id2.id.should eq('son_of_thor')
  end

  it 'should be able to fetch its data' do
    url = fixture_io 'sonofthor.xml'
    Community::SteamId.any_instance.expects(:open).with('http://steamcommunity.com/id/son_of_thor?xml=1', { :proxy => true }).returns url

    steam_id = Community::SteamId.new 'Son_of_Thor'

    steam_id.steam_id64.should eq(76561197983311154)
    steam_id.custom_url.should eq('son_of_thor')
    steam_id.location.should eq('Bellevue, Washington, United States')
    steam_id.head_line.should eq('Dad serious.')
    steam_id.nickname.should eq('Son of Thor')
    steam_id.real_name.should eq('Torsten Zabka')
    steam_id.state_message.should eq('Last Online: 3 days ago')
    steam_id.summary.should eq('We jump that fence when we get to it.')
    steam_id.trade_ban_state.should eq('None')

    steam_id.full_avatar_url.should eq('http://media.steampowered.com/steamcommunity/public/images/avatars/b8/b8438d91481295b7cc8da9578004cd63a2c3b2e4_full.jpg')
    steam_id.icon_url.should eq('http://media.steampowered.com/steamcommunity/public/images/avatars/b8/b8438d91481295b7cc8da9578004cd63a2c3b2e4.jpg')
    steam_id.medium_avatar_url.should eq('http://media.steampowered.com/steamcommunity/public/images/avatars/b8/b8438d91481295b7cc8da9578004cd63a2c3b2e4_medium.jpg')

    steam_id.banned?.should be_false
    steam_id.limited?.should be_false
    steam_id.online?.should be_false
    steam_id.fetched?.should be_true

    steam_id.public?.should be_true
  end

  it 'should be able to query its Steam level' do
    steam_id = Community::SteamId.new 76561197983311154, false

    steam_id.expects(:update_steam_level).returns 10

    steam_id.steam_level.should eq(10)
  end

  it 'should be able to return its Steam level' do
    steam_id = Community::SteamId.new 76561197983311154, false

    steam_id.instance_variable_set :@steam_level, 10
    steam_id.expects(:update_steam_level).never

    steam_id.steam_level.should eq(10)
  end

  it 'should be able to update its Steam level' do
    steam_id = Community::SteamId.new 76561197983311154, false

    Community::WebApi.expects(:json).
      with('IPlayerService', 'GetSteamLevel', 1, { :steamid => 76561197983311154 }).
      returns({ :response => { :player_level => 10 }})

    steam_id.update_steam_level.should eq(10)
    steam_id.instance_variable_get(:@steam_level).should eq(10)
  end

  it 'should be found by the 64bit Community::SteamId' do
    steam_id = Community::SteamId.new 76561197983311154, false

    steam_id.steam_id64.should eq(76561197983311154)
    steam_id.base_url.should eq('http://steamcommunity.com/profiles/76561197983311154')
  end

  it 'should be found by the Community::SteamId\'s custom URL' do
    steam_id = Community::SteamId.new 'Son_of_Thor', false

    steam_id.custom_url.should eq('son_of_thor')
    steam_id.base_url.should eq('http://steamcommunity.com/id/son_of_thor')
  end

  it 'should raise an exception when parsing invalid XML' do
    -> {
      url = fixture_io 'invalid.xml'
      Community::SteamId.any_instance.expects(:open).with('http://steamcommunity.com/id/son_of_thor?xml=1', { :proxy => true }).returns url

      Community::SteamId.new 'Son_of_Thor'
    }.should raise_error(Error, 'XML data could not be parsed.')
  end

  it 'should not cache an empty hash when an error is encountered on steam' do
    Community::WebApi.expects(:json).raises SteamCondenser::Error::WebApi.new('tesst')
    steam_id = Community::SteamId.new 76561197983311154, false

    -> { steam_id.games }.should raise_error(SteamCondenser::Error::WebApi)

    steam_id.instance_variable_get(:@games).should be_nil
  end

  after do
    Community::SteamId.clear_cache
  end

end
