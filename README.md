# SM Teams

A SourceMod plugin for managing pre-made teams in a TF2 match
organized on some 3rd party platform. It provides commands for setting
up a list of players (specified by SteamID) who are allowed to play in
a server, along with aliases they should be named as.

This plugin is heavily copied from parts of
[PugChamp](https://github.com/fwdcp/pugchamp)'s "pugchamp-control"
plugin, originally for use with TF2Stadium, but designed to be
generally applicable to other uses as well.

## Usage

This plugin's interface is designed to match the source engine's
`logaddress` interface, with `add`, `del`, `delall`, and `list`
commands.

### sm_game_players_add

Usage: `sm_game_players_add steamid name team class`

Adds the player with the specified `steamid` to the game. Upon
joining, he will be renamed to the specified `name`, and moved into
the `team` playing as `class`; where `team` and `class` are numbers
based on the following:

team: The player's team. 2 for RED, 3 for BLU

class: The player's class, based on the following table:

| scout    | 1 |
| soldier  | 3 |
| pyro     | 7 |
| demoman  | 4 |
| heavy    | 6 |
| engineer | 9 |
| medic    | 5 |
| sniper   | 2 |
| spy      | 8 |

TODO: add example usage showing steamid's format

### sm_game_players_del

Usage: `sm_game_players_del steamid`

Removes the player with the specified steamid from the game.

TODO: add example usage showing steamid's format

### sm_game_players_delall

Usage: `sm_game_players_delall`

Removes all configured players from the game.

### sm_game_players_list

Usage: `sm_game_players_list`

Prints a list of all added players to the server console.

## Building

TODO

## License

This project is released under the GNU General Public License v3.0
(GPL-3.0, available in `gpl-3.0.txt`).

The compiled plugin, as a derivative work of the SourceMod project, is
allowed to be released under GPL-3.0 in accordance with SourceMod's
licensing terms for derivative works, a copy of which is in
`SOURCEMOD-LICENSE.txt`.
