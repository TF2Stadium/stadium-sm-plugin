#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#pragma newdecls required

public Plugin myinfo = {
    name = "Teams Control",
    author = "Forward Command Post, TF2Stadium",
    description = "adds commands for configuring allowed players with specific roles",
    version = "0.0.1",
    url = "http://pug.champ.gg, http://tf2stadium.com"
};

ArrayList allowedPlayers;
StringMap playerNames;
StringMap playerTeams;
StringMap playerClasses;

ConVar whitelistCvar;

int TF2_GetTeam(const char[] name) {
    if (strcmp(name, "2") == 0) {
        return 2;
    } else if (strcmp(name, "3") == 0) {
        return 3;
    } else if (strcmp(name, "red") == 0) {
        return 2;
    } else if (strcmp(name, "blue") == 0) {
        return 3;
    } else if (strcmp(name, "blu") == 0) {
        return 3;
    }

    return -1;
}

public void OnPluginStart() {
    RegServerCmd("sm_game_player_add", Command_GamePlayerAdd, "adds a player to a game");
    RegServerCmd("sm_game_player_del", Command_GamePlayerRemove, "removes a player from a game");
    RegServerCmd("sm_game_player_delall", Command_GameReset, "removes all players from game");
    RegServerCmd("sm_game_player_list", Command_ListPlayers, "lists all configured players");

    whitelistCvar = CreateConVar("sm_game_player_whitelist", "1", "Sets whether or not to auto-kick players not on the list", _, true, 0.0, true, 1.0);

    allowedPlayers = new ArrayList(32);
    playerNames = new StringMap();
    playerTeams = new StringMap();
    playerClasses = new StringMap();

    HookEvent("player_changename", Event_NameChange, EventHookMode_Post);
    HookUserMessage(GetUserMessageId("SayText2"), UserMessage_SayText2, true);
}

public void OnClientPostAdminCheck(int client) {
    // A 64 bit steamid as a decimal string will be at most 20 chatacters
    char steamID64[32];
    if (!GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64))) {
        ThrowError("Steam ID not retrieved");
    }

    if (allowedPlayers.FindString(steamID64) == -1) {
        if (whitelistCvar.BoolValue) {
            KickClient(client, "You are not authorized to join this server.");
			  }
    } else {
			char name[32];
			if (playerNames.GetString(steamID64, name, sizeof(name))) {
        SetClientName(client, name);
			}

			int team;
			if (playerTeams.GetValue(steamID64, team)) {
        ChangeClientTeam(client, team);
			}

			TFClassType class;
			if (playerClasses.GetValue(steamID64, class)) {
        TF2_SetPlayerClass(client, class, _, true);
			}
		}
}

public Action Command_GameReset(int args) {
    allowedPlayers.Clear();
    playerNames.Clear();
    playerTeams.Clear();
    playerClasses.Clear();

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientConnected(i) && !IsClientReplay(i) && !IsClientSourceTV(i)) {
            KickClient(i, "the server is being reset");
        }
    }

    return Plugin_Handled;
}

public Action Command_GamePlayerAdd(int args) {
    char steamID[32];
    GetCmdArg(1, steamID, sizeof(steamID));
    if (allowedPlayers.FindString(steamID) == -1) {
        allowedPlayers.PushString(steamID);
    }

    // Parse optional -arg val parameter options.
    char arg[32];
    char val[32];
    for (int i = 2; i+1 <= args; i += 2) {
        GetCmdArg(i, arg, sizeof(arg));
        GetCmdArg(i+1, val, sizeof(val));

        if (strcmp("-team", arg, false) == 0) {
            int id = TF2_GetTeam(val);
            if (id != -1) {
                playerTeams.SetValue(steamID, id, true);
            }
        } else if (strcmp("-class", arg, false) == 0) {
            TFClassType id = TF2_GetClass(val);
            if (id != TFClass_Unknown) {
                playerClasses.SetValue(steamID, id, true);
            } else {
                int idNum = StringToInt(val);
                if (idNum >= 1 && idNum <= 9) {
                    playerClasses.SetValue(steamID, idNum, true);
                }
            }
        } else if (strcmp("-name", arg, false) == 0) {
            playerNames.SetString(steamID, val, true);
        }
    }
}

public Action Command_GamePlayerRemove(int args) {
    char steamID[32];
    GetCmdArg(1, steamID, sizeof(steamID));

    if (allowedPlayers.FindString(steamID) != -1) {
        allowedPlayers.Erase(allowedPlayers.FindString(steamID));
    }
    playerNames.Remove(steamID);
    playerTeams.Remove(steamID);
    playerClasses.Remove(steamID);

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientConnected(i) && !IsClientReplay(i) && !IsClientSourceTV(i)) {
            char clientSteamID[32];
            if (GetClientAuthId(i, AuthId_SteamID64, clientSteamID, sizeof(clientSteamID))) {
                if (StrEqual(steamID, clientSteamID)) {
                    KickClient(i, "you have been removed from this game");
                }
            }
        }
    }
}

public Action Command_ListPlayers(int args) {
    int n = allowedPlayers.Length;

    if (n == 0) {
        char cmdName[32];
        GetCmdArg(0, cmdName, sizeof(cmdName));
        PrintToServer("%s: no players in the list", cmdName);
    }

    char clientSteamID64[32];
    for (int i = 0; i < n; i++) {
        allowedPlayers.GetString(i, clientSteamID64, sizeof(clientSteamID64));
        PrintToServer("%d: %s", i, clientSteamID64);
    }
}

public void Event_NameChange(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    char newName[32];
    event.GetString("newname", newName, sizeof(newName));

    char steamID[32];
    GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

    char playerName[32];
    if (playerNames.GetString(steamID, playerName, sizeof(playerName))) {
        if (!StrEqual(newName, playerName)) {
            SetClientName(client, playerName);
        }
    }
}

public Action UserMessage_SayText2(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) {
    char buffer[512];

    if (!reliable) {
        return Plugin_Continue;
    }

    msg.ReadByte();
    msg.ReadByte();
    msg.ReadString(buffer, sizeof(buffer), false);

    if (StrContains(buffer, "#TF_Name_Change") != -1) {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

/* Local Variables: */
/* indent-tabs-mode: nil */
/* c-basic-offset: 4 */
/* End: */
