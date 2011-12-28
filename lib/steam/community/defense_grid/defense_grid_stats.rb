# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2011, Sebastian Staudt

require 'steam/community/game_stats'

# This class represents the game statistics for a single user in Defense Grid:
# The Awakening
#
# @author Sebastian Staudt
class DefenseGridStats < GameStats

  # Returns the bronze medals won by this player
  #
  # @return [Fixnum] Bronze medals won
  attr_reader :bronze_medals

  # Returns the damage done by this player
  #
  # @return [Float] Damage done
  attr_reader :damage_done

  # Returns the damage done during the campaign by this player
  #
  # @return [Float] Damage done during the campaign
  attr_reader :damage_campaign

  # Returns the damage done during challenges by this player
  #
  # @return [Float] Damage done during challenges
  attr_reader :damage_challenge

  # Returns the aliens encountered by this player
  #
  # @return [Fixnum] Aliens encountered
  attr_reader :encountered

  # Returns the gold medals won by this player
  #
  # @return [Fixnum] Gold medals won
  attr_reader :gold_medals

  # Returns the heat damage done by this player
  #
  # @return [Float] Heat damage done
  attr_reader :heat_damage

  # Returns the interest gained by the player
  #
  # @return [Fixnum] Interest gained
  attr_reader :interest

  # Returns the aliens killed by the player
  #
  # @return [Fixnum] Aliens killed
  attr_reader :killed

  # Returns the aliens killed during the campaign by the player
  #
  # @return [Fixnum] Aliens killed during the campaign
  attr_reader :killed_campaign

  # Returns the aliens killed during challenges by the player
  #
  # @return [Fixnum] Aliens killed during challenges
  attr_reader :killed_challenge

  # Returns the number of levels played by the player
  #
  # @return [Fixnum] Number of levels played
  attr_reader :levels_played

  # Returns the number of levels played during the campaign by the player
  #
  # @return [Fixnum] Number of levels played during the campaign
  attr_reader :levels_played_campaign

  # Returns the number of levels played during challenges by the player
  #
  # @return [Fixnum] Number of levels played during challenges
  attr_reader :levels_played_challenge

  # Returns the number of levels won by the player
  #
  # @return [Fixnum] Number of levels won
  attr_reader :levels_won

  # Returns the number of levels won during the campaign by the player
  #
  # @return [Fixnum] Number of levels during the campaign won
  attr_reader :levels_won_campaign

  # Returns the number of levels won during challenges by the player
  #
  # @return [Fixnum] Number of levels during challenges won
  attr_reader :levels_won_challenge

  # Returns the damage dealt by the orbital laser
  #
  # @return [Float] Damage dealt by the orbital laser
  attr_reader :orbital_laser_fired

  # Returns the number of times the orbital lasers has been fired by the player
  #
  # @return [Fixnum] Number of times the orbital laser has been fired
  attr_reader :orbital_laser_damage

  # Returns the amount of resources harvested by the player
  #
  # @return [Fixnum] Resources harvested by the player
  attr_reader :resources

  # Returns the silver medals won by this player
  #
  # @return [Fixnum] Silver medals won
  attr_reader :silver_medals

  # Returns the time played in seconds by the player
  #
  # @return [Float] Time played
  attr_reader :time_played

  # Creates a `DefenseGridStats` instance by calling the super constructor with
  # the game name `'defensegrid:awakening'`
  #
  # @param [String, Fixnum] steam_id The custom URL or the 64bit Steam ID of
  #        the user
  def initialize(steam_id)
    super(steam_id, 'defensegrid:awakening')

    if public?
      general_data = @xml_data['stats']['general']

      @bronze_medals           = general_data['bronze_medals_won']['value'].to_i
      @silver_medals           = general_data['silver_medals_won']['value'].to_i
      @gold_medals             = general_data['gold_medals_won']['value'].to_i
      @levels_played           = general_data['levels_played_total']['value'].to_i
      @levels_played_campaign  = general_data['levels_played_campaign']['value'].to_i
      @levels_played_challenge = general_data['levels_played_challenge']['value'].to_i
      @levels_won              = general_data['levels_won_total']['value'].to_i
      @levels_won_campaign     = general_data['levels_won_campaign']['value'].to_i
      @levels_won_challenge    = general_data['levels_won_challenge']['value'].to_i
      @encountered             = general_data['total_aliens_encountered']['value'].to_i
      @killed                  = general_data['total_aliens_killed']['value'].to_i
      @killed_campaign         = general_data['total_aliens_killed_campaign']['value'].to_i
      @killed_challenge        = general_data['total_aliens_killed_challenge']['value'].to_i
      @resources               = general_data['resources_recovered']['value'].to_i
      @heat_damage             = general_data['heatdamage']['value'].to_f
      @time_played             = general_data['time_played']['value'].to_f
      @interest                = general_data['interest_gained']['value'].to_f
      @damage_done             = general_data['tower_damage_total']['value'].to_f
      @damage_campaign         = general_data['tower_damage_total_campaign']['value'].to_f
      @damage_challenge        = general_data['tower_damage_total_challenge']['value'].to_f
      @orbital_laser_fired     = @xml_data['stats']['orbitallaser']['fired']['value'].to_i
      @orbital_laser_damage    = @xml_data['stats']['orbitallaser']['damage']['value'].to_f
    end
  end

  # Returns stats about the aliens encountered by the player
  #
  # The Hash returned uses the names of the aliens as keys. Every value of the
  # Hash is an Array containing the number of aliens encountered as the first
  # element and the number of aliens killed as the second element.
  #
  # @return [Hash<String, Array<Fixnum>>] Stats about the aliens encountered
  def alien_stats
    return unless public?

    if @alien_stats.nil?
      alien_data = @xml_data['stats']['aliens']
      @alien_stats = {}
      aliens = %w{swarmer juggernaut crasher spire grunt bulwark drone manta dart
                  decoy rumbler seeker turtle walker racer stealth}

      aliens.each do |alien|
        @alien_stats[alien] = [
          alien_data[alien]['encountered']['value'].to_i,
          alien_data[alien]['killed']['value'].to_i
        ]
      end
    end

    @alien_stats
  end

  # Returns stats about the towers built by the player
  #
  # The Hash returned uses the names of the towers as keys. Every value of
  # the Hash is another Hash using the keys 1 to 3 for different tower levels.
  # The values of these Hash is an Array containing the number of towers built
  # as the first element and the damage dealt by this specific tower type as the
  # second element.
  #
  # The Command tower uses the resources gained as second element.
  # The Temporal tower doesn't have a second element.
  #
  # @return [Hash<String, Array<Fixnum>>] Stats about the towers built
  def tower_stats
    return unless public?

    if @tower_stats.nil?
      tower_data = @xml_data['stats']['towers']
      @tower_stats = {}
      towers = %w{cannon flak gun inferno laser meteor missile tesla}

      towers.each do |tower|
        @tower_stats[tower] = {}
        (1..3).each do |i|
          tower_level = tower_data[tower].detect { |t| t['level'].to_i == i }
          @tower_stats[tower][i] = [
            tower_level['built']['value'].to_i,
            tower_level['damage']['value'].to_f
          ]
        end
      end

      @tower_stats['command'] = {}
      (1..3).each do |i|
        tower_level = tower_data['command'].detect { |t| t['level'].to_i == i }
        @tower_stats['command'][i] = [
          tower_level['built']['value'].to_i,
          tower_level['resource']['value'].to_f
        ]
      end

      @tower_stats['temporal'] = {}
      (1..3).each do |i|
        tower_level = tower_data['temporal'].detect { |t| t['level'].to_i == i }
        @tower_stats['temporal'][i] = [ tower_level['built']['value'].to_i ]
      end
    end

    @tower_stats
  end

end
