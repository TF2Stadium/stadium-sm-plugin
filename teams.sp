#include <sourcemod>
#include <connect>
#include <sdktools>
#include <steamtools>
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

public void OnPluginStart() {
    RegServerCmd("pugchamp_game_reset", Command_GameReset, "resets a currently active game");

    RegServerCmd("pugchamp_game_player_add", Command_GamePlayerAdd, "adds a player to a game");
    RegServerCmd("pugchamp_game_player_remove", Command_GamePlayerRemove, "removes a player from a game");

    allowedPlayers = new ArrayList(32);
    playerNames = new StringMap();
    playerTeams = new StringMap();
    playerClasses = new StringMap();

    HookEvent("player_changename", Event_NameChange, EventHookMode_Post);
    HookUserMessage(GetUserMessageId("SayText2"), UserMessage_SayText2, true);
}

public bool OnClientPreConnectEx(const char[] name, char password[255], const char[] ip, const char[] steamID, char rejectReason[255]) {
    char steamID64[32];
    Connect_GetAuthId(AuthId_SteamID64, steamID64, sizeof(steamID64));

    if (allowedPlayers.FindString(steamID64) == -1) {
        strcopy(rejectReason, sizeof(rejectReason), "You are not authorized to join this server.");

        return false;
    }

    return true;
}

public void OnClientPostAdminCheck(int client) {
    char steamID[32];
    if (!GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID))) {
        ThrowError("Steam ID not retrieved");
    }

    char name[32];
    if (playerNames.GetString(steamID, name, sizeof(name))) {
        SetClientName(client, name);
    }

    int team;
    if (playerTeams.GetValue(steamID, team)) {
        ChangeClientTeam(client, team);
    }

    TFClassType class;
    if (playerClasses.GetValue(steamID, class)) {
        TF2_SetPlayerClass(client, class, _, true);
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

    char name[32];
    GetCmdArg(2, name, sizeof(name));
    playerNames.SetString(steamID, name, true);

    if (args >= 3) {
        char teamString[4];
        int team;
        GetCmdArg(3, teamString, sizeof(teamString));
        team = StringToInt(teamString);
        playerTeams.SetValue(steamID, team, true);

        if (args >= 4) {
            char classString[4];
            int class;
            GetCmdArg(4, classString, sizeof(classString));
            class = StringToInt(classString);
            playerClasses.SetValue(steamID, class, true);
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
