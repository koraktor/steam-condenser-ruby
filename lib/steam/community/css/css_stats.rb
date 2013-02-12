# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2013, Sebastian Staudt

require 'steam/community/css/css_map'
require 'steam/community/css/css_weapon'

# The is class represents the game statistics for a single user in
# Counter-Strike: Source
#
# @author Sebastian Staudt
class CSSStats < GameStats

  # The names of the maps in Counter-Strike: Source
  MAPS = [ 'cs_assault', 'cs_compound', 'cs_havana', 'cs_italy', 'cs_militia',
           'cs_office', 'de_aztec', 'de_cbble', 'de_chateau', 'de_dust',
           'de_dust2', 'de_inferno', 'de_nuke', 'de_piranesi', 'de_port',
           'de_prodigy', 'de_tides', 'de_train' ]

  # The names of the weapons in Counter-Strike: Source
  WEAPONS = [ 'deagle', 'usp', 'glock', 'p228', 'elite', 'fiveseven', 'awp',
              'ak47', 'm4a1', 'aug', 'sg552', 'sg550', 'galil', 'famas',
              'scout', 'g3sg1', 'p90', 'mp5navy', 'tmp', 'mac10', 'ump45',
              'm3', 'xm1014', 'm249', 'knife', 'grenade' ]

  # Returns statistics about the last match the player played
  #
  # @return [Hash<Symbol, Object>] The stats of the last match
  attr_reader :last_match_stats

  # Returns overall statistics of this player
  #
  # @return [Hash<Symbol, Object>] The overall statistics
  attr_reader :total_stats

  # Creates a `CSSStats` instance by calling the super constructor
  # with the game name `'cs:s'`
  #
  # @param [String, Fixnum] steam_id The custom URL or 64bit Steam ID of the
  #        user
  # @macro cacheable
  def initialize(steam_id)
    super steam_id, 'cs:s'

    if public?
      last_match_data = @xml_data['stats']['lastmatch']
      lifetime_data = @xml_data['stats']['lifetime']
      summary_data = @xml_data['stats']['summary']

      @last_match_stats = {}
      @total_stats      = {}

      @last_match_stats[:cost_per_kill]      = last_match_data['costkill'].to_f
      @last_match_stats[:ct_wins]            = last_match_data['ct_wins'].to_i
      @last_match_stats[:damage]             = last_match_data['dmg'].to_i
      @last_match_stats[:deaths]             = last_match_data['deaths'].to_i
      @last_match_stats[:dominations]        = last_match_data['dominations'].to_i
      @last_match_stats[:favorite_weapon_id] = last_match_data['favwpnid'].to_i
      @last_match_stats[:kills]              = last_match_data['kills'].to_i
      @last_match_stats[:max_players]        = last_match_data['max_players'].to_i
      @last_match_stats[:money]              = last_match_data['money'].to_i
      @last_match_stats[:revenges]           = last_match_data['revenges'].to_i
      @last_match_stats[:stars]              = last_match_data['stars'].to_i
      @last_match_stats[:t_wins]             = last_match_data['t_wins'].to_i
      @last_match_stats[:wins]               = last_match_data['wins'].to_i

      @total_stats[:blind_kills]             = lifetime_data['blindkills'].to_i
      @total_stats[:bombs_defused]           = lifetime_data['bombsdefused'].to_i
      @total_stats[:bombs_planted]           = lifetime_data['bombsplanted'].to_i
      @total_stats[:damage]                  = lifetime_data['dmg'].to_i
      @total_stats[:deaths]                  = summary_data['deaths'].to_i
      @total_stats[:domination_overkills]    = lifetime_data['dominationoverkills'].to_i
      @total_stats[:dominations]             = lifetime_data['dominations'].to_i
      @total_stats[:earned_money]            = lifetime_data['money'].to_i
      @total_stats[:enemy_weapon_kills]      = lifetime_data['enemywpnkills'].to_i
      @total_stats[:headshots]               = lifetime_data['headshots'].to_i
      @total_stats[:hits]                    = summary_data['shotshit'].to_i
      @total_stats[:hostages_rescued]        = lifetime_data['hostagesrescued'].to_i
      @total_stats[:kills]                   = summary_data['kills'].to_i
      @total_stats[:knife_kills]             = lifetime_data['knifekills'].to_i
      @total_stats[:logos_sprayed]           = lifetime_data['decals'].to_i
      @total_stats[:nightvision_damage]      = lifetime_data['nvgdmg'].to_i
      @total_stats[:pistol_rounds_won]       = lifetime_data['pistolrounds'].to_i
      @total_stats[:revenges]                = lifetime_data['revenges'].to_i
      @total_stats[:rounds_played]           = summary_data['rounds'].to_i
      @total_stats[:rounds_won]              = summary_data['wins'].to_i
      @total_stats[:seconds_played]          = summary_data['timeplayed'].to_i
      @total_stats[:shots]                   = summary_data['shots'].to_i
      @total_stats[:stars]                   = summary_data['stars'].to_i
      @total_stats[:weapons_donated]         = lifetime_data['wpndonated'].to_i
      @total_stats[:windows_broken]          = lifetime_data['winbroken'].to_i
      @total_stats[:zoomed_sniper_kills]     = lifetime_data['zsniperkills'].to_i

      @last_match_stats[:kdratio] = (@total_stats[:deaths] > 0) ? @last_match_stats[:kills].to_f / @last_match_stats[:deaths] : 0
      @total_stats[:accuracy]     = (@total_stats[:shots] > 0) ? @total_stats[:hits].to_f / @total_stats[:shots] : 0
      @total_stats[:kdratio]      = (@total_stats[:deaths] > 0) ? @total_stats[:kills].to_f / @total_stats[:deaths] : 0
      @total_stats[:rounds_lost]  = @total_stats[:rounds_played] - @total_stats[:rounds_won]
    end
  end

  # Returns a map of `CSSMap` for this user containing all CS:S maps.
  #
  # If the maps haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, Object>] The map statistics for this user
  def map_stats
    return unless public?

    if @map_stats.nil?
      @map_stats = {}
      maps_data = @xml_data['stats']['maps']

      MAPS.each do |map_name|
        @map_stats[map_name] = CSSMap.new(map_name, maps_data)
      end
    end

    @map_stats
  end

  # Returns a map of `CSSWeapon` for this user containing all CS:S weapons.
  #
  # If the weapons haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, Object>] The weapon statistics for this user
  def weapon_stats
    return unless public?

    if @weapon_stats.nil?
      @weapon_stats = {}
      weapons_data = @xml_data['stats']['weapons']

      WEAPONS.each do |weapon_name|
        @weapon_stats[weapon_name] = CSSWeapon.new(weapon_name, weapons_data)
      end
    end

    @weapon_stats
  end

end
