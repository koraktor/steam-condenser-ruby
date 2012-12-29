# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'steam/community/alien_swarm/alien_swarm_mission'
require 'steam/community/alien_swarm/alien_swarm_weapon'

# This class represents the game statistics for a single user in Alien Swarm
#
# @author Sebastian Staudt
class AlienSwarmStats < GameStats

  # Returns general stats for the players
  #
  # @return [Hash<Symbol, Object>] The stats for the player
  attr_reader :lifetime_stats

  # The base URL for all images referenced in the stats
  BASE_URL = 'http://cdn.steamcommunity.com/public/images/gamestats/swarm/'

  # The names of all weapons in Alien Swarm
  WEAPONS = [ 'Autogun', 'Cannon_Sentry', 'Chainsaw', 'Flamer',
              'Grenade_Launcher', 'Hand_Grenades', 'Hornet_Barrage',
              'Incendiary_Sentry', 'Laser_Mines', 'Marskman_Rifle', 'Minigun',
              'Mining_Laser', 'PDW', 'Pistol', 'Prototype_Rifle', 'Rail_Rifle',
              'Rifle', 'Rifle_Grenade', 'Sentry_Gun', 'Shotgun',
              'Tesla_Cannon', 'Vindicator', 'Vindicator_Grenade' ]

  # Creates a new `AlienSwarmStats` instance by calling the super constructor
  # with the game name `'alienswarm'`
  #
  # @param [String, Fixnum] steam_id The custom URL or the 64bit Steam ID of
  #        the user
  # @macro cacheable
  def initialize(steam_id)
    super steam_id, 'alienswarm'

    if public?
      @hours_played = @xml_data['stats']['lifetime']['timeplayed']

      @lifetime_stats = {}
      @lifetime_stats[:accuracy]            = @xml_data['stats']['lifetime']['accuracy'].to_f
      @lifetime_stats[:aliens_burned]       = @xml_data['stats']['lifetime']['aliensburned'].to_i
      @lifetime_stats[:aliens_killed]       = @xml_data['stats']['lifetime']['alienskilled'].to_i
      @lifetime_stats[:campaigns]           = @xml_data['stats']['lifetime']['campaigns'].to_i
      @lifetime_stats[:damage_taken]        = @xml_data['stats']['lifetime']['damagetaken'].to_i
      @lifetime_stats[:experience]          = @xml_data['stats']['lifetime']['experience'].to_i
      @lifetime_stats[:experience_required] = @xml_data['stats']['lifetime']['xprequired'].to_i
      @lifetime_stats[:fast_hacks]          = @xml_data['stats']['lifetime']['fasthacks'].to_i
      @lifetime_stats[:friendly_fire]       = @xml_data['stats']['lifetime']['friendlyfire'].to_i
      @lifetime_stats[:games_successful]    = @xml_data['stats']['lifetime']['gamessuccess'].to_i
      @lifetime_stats[:healing]             = @xml_data['stats']['lifetime']['healing'].to_i
      @lifetime_stats[:kills_per_hour]      = @xml_data['stats']['lifetime']['killsperhour'].to_f
      @lifetime_stats[:level]               = @xml_data['stats']['lifetime']['level'].to_i
      @lifetime_stats[:promotion]           = @xml_data['stats']['lifetime']['promotion'].to_i
      @lifetime_stats[:promotion_img]       = BASE_URL + @xml_data['stats']['lifetime']['promotionpic'] if @lifetime_stats[:promotion] > 0
      @lifetime_stats[:next_unlock]         = @xml_data['stats']['lifetime']['nextunlock']
      @lifetime_stats[:next_unlock_img]     = BASE_URL + @xml_data['stats']['lifetime']['nextunlockimg']
      @lifetime_stats[:shots_fired]         = @xml_data['stats']['lifetime']['shotsfired'].to_i
      @lifetime_stats[:total_games]         = @xml_data['stats']['lifetime']['totalgames'].to_i

      @lifetime_stats[:games_successful_percentage] = (@lifetime_stats[:total_games] > 0) ? @lifetime_stats[:games_successful].to_f / @lifetime_stats[:total_games] : 0;
    end
  end

  # Returns the favorites of this user like weapons and marine
  #
  # If the favorites haven't been parsed already, parsing is done now.
  #
  # @return [Hash<Symbol, Object>] The favorites of this player
  def favorites
    return unless public?

    if @favorites.nil?
      @favorites = {}
      @favorites[:class]                       = @xml_data['stats']['favorites']['class']
      @favorites[:class_img]                   = @xml_data['stats']['favorites']['classimg']
      @favorites[:class_percentage]            = @xml_data['stats']['favorites']['classpct'].to_f
      @favorites[:difficulty]                  = @xml_data['stats']['favorites']['difficulty']
      @favorites[:difficulty_percentage]       = @xml_data['stats']['favorites']['difficultypct'].to_f
      @favorites[:extra]                       = @xml_data['stats']['favorites']['extra']
      @favorites[:extra_img]                   = @xml_data['stats']['favorites']['extraimg']
      @favorites[:extra_percentage]            = @xml_data['stats']['favorites']['extrapct'].to_f
      @favorites[:marine]                      = @xml_data['stats']['favorites']['marine']
      @favorites[:marine_img]                  = @xml_data['stats']['favorites']['marineimg']
      @favorites[:marine_percentage]           = @xml_data['stats']['favorites']['marinepct'].to_f
      @favorites[:mission]                     = @xml_data['stats']['favorites']['mission']
      @favorites[:mission_img]                 = @xml_data['stats']['favorites']['missionimg']
      @favorites[:mission_percentage]          = @xml_data['stats']['favorites']['missionpct'].to_f
      @favorites[:primary_weapon]              = @xml_data['stats']['favorites']['primary']
      @favorites[:primary_weapon_img]          = @xml_data['stats']['favorites']['primaryimg']
      @favorites[:primary_weapon_percentage]   = @xml_data['stats']['favorites']['primarypct'].to_f
      @favorites[:secondary_weapon]            = @xml_data['stats']['favorites']['secondary']
      @favorites[:secondary_weapon_img]        = @xml_data['stats']['favorites']['secondaryimg']
      @favorites[:secondary_weapon_percentage] = @xml_data['stats']['favorites']['secondarypct'].to_f
    end

    @favorites
  end

  # Returns the item stats for this user like ammo deployed and medkits
  # used
  #
  # If the items haven't been parsed already, parsing is done now.
  #
  # @return [Hash<Symbol, Object>] The item stats of this player
  def item_stats
    return unless public?

    if @item_stats.nil?
      @item_stats = {}
      @item_stats[:ammo_deployed]             = @xml_data['stats']['weapons']['ammo_deployed'].to_i
      @item_stats[:sentryguns_deployed]       = @xml_data['stats']['weapons']['sentryguns_deployed'].to_i
      @item_stats[:sentry_flamers_deployed]   = @xml_data['stats']['weapons']['sentry_flamers_deployed'].to_i
      @item_stats[:sentry_freeze_deployed]    = @xml_data['stats']['weapons']['sentry_freeze_deployed'].to_i
      @item_stats[:sentry_cannon_deployed]    = @xml_data['stats']['weapons']['sentry_cannon_deployed'].to_i
      @item_stats[:medkits_used]              = @xml_data['stats']['weapons']['medkits_used'].to_i
      @item_stats[:flares_used]               = @xml_data['stats']['weapons']['flares_used'].to_i
      @item_stats[:adrenaline_used]           = @xml_data['stats']['weapons']['adrenaline_used'].to_i
      @item_stats[:tesla_traps_deployed]      = @xml_data['stats']['weapons']['tesla_traps_deployed'].to_i
      @item_stats[:freeze_grenades_thrown]    = @xml_data['stats']['weapons']['freeze_grenades_thrown'].to_i
      @item_stats[:electric_armor_used]       = @xml_data['stats']['weapons']['electric_armor_used'].to_i
      @item_stats[:healgun_heals]             = @xml_data['stats']['weapons']['healgun_heals'].to_i
      @item_stats[:healgun_heals_self]        = @xml_data['stats']['weapons']['healgun_heals_self'].to_i
      @item_stats[:healbeacon_heals]          = @xml_data['stats']['weapons']['healbeacon_heals'].to_i
      @item_stats[:healbeacon_heals_self]     = @xml_data['stats']['weapons']['healbeacon_heals_self'].to_i
      @item_stats[:damage_amps_used]          = @xml_data['stats']['weapons']['damage_amps_used'].to_i
      @item_stats[:healbeacons_deployed]      = @xml_data['stats']['weapons']['healbeacons_deployed'].to_i
      @item_stats[:healbeacon_heals_pct]      = @xml_data['stats']['weapons']['healbeacon_heals_pct'].to_f
      @item_stats[:healgun_heals_pct]         = @xml_data['stats']['weapons']['healgun_heals_pct'].to_f
      @item_stats[:healbeacon_heals_pct_self] = @xml_data['stats']['weapons']['healbeacon_heals_pct_self'].to_f
      @item_stats[:healgun_heals_pct_self]    = @xml_data['stats']['weapons']['healgun_heals_pct_self'].to_f
    end

    @item_stats
  end

  # Returns the stats for individual missions for this user containing all
  # Alien Swarm missions
  #
  # If the mission stats haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, AlienSwarmMission>] The mission stats for this player
  def mission_stats
    return unless public?

    if @mission_stats.nil?
      @mission_stats = {}
      @xml_data['stats']['missions'].each do |mission_data|
        mission = AlienSwarmMission.new *mission_data
        @mission_stats[mission.name] = mission
      end
    end

    @mission_stats
  end

  # Returns the stats for individual weapons for this user containing all
  # Alien Swarm weapons
  #
  # If the weapon stats haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, AlienSwarmWeapon>] The weapon stats for this player
  def weapon_stats
    return unless public?

    if @weapon_stats.nil?
      @weapon_stats = {}
      WEAPONS.each do |weapon_node|
        weapon_data = @xml_data['stats']['weapons'][weapon_node]
        weapon = AlienSwarmWeapon.new(weapon_data)
        @weapon_stats[weapon.name] = weapon
      end
    end

    @weapon_stats
  end

end
