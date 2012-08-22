# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'

class TestBaseSocket < Test::Unit::TestCase

  class GenericSocket
    include SteamCondenser::Servers::Sockets::BaseSocket
  end

  context 'The user timeout of a socket' do

    should 'be able to change the timeout of a socket' do
      SteamCondenser::Servers::Sockets::BaseSocket.timeout = 2000

      assert_equal 2000, SteamCondenser::Servers::Sockets::BaseSocket.send(:class_variable_get, :@@timeout)
    end

  end

  context 'A new socket' do

    should 'create and connect an UDP socket' do
      socket = mock
      socket.expects(:connect).with '127.0.0.1', 27015
      UDPSocket.expects(:new).returns socket

      GenericSocket.new '127.0.0.1'
    end

  end

  context 'A socket' do

    setup do
      @udp_socket = mock
      @udp_socket.stubs(:connect).with '127.0.0.1', 27015
      UDPSocket.stubs(:new).returns @udp_socket

      @socket = GenericSocket.new '127.0.0.1'
    end

    should 'close the UDP socket if it is closed' do
      @udp_socket.expects :close

      @socket.close
    end

    should 'send packet data using the UDP socket' do
      packet = mock
      packet.expects(:to_s).returns 'test'
      @udp_socket.expects(:send).with 'test', 0

      @socket.send packet
    end

    should 'raise a timeout if no reply is received' do
      @socket.expects(:select).with([@udp_socket], nil, nil, 1).returns nil

      assert_raises SteamCondenser::Error::Timeout do
        @socket.receive_packet
      end
    end

    should 'receive a packet into a new buffer' do
      @socket.expects(:select).with([@udp_socket], nil, nil, 1).returns true
      @udp_socket.expects(:recv).with(4).returns 'test'

      assert_equal 4, @socket.receive_packet(4)

      buffer = @socket.instance_variable_get :@buffer
      assert_equal 0, buffer.pos
      assert_equal 4, buffer.size
      assert_equal 'test', buffer.string
    end

    should 'receive a packet into an existing buffer' do
      @socket.instance_variable_set :@buffer, StringIO.alloc(10)

      @socket.expects(:select).with([@udp_socket], nil, nil, 1).returns true
      @udp_socket.expects(:recv).with(10).returns 'test'

      assert_equal 4, @socket.receive_packet

      buffer = @socket.instance_variable_get :@buffer
      assert_equal 0, buffer.pos
      assert_equal 4, buffer.size
      assert_equal 'test', buffer.string
    end

  end

end
