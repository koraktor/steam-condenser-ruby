# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2013, Sebastian Staudt

require 'steam/community/l4d/abstract_l4d_stats'
require 'steam/community/l4d/l4d2_map'
require 'steam/community/l4d/l4d2_weapon'

# This class represents the game statistics for a single user in Left4Dead 2
#
# @author Sebastian Staudt
class L4D2Stats < GameStats

  include AbstractL4DStats

  # The names of the special infected in Left4Dead 2
  SPECIAL_INFECTED = SPECIAL_INFECTED + %w{charger jockey spitter}

  # Returns the percentage of damage done by this player with each weapon type
  #
  # Available weapon types are `:melee`, `:pistols`, `:rifles` and `:shotguns`.
  #
  # @return [Hash<Symbol, Float>] The percentages of damage done with each
  #         weapon type
  attr_reader :damage_percentages

  # Creates a `L4D2Stats` object by calling the super constructor with the game
  # name `'l4d2'`
  #
  # @param [String, Fixnum] steam_id The custom URL or 64bit Steam ID of the
  #        user
  # @macro cacheable
  def initialize(steam_id)
    super steam_id, 'l4d2'

    weapons_data = @xml_data['stats']['weapons']

    @damage_percentages = {
      :melee    => weapons_data['meleepctdmg'].to_f,
      :pistols  => weapons_data['pistolspctdmg'].to_f,
      :rifles   => weapons_data['bulletspctdmg'].to_f,
      :shotguns => weapons_data['shellspctdmg'].to_f
    }
  end

  # Returns a hash of lifetime statistics for this user like the time played
  #
  # If the lifetime statistics haven't been parsed already, parsing is done
  # now.
  #
  # There are only a few additional lifetime statistics for Left4Dead 2
  # which are not generated for Left4Dead, so this calls
  # {AbstractL4DStats#lifetime_stats} first and adds some additional stats.
  #
  # @return [Hash<String, Object>] The lifetime statistics of the player in
  #         Left4Dead 2
  def lifetime_stats
    return unless public?

    if @lifetime_stats.nil?
      super

      lifetime_data = @xml_data['stats']['lifetime']
      @lifetime_stats[:avg_adrenaline_shared]   = lifetime_data['adrenalineshared'].to_f
      @lifetime_stats[:avg_adrenaline_used]     = lifetime_data['adrenalineused'].to_f
      @lifetime_stats[:avg_defibrillators_used] = lifetime_data['defibrillatorsused'].to_f
    end

    @lifetime_stats
  end

  # Returns a hash of Scavenge statistics for this user like the number of
  # Scavenge rounds played
  #
  # If the Scavenge statistics haven't been parsed already, parsing is done
  # now.
  #
  # @return [Hash<String, Object>] The Scavenge statistics of the player
  def scavenge_stats
    return unless public?

    if @scavenge_stats.nil?
      scavange_data = @xml_data['stats']['scavenge']

      @scavenge_stats = {}
      @scavenge_stats[:avg_cans_per_round] = scavange_data['avgcansperround'].to_f
      @scavenge_stats[:perfect_rounds]     = scavange_data['perfect16canrounds'].to_i
      @scavenge_stats[:rounds_lost]        = scavange_data['roundslost'].to_i
      @scavenge_stats[:rounds_played]      = scavange_data['roundsplayed'].to_i
      @scavenge_stats[:rounds_won]         = scavange_data['roundswon'].to_i
      @scavenge_stats[:total_cans]         = scavange_data['totalcans'].to_i

      @scavenge_stats[:maps] = {}
      scavange_data['mapstats']['map'].each do |map_data|
        map_stats = {}
        map_stats['avg_round_score']     = map_data['avgscoreperround'].to_i
        map_stats['highest_game_score']  = map_data['highgamescore'].to_i
        map_stats['highest_round_score'] = map_data['highroundscore'].to_i
        map_stats['name']                = map_data['fullname']
        map_stats['rounds_played']       = map_data['roundsplayed'].to_i
        map_stats['rounds_won']          = map_data['roundswon'].to_i
        @scavenge_stats[:maps][map_data['name']] = map_stats

      end

      @scavenge_stats[:infected] = {}
      scavange_data['infectedstats']['special'].each do |infected_data|
        infected_stats = {}
        infected_stats['max_damage_per_life']   = infected_data['maxdmg1life'].to_i
        infected_stats['max_pours_interrupted'] = infected_data['maxpoursinterrupted'].to_i
        infected_stats['special_attacks']       = infected_data['specialattacks'].to_i
        @scavenge_stats[:infected][infected_data['name']] = infected_stats
      end
    end

    @scavenge_stats
  end

  # Returns a hash of Survival statistics for this user like revived teammates
  #
  # If the Survival statistics haven't been parsed already, parsing is done
  # now.
  #
  # The XML layout for the Survival statistics for Left4Dead 2 differs a bit
  # from Left4Dead's Survival statistics. So we have to use a different way
  # of parsing for the maps and we use a different map class
  # (`L4D2Map`) which holds the additional information provided in
  # Left4Dead 2's statistics.
  #
  # @return [Hash<String, Object>] The Survival statistics of the player
  def survival_stats
    return unless public?

    if @survival_stats.nil?
      super
      @survival_stats[:maps] = {}
      @xml_data['stats']['survival']['maps']['map'].each do |map_data|
        map = L4D2Map.new(map_data)
        @survival_stats[:maps][map.id] = map
      end
    end

    @survival_stats
  end

  # Returns a hash of `L4D2Weapon` for this user containing all Left4Dead 2
  # weapons
  #
  # If the weapons haven't been parsed already, parsing is done now.
  #
  # @return [Hash<String, Object>] The weapon statistics for this player
  def weapon_stats
    return unless public?

    if @weapon_stats.nil?
      @weapon_stats = {}
      @xml_data['stats']['weapons'].each do |weapon_data|
        next if weapon_data.nil?

        unless %w{bilejars molotov pipes}.include? weapon_data[0]
          weapon = L4D2Weapon.new *weapon_data
        else
          weapon = L4DExplosive.new *weapon_data
        end

        @weapon_stats[weapon_data[0]] = weapon
      end
    end

    @weapon_stats
  end

end
