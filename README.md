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

### sm_game_player_add

Usage: `sm_game_player_add steamid [-name ...] [-team ...] [-class ...]`

Adds the player with the specified `steamid` to the game. Upon
joining, he will be renamed to the specified `name`, and moved into
the `team` playing as `class`.

team: The player's team. As either a number (2 for RED, 3 for BLU) or
as red or blu/blue.

class: The player's class, by name or by its ID:

| scout    | 1 |
| soldier  | 3 |
| pyro     | 7 |
| demoman  | 4 |
| heavy    | 6 |
| engineer | 9 |
| medic    | 5 |
| sniper   | 2 |
| spy      | 8 |

Examples:

    sm_game_player_add 76501234567890123 -name TestName -team blu -class engineer
    sm_game_player_add 76501234567890123 -team 3 -class 9
    sm_game_player_add 76501234567890123 -name TestName -team blue -class 9

### sm_game_player_del

Usage: `sm_game_player_del steamid`

Removes the player with the specified steamid from the game.

Examples:

    sm_game_player_del 76501234567890123

### sm_game_player_delall

Usage: `sm_game_player_delall`

Removes all configured players from the game.

### sm_game_player_list

Usage: `sm_game_player_list`

Prints a list of all added players to the server console.

Examples :

    > sm_game_player_list
    sm_game_player_list: no players in the list
    > sm_game_player_list
    0: 76501234567890123
    1: 76501234567890125
    2: 76501234567890122

### sm_game_player_whitelist

Usage: `sm_game_player_whitelist 0/1`

If 0, anyone can join the game: players not configured with the other
commands will simply not be specially handled. If 1, players not
previously configured via `sm_game_player_add` will be automatically
kicked whenever they attempt to join the game.

## Building

To build, simply run `make`.

If you do not have a SourcePawn compiler available (`spcomp`), you can
easily install the latest 1.7 build locally into `sourcemod/` by running
`./download-sourcemod.sh`.

## License

This project is released under the GNU General Public License v3.0
(GPL-3.0, available in `gpl-3.0.txt`).

The compiled plugin, as a derivative work of the SourceMod project, is
allowed to be released under GPL-3.0 in accordance with SourceMod's
licensing terms for derivative works, a copy of which is in
`SOURCEMOD-LICENSE.txt`.
