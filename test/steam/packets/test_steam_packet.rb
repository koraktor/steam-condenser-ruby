# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'helper'
require 'steam/packets/steam_packet'

class TestSteamPacket < Test::Unit::TestCase

  class GenericSteamPacket
    include SteamPacket
  end

  context 'A packet' do

    setup do
      @packet = GenericSteamPacket.new 0x61, 'test'
    end

    should 'have a data buffer' do
      data = @packet.instance_variable_get(:@content_data)
      assert_instance_of StringIO, data
      assert_equal 'test', data.string
    end

    should 'know its header' do
      assert_equal 0x61, @packet.instance_variable_get(:@header_data)
    end

    should 'have a valid byte representation' do
      assert_equal "\xFF\xFF\xFF\xFFatest", @packet.to_s
    end

  end

end
