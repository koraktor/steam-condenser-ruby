# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2015, Sebastian Staudt

require 'helper'

class TestGoldSrcServer < Test::Unit::TestCase

  context 'The user' do

    should 'be able to get a master server for GoldSrc servers' do
      master = mock
      Servers::MasterServer.expects(:new).
        with(*Servers::MasterServer::GOLDSRC_MASTER_SERVER).
        returns master

      assert_equal master, Servers::GoldSrcServer.master
    end

  end

  context 'A GoldSrc server' do

    setup do
      Socket.stubs(:getaddrinfo).
        with('goldsrc', 27015, Socket::AF_INET, Socket::SOCK_DGRAM).
        returns [[nil, nil, 'goldsrc', '127.0.0.1']]

      @server = Servers::GoldSrcServer.new 'goldsrc', 27015
    end

    should 'create a client socket upon initialization' do
      socket = mock
      Servers::Sockets::GoldSrcSocket.expects(:new).with('127.0.0.1', 27015, false).returns socket

      @server.init_socket

      assert_same socket, @server.instance_variable_get(:@socket)
    end

    should 'not save the RCON password if not authenticated successfully' do
      socket = mock
      socket.expects(:rcon_exec).with('password', '').raises Error::RCONNoAuth
      @server.instance_variable_set :@socket, socket

      assert_not @server.rcon_auth 'password'
      assert_not @server.rcon_authenticated?
      assert_nil @server.instance_variable_get(:@rcon_password)
    end

    should 'save the RCON password if authenticated successfully' do
      @server.expects(:rcon_exec).with('').returns ''

      assert @server.rcon_auth 'password'
      assert @server.rcon_authenticated?
      assert_equal 'password', @server.instance_variable_get(:@rcon_password)
    end

    should 'send RCON commands with the password' do
      socket = mock
      socket.expects(:rcon_exec).with('password', 'command').returns 'test '

      @server.instance_variable_set :@rcon_authenticated, true
      @server.instance_variable_set :@rcon_password, 'password'
      @server.instance_variable_set :@socket, socket

      assert_equal 'test', @server.rcon_exec('command')
    end

    should 'reset authentication if the server denies access' do
      socket = mock
      socket.expects(:rcon_exec).with('password', 'command').raises Error::RCONNoAuth
      @server.instance_variable_set :@rcon_authenticated, true
      @server.instance_variable_set :@rcon_password, 'password'
      @server.instance_variable_set :@socket, socket

      assert_raises Error::RCONNoAuth do
        @server.rcon_exec('command')
      end

      assert_not @server.rcon_authenticated?
    end

    should 'raise an error if sending RCON commands before authentication' do
      assert_raises Error::RCONNoAuth do
        @server.rcon_exec('command')
      end
    end

  end

end
