# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2013, Sebastian Staudt

require 'steam-condenser/community/game_stats'
require 'steam-condenser/community/alien_swarm/alien_swarm_mission'
require 'steam-condenser/community/alien_swarm/alien_swarm_weapon'

module SteamCondenser::Community

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
    WEAPONS = %w(Autogun Cannon_Sentry Chainsaw Flamer Grenade_Launcher
                 Hand_Grenades Hornet_Barrage Incendiary_Sentry Laser_Mines
                 Marskman_Rifle Minigun Mining_Laser PDW Pistol Prototype_Rifle
                 Rail_Rifle Rifle Rifle_Grenade Sentry_Gun Shotgun Tesla_Cannon
                 Vindicator Vindicator_Grenade)

    # Creates a new `AlienSwarmStats` instance by calling the super constructor
    # with the game name `'alienswarm'`
    #
    # @param [String, Fixnum] steam_id The custom URL or the 64bit Steam ID of
    #        the user
    # @macro cacheable
    def initialize(steam_id)
      super steam_id, 'alienswarm'

      if public?
        lifetime_data = @xml_data['stats']['lifetime']

        @hours_played = lifetime_data['timeplayed']

        @lifetime_stats = {
          :accuracy                    => lifetime_data['accuracy'].to_f,
          :aliens_burned               => lifetime_data['aliensburned'].to_i,
          :aliens_killed               => lifetime_data['alienskilled'].to_i,
          :campaigns                   => lifetime_data['campaigns'].to_i,
          :damage_taken                => lifetime_data['damagetaken'].to_i,
          :experience                  => lifetime_data['experience'].to_i,
          :experience_required         => lifetime_data['xprequired'].to_i,
          :fast_hacks                  => lifetime_data['fasthacks'].to_i,
          :friendly_fire               => lifetime_data['friendlyfire'].to_i,
          :games_successful            => lifetime_data['gamessuccess'].to_i,
          :healing                     => lifetime_data['healing'].to_i,
          :kills_per_hour              => lifetime_data['killsperhour'].to_f,
          :level                       => lifetime_data['level'].to_i,
          :promotion                   => lifetime_data['promotion'].to_i,
          :next_unlock                 => lifetime_data['nextunlock'],
          :next_unlock_img             => BASE_URL + lifetime_data['nextunlockimg'],
          :shots_fired                 => lifetime_data['shotsfired'].to_i,
          :total_games                 => lifetime_data['totalgames'].to_i,
          :games_successful_percentage => (@lifetime_stats[:total_games] > 0) ? @lifetime_stats[:games_successful].to_f / @lifetime_stats[:total_games] : 0
        }

        @lifetime_stats[:promotion_img] = BASE_URL + lifetime_data['promotionpic'] if @lifetime_stats[:promotion] > 0
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
        favorites_data = @xml_data['stats']['favorites']

        @favorites = {
          :class                       => favorites_data['class'],
          :class_img                   => favorites_data['classimg'],
          :class_percentage            => favorites_data['classpct'].to_f,
          :difficulty                  => favorites_data['difficulty'],
          :difficulty_percentage       => favorites_data['difficultypct'].to_f,
          :extra                       => favorites_data['extra'],
          :extra_img                   => favorites_data['extraimg'],
          :extra_percentage            => favorites_data['extrapct'].to_f,
          :marine                      => favorites_data['marine'],
          :marine_img                  => favorites_data['marineimg'],
          :marine_percentage           => favorites_data['marinepct'].to_f,
          :mission                     => favorites_data['mission'],
          :mission_img                 => favorites_data['missionimg'],
          :mission_percentage          => favorites_data['missionpct'].to_f,
          :primary_weapon              => favorites_data['primary'],
          :primary_weapon_img          => favorites_data['primaryimg'],
          :primary_weapon_percentage   => favorites_data['primarypct'].to_f,
          :secondary_weapon            => favorites_data['secondary'],
          :secondary_weapon_img        => favorites_data['secondaryimg'],
          :secondary_weapon_percentage => favorites_data['secondarypct'].to_f
        }
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
        weapons_data = @xml_data['stats']['weapons']

        @item_stats = {
          :ammo_deployed             => weapons_data['ammo_deployed'].to_i,
          :sentryguns_deployed       => weapons_data['sentryguns_deployed'].to_i,
          :sentry_flamers_deployed   => weapons_data['sentry_flamers_deployed'].to_i,
          :sentry_freeze_deployed    => weapons_data['sentry_freeze_deployed'].to_i,
          :sentry_cannon_deployed    => weapons_data['sentry_cannon_deployed'].to_i,
          :medkits_used              => weapons_data['medkits_used'].to_i,
          :flares_used               => weapons_data['flares_used'].to_i,
          :adrenaline_used           => weapons_data['adrenaline_used'].to_i,
          :tesla_traps_deployed      => weapons_data['tesla_traps_deployed'].to_i,
          :freeze_grenades_thrown    => weapons_data['freeze_grenades_thrown'].to_i,
          :electric_armor_used       => weapons_data['electric_armor_used'].to_i,
          :healgun_heals             => weapons_data['healgun_heals'].to_i,
          :healgun_heals_self        => weapons_data['healgun_heals_self'].to_i,
          :healbeacon_heals          => weapons_data['healbeacon_heals'].to_i,
          :healbeacon_heals_self     => weapons_data['healbeacon_heals_self'].to_i,
          :damage_amps_used          => weapons_data['damage_amps_used'].to_i,
          :healbeacons_deployed      => weapons_data['healbeacons_deployed'].to_i,
          :healbeacon_heals_pct      => weapons_data['healbeacon_heals_pct'].to_f,
          :healgun_heals_pct         => weapons_data['healgun_heals_pct'].to_f,
          :healbeacon_heals_pct_self => weapons_data['healbeacon_heals_pct_self'].to_f,
          :healgun_heals_pct_self    => weapons_data['healgun_heals_pct_self'].to_f
        }
      end

      @item_stats
    end

    # Returns the stats for individual missions for this user containing all
    # Alien Swarm missions
    #
    # If the mission stats haven't been parsed already, parsing is done now.
    #
    # @return [Hash<String, AlienSwarmMission>] The mission stats for this
    #         player
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
end
