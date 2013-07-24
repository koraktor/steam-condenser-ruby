## Version 2.0.0 / Unreleased

 * [FEATURE] Use the Web API to get games
 * [ENHANCEMENT] Use proper namespacing throughout the library
 * [ENHANCEMENT] Provide a simple way to get parsed JSON from Web API
 * [ENHANCEMENT] Removed old hackish master server functionality
 * [ENHANCEMENT] Removed deprecated aliases from SteamId

## Version 1.3.6 / 2013-07-23

 * [SECURITY] Use HTTPS for Web API by default
 * [ENHANCEMENT] bzip2-ruby is optional again for compatibility with Ruby 2.0.0
                 and JRuby
 * [ENHANCEMENT] Improved code style in various places
 * [BUGFIX] Changed to the correct GoldSrc master server port
 * [BUGFIX] Fixed SourceSocket not failing when it should
 * [BUGFIX] Fixed creating SteamId instances with `U_` IDs

## Version 1.3.5 / 2013-03-29

 * [ENHANCEMENT] Adapted game item parsing to *DotA 2* API changes
 * [SECURITY] Strip Wep API keys from debug output
 * [BUGFIX] Fixed creating SteamId instances with `STEAM_` IDs

## Version 1.3.4.1 / 2013-02-13

 * [BUGFIX] Corrected gem build for version 1.3.4

## Version 1.3.4 / 2013-02-13

 * [BUGFIX] Fixed a regression in community error handling

## Version 1.3.3 / 2013-02-12

 * [FEATURE] Added support for game ID in server info
 * [ENHANCEMENT] Improved error handling for XML data
 * [ENHANCEMENT] Simplified server info packets

## Version 1.3.2 / 2013-02-04

 * [ENHANCEMENT] Improved detection of RCON bans

## Version 1.3.1 / 2013-01-20

 * [ENHANCEMENT] Added support for preliminary inventory items
 * [ENHANCEMENT] Further improved RCON connection handling
 * [BUGFIX] Do not cache failed user groups and friends
 * [BUGFIX] Fixed errors when creating cacheable classes

## Version 1.3.0 / 2012-12-29

 * [FEATURE] Added support for new Web API interfaces
 * [FEATURE] Added support for new Steam ID format ("[U:#:#####]")
 * [ENHANCEMENT] Vastly improved inventories
 * [ENHANCEMENT] Better handling of RCON edge cases
 * [ENHANCEMENT] Improved connection handling for RCON edge cases
 * [BUGFIX] Fixed several community parsing issues

## Version 1.2.1 / 2012-07-21

 * [FEATURE] Support for *DotA 2* (beta) inventories
 * [ENHANCEMENT] Improved behavior of cacheable classes
 * [ENHANCEMENT] Workaround for game URLs with duplicate slashes

## Version 1.2.0 / 2012-04-24

 * [FEATURE] Support for game version checks
 * [FEATURE] Support query for all Web API interfaces
 * [FEATURE] Check game versions using its `steam.inf` file
 * [FEATURE] Support for new Steam profile attributes
 * [ENHANCEMENT] Improved fetching of community groups
 * [ENHANCEMENT] Improved unit tests
 * [ENHANCEMENT] Cleaned up community-related code
 * [ENHANCEMENT] Use multi_xml for parsing XML
 * [BUGFIX] Use `A2S_PLAYER` packet to challenge game servers
 * [BUGFIX] Fixed several URL related problems
 * [BUGFIX] Fixed Web API not working without an API key
 * [PERFORMACE] Optimized fetching of Steam group members

## Version 1.1.0 / 2011-12-13

 * [FEATURE] Support for leaderboards
 * [FEATURE] Support for *Team Fortress 2* beta stats
 * [ENHANCEMENT] Allow use of service names instead of port numbers
 * [BUGFIX] Fixed sending master server heartbeats
 * [BUGFIX] Fixed check for profile links

## Version 1.0.2 / 2011-10-24

 * [ENHANCEMENT] Added API name and description to achievements
 * [BUGFIX] Fixed handling of empty RCON responses
 * [BUGFIX] Fixed `SourceServer.master`
 * [BUGFIX] Fixed parsing rules with empty values
 * [BUGFIX] Fixed server info for some Source servers
 * [BUGFIX] Fixed Rakefile encoding for Ruby 1.9

## Version 1.0.1 / 2011-08-23

 * [BUGFIX] Fixed several packaging problems

## Version 1.0.0 / 2011-08-18

 * [ENHANCEMENT] Added intuitive way to get master servers
 * [ENHANCEMENT] Added a shortcut to get stats for a SteamGame
 * [ENHANCEMENT] Added a way to bypass master server problems
 * [ENHANCEMENT] Updated documentation
 * [ENHANCEMENT] Improved code style
 * [ENHANCEMENT] Updated achievement Web API to version 2
 * [ENHANCEMENT] Updated application news Web API to version 2
 * [ENHANCEMENT] Use Bundler instead of Ore
 * [ENHANCEMENT] Use multi_json instead of json
 * [BUGFIX] Fixed author field for application news

## Version 0.14.0 / 2011-06-01

 * [FEATURE] Support for *Portal 2* stats
 * [ENHANCEMENT] Updated documentation
 * [ENHANCEMENT] Use `IEconItems` Web API interfaces for inventories
 * [BUGFIX] Fixed consecutive Source RCON requests
 * [BUGFIX] Fixed inventory caching

## Version 0.13.1 / 2011-04-15

* [BUGFIX] Fixed several problems when parsing RCON `status` output

## Version 0.13.0 / 2011-04-12

* [FEATURE] Support for Steam's Web API
* [FEATURE] Support for Steam application news
* [FEATURE] Support for *Team Fortress 2* inventories, golden wrenches
* [FEATURE] Support for master server heartbeating
* [FEATURE] Dynamic name resolution and automatic failover for master servers
* [ENHANCEMENT] Improved parsing of RCON `status` output
* [BUGFIX] Fixed pinging game servers
* [BUGFIX] Fixed `A2S_PLAYER` and `A2S_RULES` packet creation
* [BUGFIX] Fixed regular expression for game links
* [PERFORMANCE] Optimized RCON queries
* [PERFORMANCE] Fixed timeout calculation in `SteamSocket`
* [PERFORMANCE] Lazy load zlib for compressed packets

## Version 0.12.0 / 2010-12-29

 * [FEATURE] Support for *Alien Swarm* stats
 * [FEATURE] Allow customization of socket timeouts
 * [ENHANCEMENT] Moved from Jeweler to Ore
 * [BUGFIX] Fixed stats for games without a specific implementation

## Version 0.11.4 / 2010-11-07

 * [BUGFIX] Fixed split packet handling
 * [BUGFIX] Fixed compatibility with Ruby 1.9
 * [BUGFIX] Fix for a change in *CS:S*' stats XML data

## Version 0.11.3 / 2010-10-05

 * [BUGFIX] Fix for `SteamId#game_stats`

## Version 0.11.2 / 2010-09-08

 * [ENHANCEMENT] Provide the unlock date of achievements if available
 * [BUGFIX] Removed workaround for GoldSrc master servers
 * [BUGFIX] Compatibility fix for `StringIO` additions

## Version 0.11.1 / 2010-07-05

 * [BUGFIX] Fixed parsing of RCON replies

## Version 0.11.0 / 2010-07-02

 * [FEATURE] Support for *Counter-Strike: Source* stats
 * [ENHANCEMENT] Adapt to common Ruby code conventions
 * [BUGFIX] Fixed timouts for unresponsive master servers
 * [BUGFIX] Fixed querying GoldSrc master servers

## Version 0.10.1 / 2010-04-05

 * [FEATURE] Load servers' Steam IDs from `S2A_INFO2` replies
 * [BUGFIX] Fixed fetching group members
 * [BUGFIX] Fixed cacheable community data
 * [BUGFIX] Fixed check for EDF in `S2A_INFO2` replies

## Version 0.10.0 / 2010-02-24

 * [FEATURE] Support for *Left4Dead 2* stats
 * [FEATURE] Added conversion from 64bit to `STEAM_` IDs
 * [ENHANCEMENT] Parse XML data to get a user's games
 * [BUGFIX] Fixed parsing of deactivated community profiles
 * [BUGFIX] Fixed loading additional player information for Source servers

## Version 0.9.0 / 2009-09-16

 * [FEATURE] Support loading community groups of a user
 * [FEATURE] Support for *Defense Grid: The Awakening* stats
 * [ENHANCEMENT] Workaround for corrupt `S2A_RULES` replies
 * [ENHANCEMENT] Supply a `VERSION` constant
 * [BUGFIX] Fixed gem packaging
 * [BUGFIX] Fixed handling of really long RCON replies
 * [BUGFIX] Improved parsing of `S2A_RULES` packets
 * [BUGFIX] Fixed compatibility with Ruby 1.9
 * [PERFORMANCE] Added caching to `SteamGroup` and `SteamId`

## Version 0.8.0 / 2009-06-15

 * [FEATURE] Load additional player information via RCON
 * [FEATURE] Support for *Day of Defeat: Source* stats
 * [FEATURE] Support for *Left4Dead* stats
 * [FEATURE] Support loading games of a user
 * [ENHANCEMENT] Let `SteamCondenserError` inherit from `StandardError`
 * [ENHANCEMENT] Several improvements to Steam Community features
 * [ENHANCEMENT] Several improvements to server queries
 * [ENHANCEMENT] Use Jeweler for packaging
 * [BUGFIX] Fixed problems with compressed packets
 * [BUGFIX] Fixed parsing profiles without favorite or most played games
 * [PERFORMANCE] Optimized server queries

## Version 0.7.0 / 2009-03-02

 * [FEATURE] Support for *Team Fortress 2* stats and achievements
 * [FEATURE] Support for split RCON replies
 * [FEATURE] Support for compressed query replies
 * [ENHANCEMENT] Better support for HTLV servers
 * [ENHANCEMENT] XML cache for `GameStats`
 * [ENHANCEMENT] Use correct packet names
 * [BUGFIX] Fixed fetching of `SteamId` data
 * [BUGFIX] Fixed several GoldSrc RCON problems

## Version 0.6.0 / 2008-10-23

 * [FEATURE] Support for Steam Community profiles
 * [FEATURE] Support for game statistics
 * [FEATURE] Support for RCON

## Version 0.5.0 / 2008-08-10

 * [FEATURE] Support for GoldSrc and Source server queries
 * [FEATURE] Support for master server queries
