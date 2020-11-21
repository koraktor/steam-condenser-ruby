# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2020, Sebastian Staudt

require 'helper'

class TestQueryPacket < Test::Unit::TestCase

  class GenericQueryPacket
    include Servers::Packets::QueryPacket
  end

  context 'A query packet' do

    setup do
      @packet = GenericQueryPacket.new 0x61, 'test'
    end

    should 'pad its content to at least 1200 bytes' do
      assert_equal [255, 255, 255, 255, 'atest' + "\0" * 1191].pack('c4a*'), @packet.to_s
    end

  end

end