# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'

class TestGoldSrcServer < Test::Unit::TestCase

  context 'The user' do

    should 'be able to get a master server for GoldSrc servers' do
      master = mock
      SteamCondenser::Servers::MasterServer.expects(:new).
        with(*SteamCondenser::Servers::MasterServer::GOLDSRC_MASTER_SERVER).
        returns master

      assert_equal master, SteamCondenser::Servers::GoldSrcServer.master
    end

  end

  context 'A GoldSrc server' do

    setup do
      Socket.stubs(:getaddrinfo).
        with('goldsrc', 27015, Socket::AF_INET, Socket::SOCK_DGRAM).
        returns [[nil, nil, 'goldsrc', '127.0.0.1']]

      @server = SteamCondenser::Servers::GoldSrcServer.new 'goldsrc', 27015
    end

    should 'create a client socket upon initialization' do
      socket = mock
      SteamCondenser::Servers::Sockets::GoldSrcSocket.expects(:new).with('127.0.0.1', 27015, false).returns socket

      @server.init_socket

      assert_same socket, @server.instance_variable_get(:@socket)
    end

    should 'save the RCON password for further use' do
      assert @server.rcon_auth 'password'
      assert_equal 'password', @server.instance_variable_get(:@rcon_password)
    end

    should 'send RCON commands with the password' do
      socket = mock
      socket.expects(:rcon_exec).with('password', 'command').returns 'test '

      @server.instance_variable_set :@rcon_password, 'password'
      @server.instance_variable_set :@socket, socket

      assert_equal 'test', @server.rcon_exec('command')
    end

  end

end
