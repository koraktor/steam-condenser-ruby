# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2008-2012, Sebastian Staudt

require 'errors/steam_condenser_error'
require 'steam/community/cacheable'
require 'steam/community/steam_id'
require 'steam/community/xml_data'

# The SteamGroup class represents a group in the Steam Community
#
# @author Sebastian Staudt
module SteamCondenser
  class SteamGroup

    include Cacheable
    cacheable_with_ids :custom_url, :group_id64

    include XMLData

    # Returns the custom URL of this group
    #
    # The custom URL is a admin specified unique string that can be used instead
    # of the 64bit SteamID as an identifier for a group.
    #
    # @return [String] The custom URL of this group
    attr_reader :custom_url

    # Returns this group's 64bit SteamID
    #
    # @return [Fixnum] This group's 64bit SteamID
    attr_reader :group_id64

    # Creates a new `SteamGroup` instance for the group with the given ID
    #
    # @param [String, Fixnum] id The custom URL of the group specified by the
    #        group admin or the 64bit group ID
    # @macro cacheable
    def initialize(id)
      if id.is_a? Numeric
        @group_id64 = id
      else
        @custom_url = id.downcase
      end
      @members = []
    end

    # Returns the base URL for this group's page
    #
    # This URL is different for groups having a custom URL.
    #
    # @return [String] The base URL for this group
    def base_url
      if @custom_url.nil?
        "http://steamcommunity.com/gid/#@group_id64"
      else
        "http://steamcommunity.com/groups/#@custom_url"
      end
    end

    # Loads the members of this group
    #
    # This might take several HTTP requests as the Steam Community splits this
    # data over several XML documents if the group has lots of members.
    #
    # @see Cacheable#fetch
    def fetch
      if @member_count.nil? || @member_count == @members.size
        page = 0
      else
        page = 1
      end

      begin
        total_pages = fetch_page(page += 1)
      end while page < total_pages
    end

    # Returns the number of members this group has
    #
    # If the members have already been fetched the size of the member array is
    # returned. Otherwise the the first page of the member listing is fetched and
    # the member count and the first batch of members is stored.
    #
    # @return [Fixnum] The number of this group's members
    def member_count
      if @member_count.nil?
        total_pages = fetch_page(1)
        @fetch_time = Time.now if total_pages == 1
      end

      @member_count
    end

    # Returns the members of this group
    #
    # If the members haven't been fetched yet, this is done now.
    #
    # @return [Array<SteamId>] The Steam ID's of the members of this group
    # @see #fetch
    def members
      fetch if @members.size != @member_count
      @members
    end

    private

    # Fetches a specific page of the member listing of this group
    #
    # @param [Fixnum] page The member page to fetch
    # @return [Fixnum] The total number of pages of this group's member listing
    def fetch_page(page)
      member_data = parse "#{base_url}/memberslistxml?p=#{page}"

      begin
        @group_id64   = member_data['groupID64'].to_i if page == 1
        @member_count = member_data['memberCount'].to_i
        total_pages   = member_data['totalPages'].to_i

        member_data['members']['steamID64'].each do |member|
          @members << SteamId.new(member.to_i, false)
        end
      rescue
        raise SteamCondenserError, 'XML data could not be parsed.', $!.backtrace
      end

      total_pages
    end

  end
end
