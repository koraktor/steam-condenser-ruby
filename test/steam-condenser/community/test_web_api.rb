# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestWebApi < Test::Unit::TestCase

  context 'The Web API' do

    setup do
      Community::WebApi.api_key = '0123456789ABCDEF0123456789ABCDEF'
    end

    should 'allow access to the API key' do
      assert_equal '0123456789ABCDEF0123456789ABCDEF', Community::WebApi.api_key
    end

    should 'allow to set the API key' do
      Community::WebApi.api_key = 'FEDCBA9876543210FEDCBA9876543210'

      assert_equal 'FEDCBA9876543210FEDCBA9876543210', Community::WebApi.api_key
    end

    should 'fail to set an invalid API key' do
      error = assert_raises Error::WebApi do
        Community::WebApi.api_key = 'test'
      end
      assert_equal 'This is not a valid Steam Web API key.', error.message
    end

    should 'provide easy access to parsed JSON data' do
      data = mock
      Community::WebApi.expects(:get).with(:json, 'interface', 'method', 2, test: 'param').
        returns data
      MultiJson.expects(:load).with(data, { symbolize_keys: true }).
        returns({ result: { status: 1 }})

      assert_equal({ result: { status: 1 }}, Community::WebApi.json('interface', 'method', 2, test: 'param'))
    end

    should 'provide easy access to parsed and checked JSON data' do
      Community::WebApi.expects(:json).with('interface', 'method', 2, test: 'param').
        returns({ result: { status: 1 }})

      assert_equal({ status: 1 }, Community::WebApi.json!('interface', 'method', 2, test: 'param'))
    end

    should 'raise an error if the checked JSON data is an error message' do
      Community::WebApi.expects(:json).with('interface', 'method', 2, test: 'param').
        returns({ result: { status: 2, statusDetail: 'error' } })

      error = assert_raises Error::WebApi do
        Community::WebApi.json! 'interface', 'method', 2, test: 'param'
      end
      assert_equal 'The Web API request failed with the following error: error (status code: 2).', error.message
    end

    should 'load data from the Steam Community Web API' do
      data = mock read: 'data'
      Community::URI.expects(:open).with do |url, options|
        options == { proxy: true, 'Content-Type' => 'application/x-www-form-urlencoded' } &&
        url.start_with?('https://api.steampowered.com/interface/method/v2/?') &&
        (url.split('?').last.split('&') & %w{test=param format=json key=0123456789ABCDEF0123456789ABCDEF}).size == 3
      end.returns data

      assert_equal 'data', Community::WebApi.get(:json, 'interface', 'method', 2, test: 'param')
    end

    should 'load data from the Steam Community Web API without an API key' do
      Community::WebApi.api_key = nil

      data = mock read: 'data'
      Community::URI.expects(:open).with do |url, options|
        options == { proxy: true, 'Content-Type' => 'application/x-www-form-urlencoded' } &&
        url.start_with?('https://api.steampowered.com/interface/method/v2/?') &&
        (url.split('?').last.split('&') & %w{test=param format=json}).size == 2
      end.returns data

      assert_equal 'data', Community::WebApi.get(:json, 'interface', 'method', 2, test: 'param')
    end

    should 'handle unauthorized access error when loading data' do
      io = mock status: [401]
      http_error = OpenURI::HTTPError.new '', io
      Community::URI.expects(:open).raises http_error

      error = assert_raises Error::WebApi do
        Community::WebApi.get :json, 'interface', 'method', 2, test: 'param'
      end
      assert_equal 'Your Web API request has been rejected. You most likely did not specify a valid Web API key.', error.message
    end

    should 'handle generic HTTP errors when loading data' do
      io = mock status: [[404, 'Not found']]
      http_error = OpenURI::HTTPError.new '', io
      Community::URI.expects(:open).raises http_error

      error = assert_raises Error::WebApi do
        Community::WebApi.get :json, 'interface', 'method', 2, test: 'param'
      end
      assert_equal 'The Web API request has failed due to an HTTP error: Not found (status code: 404).', error.message
    end

    should 'use insecure HTTP if set' do
      Community::WebApi.secure = false

      data = mock read: 'data'
      Community::URI.expects(:open).with do |url, options|
        options == { proxy: true, 'Content-Type' => 'application/x-www-form-urlencoded' } &&
        url.start_with?('http://api.steampowered.com/interface/method/v2/?') &&
        (url.split('?').last.split('&') & %w{test=param format=json key=0123456789ABCDEF0123456789ABCDEF}).size == 3
      end.returns data

      assert_equal 'data', Community::WebApi.get(:json, 'interface', 'method', 2, test: 'param')
    end

  end

end
