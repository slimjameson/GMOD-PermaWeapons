-- MADE BY SLIM JAMESON
AddCSLuaFile("permweapons_config.lua")
include("permweapons_config.lua")

util.AddNetworkString("PermWeapons_OpenMenu")
util.AddNetworkString("PermWeapons_Apply")

local DATA_FILE = "permweapons_data.json"

-- Load existing data (or empty table)
local function LoadPermData()
    if not file.Exists(DATA_FILE, "DATA") then
        return {}
    end
    local raw = file.Read(DATA_FILE, "DATA")
    local tbl = util.JSONToTable(raw) or {}
    return tbl
end

-- Save pretty-printed JSON back to disk
local function SavePermData(tbl)
    file.Write(DATA_FILE, util.TableToJSON(tbl, true))
end

-- Chat command
hook.Add("PlayerSay", "PermWeapons_Command", function(ply, txt)
    if txt:lower() ~= "!permweapons" then return end

    if PermWeaponsConfig.AllowedRanks[ ply:GetUserGroup():lower() ] then
        net.Start("PermWeapons_OpenMenu")
        net.Send(ply)
    else
        ply:ChatPrint("You don't have permission for that.")
    end
    return ""
end)

-- Receive from client
net.Receive("PermWeapons_Apply", function(_, ply)
    local targetID = net.ReadString()
    local wepClass = net.ReadString()

    local data = LoadPermData()

    -- ensure we have a weapon-list for this ID
    data[targetID] = data[targetID] or {}

    -- add if not already there
    if not table.HasValue(data[targetID], wepClass) then
        table.insert(data[targetID], wepClass)
        ply:ChatPrint("Added "..wepClass.." for "..targetID)
    else
        ply:ChatPrint(wepClass.." was already set for "..targetID)
    end

    SavePermData(data)
end)

-- Give weapons on spawn
hook.Add("PlayerSpawn", "PermWeapons_GiveOnSpawn", function(ply)
    local data = LoadPermData()
    for id, wepList in pairs(data) do
        -- match against STEAMID or STEAMID64
        if id == ply:SteamID() or id == ply:SteamID64() then
            for _, cls in ipairs(wepList) do
                ply:Give(cls)
            end
        end
    end
end)
