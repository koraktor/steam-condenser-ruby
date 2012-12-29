# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

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
      @last_match_stats = {}
      @total_stats      = {}

      @last_match_stats[:cost_per_kill]      = @xml_data['stats']['lastmatch']['costkill'].to_f
      @last_match_stats[:ct_wins]            = @xml_data['stats']['lastmatch']['ct_wins'].to_i
      @last_match_stats[:damage]             = @xml_data['stats']['lastmatch']['dmg'].to_i
      @last_match_stats[:deaths]             = @xml_data['stats']['lastmatch']['deaths'].to_i
      @last_match_stats[:dominations]        = @xml_data['stats']['lastmatch']['dominations'].to_i
      @last_match_stats[:favorite_weapon_id] = @xml_data['stats']['lastmatch']['favwpnid'].to_i
      @last_match_stats[:kills]              = @xml_data['stats']['lastmatch']['kills'].to_i
      @last_match_stats[:max_players]        = @xml_data['stats']['lastmatch']['max_players'].to_i
      @last_match_stats[:money]              = @xml_data['stats']['lastmatch']['money'].to_i
      @last_match_stats[:revenges]           = @xml_data['stats']['lastmatch']['revenges'].to_i
      @last_match_stats[:stars]              = @xml_data['stats']['lastmatch']['stars'].to_i
      @last_match_stats[:t_wins]             = @xml_data['stats']['lastmatch']['t_wins'].to_i
      @last_match_stats[:wins]               = @xml_data['stats']['lastmatch']['wins'].to_i
      @total_stats[:blind_kills]             = @xml_data['stats']['lifetime']['blindkills'].to_i
      @total_stats[:bombs_defused]           = @xml_data['stats']['lifetime']['bombsdefused'].to_i
      @total_stats[:bombs_planted]           = @xml_data['stats']['lifetime']['bombsplanted'].to_i
      @total_stats[:damage]                  = @xml_data['stats']['lifetime']['dmg'].to_i
      @total_stats[:deaths]                  = @xml_data['stats']['summary']['deaths'].to_i
      @total_stats[:domination_overkills]    = @xml_data['stats']['lifetime']['dominationoverkills'].to_i
      @total_stats[:dominations]             = @xml_data['stats']['lifetime']['dominations'].to_i
      @total_stats[:earned_money]            = @xml_data['stats']['lifetime']['money'].to_i
      @total_stats[:enemy_weapon_kills]      = @xml_data['stats']['lifetime']['enemywpnkills'].to_i
      @total_stats[:headshots]               = @xml_data['stats']['lifetime']['headshots'].to_i
      @total_stats[:hits]                    = @xml_data['stats']['summary']['shotshit'].to_i
      @total_stats[:hostages_rescued]        = @xml_data['stats']['lifetime']['hostagesrescued'].to_i
      @total_stats[:kills]                   = @xml_data['stats']['summary']['kills'].to_i
      @total_stats[:knife_kills]             = @xml_data['stats']['lifetime']['knifekills'].to_i
      @total_stats[:logos_sprayed]           = @xml_data['stats']['lifetime']['decals'].to_i
      @total_stats[:nightvision_damage]      = @xml_data['stats']['lifetime']['nvgdmg'].to_i
      @total_stats[:pistol_rounds_won]       = @xml_data['stats']['lifetime']['pistolrounds'].to_i
      @total_stats[:revenges]                = @xml_data['stats']['lifetime']['revenges'].to_i
      @total_stats[:rounds_played]           = @xml_data['stats']['summary']['rounds'].to_i
      @total_stats[:rounds_won]              = @xml_data['stats']['summary']['wins'].to_i
      @total_stats[:seconds_played]          = @xml_data['stats']['summary']['timeplayed'].to_i
      @total_stats[:shots]                   = @xml_data['stats']['summary']['shots'].to_i
      @total_stats[:stars]                   = @xml_data['stats']['summary']['stars'].to_i
      @total_stats[:weapons_donated]         = @xml_data['stats']['lifetime']['wpndonated'].to_i
      @total_stats[:windows_broken]          = @xml_data['stats']['lifetime']['winbroken'].to_i
      @total_stats[:zoomed_sniper_kills]     = @xml_data['stats']['lifetime']['zsniperkills'].to_i

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
