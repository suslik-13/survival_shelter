-- factions.lua
dofile(core.get_modpath("serverfactions") .. "/relations.lua")
factions = {}
factions.list = {}

-- Function for load factions
function factions.load_factions()
    local file = io.open(core.get_worldpath() .. "/factions.txt", "r")
    if file then
        for line in file:lines() do
            local faction_name, leader, members_str, claims, maxclaims = line:match("^([^,]+),([^,]+),(.*),([^,]+),([^,]+)$")
            if faction_name then
                local faction = {
                    name = faction_name,
                    leader = leader,
                    members = {},
                    tax = 0,
                    claim_count = tonumber(claims) or 0,
                    max_claim = tonumber(maxclaims) or 4
                }
                factions.list[faction_name] = faction
                for member_info in members_str:gmatch("([^;]+)") do
                    local member_name, role = member_info:match("([^:]+):([^:]+)")
                    if member_name and role then
                        if role == "waiting" then
                            -- Legacy format: pending invitations were stored as members
                            factions.pending.invitations[faction_name] = factions.pending.invitations[faction_name] or {}
                            factions.pending.invitations[faction_name][member_name] = os.time()
                        else
                            faction.members[member_name] = role
                        end
                    end
                end
                if not faction.members[leader] then
                    faction.members[leader] = "factionleader"
                end
            elseif line ~= "" then
                core.log("warning", "[serverfactions] Cannot parse factions.txt line: " .. line)
            end
        end
        file:close()
        factions.save_pending()
    end
end

-- Pending invitations (leader -> player) and join requests (player -> faction).
-- Stored in mod storage so they survive restarts and can be cleaned up properly.
-- Format: pending.invitations[faction_name][player_name] = sent_at
--         pending.join_requests[faction_name][player_name] = sent_at
local storage = core.get_mod_storage()
local PENDING_TTL = 604800 -- one week

factions.pending = core.deserialize(storage:get_string("pending") or "") or {}
factions.pending.invitations = factions.pending.invitations or {}
factions.pending.join_requests = factions.pending.join_requests or {}

function factions.save_pending()
    storage:set_string("pending", core.serialize(factions.pending))
end

local function pending_get(kind, faction_name, player_name)
    local t = factions.pending[kind][faction_name]
    return t and t[player_name]
end

local function pending_set(kind, faction_name, player_name, value)
    local t = factions.pending[kind][faction_name]
    if value == nil then
        if t then
            t[player_name] = nil
            if next(t) == nil then
                factions.pending[kind][faction_name] = nil
            end
        end
    else
        if not t then
            t = {}
            factions.pending[kind][faction_name] = t
        end
        t[player_name] = value
    end
    factions.save_pending()
end

-- Remove every invitation/request concerning a player (used when he joins a faction)
local function pending_clear_player(player_name)
    for _, kind in ipairs({"invitations", "join_requests"}) do
        for faction_name, t in pairs(factions.pending[kind]) do
            t[player_name] = nil
            if next(t) == nil then
                factions.pending[kind][faction_name] = nil
            end
        end
    end
    factions.save_pending()
end

local function pending_clear_faction(faction_name)
    factions.pending.invitations[faction_name] = nil
    factions.pending.join_requests[faction_name] = nil
    factions.save_pending()
end

-- Can this player manage invitations/requests of the faction?
function factions.can_manage(player_name, faction_name)
    local faction = factions.list[faction_name]
    if not faction then
        return false
    end
    return faction.leader == player_name or faction.members[player_name] == "co-leader"
end

-- Notify online leader and co-leaders of a faction
local function notify_managers(faction_name, message)
    local faction = factions.list[faction_name]
    if not faction then
        return
    end
    for member_name, role in pairs(faction.members) do
        if (member_name == faction.leader or role == "co-leader") and core.get_player_by_name(member_name) then
            core.chat_send_player(member_name, message)
        end
    end
end

-- Faction names are stored in comma/colon separated files and used in formspecs
function factions.is_valid_name(str)
    return str:match("^[%w_%-]+$") ~= nil
end

-- Function for save factions in a file
function factions.save_factions()
    local file = io.open(core.get_worldpath() .. "/factions.txt", "w")
    if not file then
        core.log("error", "[serverfactions] Cannot open factions.txt for writing.")
        return
    end
    for faction_name, faction in pairs(factions.list) do
        local members_str = ""
        for member_name, role in pairs(faction.members) do
            members_str = members_str .. member_name .. ":" .. role .. ";"
        end
        members_str = members_str:sub(1, -2)
        file:write(faction_name .. "," .. faction.leader .. "," .. members_str .. "," .. faction.claim_count .. "," .. faction.max_claim .. "\n")
    end
    file:close()
end

-- Function for save the factions homes
function factions.save_homes()
    local file = io.open(core.get_worldpath() .. "/faction_homes.txt", "w")
    if file then
        for faction_name, pos in pairs(factions.homes) do
            file:write(faction_name .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. "\n")
        end
        file:close()
    end
end

-- Init factions and their homes
factions = factions or {}
factions.homes = factions.homes or {}

-- Load the factions homes
function factions.load_homes()
    local file = io.open(core.get_worldpath() .. "/faction_homes.txt", "r")
    if file then
        for line in file:lines() do
            local faction_name, x, y, z = line:match("([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+)")
            if faction_name and x and y and z then
                factions.homes[faction_name] = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
            end
        end
        file:close()
    end
end

-- Save the factions when quitting
-- (previously this only saved when at least one faction home existed)
core.register_on_shutdown(function()
    factions.save_homes()
    factions.save_factions()
    factions.save_pending()
end)

-- Expire old invitations/requests
function factions.clean_expired_invitations()
    local now = os.time()
    local changed = false
    for _, kind in ipairs({"invitations", "join_requests"}) do
        for faction_name, t in pairs(factions.pending[kind]) do
            for player_name, sent_at in pairs(t) do
                if not factions.list[faction_name] or now - sent_at > PENDING_TTL then
                    t[player_name] = nil
                    changed = true
                end
            end
            if next(t) == nil then
                factions.pending[kind][faction_name] = nil
                changed = true
            end
        end
    end
    if changed then
        factions.save_pending()
    end
end

-- One single join handler: remind pending invitations/requests once per login
core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    core.after(2, function()
        if not core.get_player_by_name(name) then
            return
        end
        factions.clean_expired_invitations()

        if not factions.get_player_faction(name) then
            local invited_by = {}
            for faction_name, t in pairs(factions.pending.invitations) do
                if t[name] then
                    table.insert(invited_by, faction_name)
                end
            end
            if #invited_by > 0 then
                table.sort(invited_by)
                core.chat_send_player(name, "You have faction invitations from: " .. table.concat(invited_by, ", ") ..
                    ". Open /f menu to join, or /f decline <faction> to decline.")
            end
        end

        local faction_name = factions.get_player_faction(name)
        if faction_name and factions.can_manage(name, faction_name) then
            local requests = {}
            for requester in pairs(factions.pending.join_requests[faction_name] or {}) do
                table.insert(requests, requester)
            end
            if #requests > 0 then
                table.sort(requests)
                core.chat_send_player(name, "Pending join requests: " .. table.concat(requests, ", ") ..
                    ". Use /f accept <player> or /f refuse <player>.")
            end
        end
    end)
end)

-- Add the name of the faction in front of the message
-- Prepend faction info to formatted chat messages instead of intercepting chat.
-- This allows other mods (statistics, translation, discord relay, etc.) to
-- receive the original `register_on_chat_message` event and cooperate.
do
    local old_format = minetest.format_chat_message
    minetest.format_chat_message = function(name, message)
        local player = core.get_player_by_name(name)
        if not player then
            if old_format then
                return old_format(name, message)
            end
            return name .. ": " .. message
        end

        local faction_name = factions.get_player_faction(name)
        local prefix = ""
        if faction_name then
            prefix = faction_name
        else
            prefix = "No Clan"
        end

        local formatted = nil
        if old_format then
            formatted = old_format(name, message)
        else
            formatted = name .. ": " .. message
        end

        return "[" .. prefix .. "] " .. formatted
    end
end

-- Check is the string haven't any spaces
function factions.is_only_spaces(str)
    return str:match("^%s*$") ~= nil
end

-- Check if the string is in 3 and 10 chars
function factions.is_length_between_3_and_10(str)
    local length = #str
    return length >= 3 and length <= 10
end

-- Function for create a new faction
function factions.create(player_name, faction_name)
    if factions.list[faction_name] then
        return false, "The faction already exist."
    end

    if factions.get_player_faction(player_name) then
        return false, "Your already in a faction."
    end

    if not factions.is_valid_name(faction_name) then
        return false, "The faction name may only contain letters, digits, '_' and '-'."
    end

    factions.list[faction_name] = {
        name = faction_name,
        leader = player_name,
        members = {[player_name] = "factionleader"},
        tax = 0,
        claim_count = 0,
        max_claim = 4
    }

    -- Ensure relations table exists and initialize entry for the new faction
    relations = relations or {}
    relations.data = relations.data or {}
    relations.data[faction_name] = relations.data[faction_name] or {}

    for fac_name, fac in pairs(factions.list) do
        if fac_name ~= faction_name then
            relations.data[faction_name][fac_name] = "NEUTRAL"
            relations.data[fac_name] = relations.data[fac_name] or {}
            relations.data[fac_name][faction_name] = "NEUTRAL"
        end
    end

    -- full rewrite: appending duplicated every relation line on each creation
    relations.save_relations(true)
    pending_clear_player(player_name)
    factions.save_factions()

    return true, "Faction '" .. faction_name .. "' successfully created."
end

-- Function for invite someone in your faction
function factions.invite(player_name, faction_name, target_player)
    if not factions.list[faction_name] then
        return false, "Cannot find the faction."
    end

    if not factions.can_manage(player_name, faction_name) then
        return false, "Only the faction leader or a co-leader can invite players."
    end

    if not core.player_exists(target_player) then
        return false, "The player " .. target_player .. " does not exist."
    end

    if factions.get_player_faction(target_player) then
        return false, "The player " .. target_player .. " is already in a faction."
    end

    if pending_get("invitations", faction_name, target_player) then
        return false, target_player .. " already has a pending invitation."
    end

    -- The player asked to join earlier: inviting him simply accepts the request
    if pending_get("join_requests", faction_name, target_player) then
        return factions.accept_invite(player_name, target_player)
    end

    pending_set("invitations", faction_name, target_player, os.time())

    if core.get_player_by_name(target_player) then
        core.chat_send_player(target_player,
            "You have been invited to join the faction '" .. faction_name ..
            "'. Open /f menu to join, or /f decline " .. faction_name .. " to decline.")
    end
    -- Offline players get a reminder on their next login (see register_on_joinplayer)

    return true, "Invitation sent to " .. target_player
end

-- Function for accept a join request (or force an invitation) - leader/co-leader side
function factions.accept_invite(player_name, target_player)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name or not factions.list[faction_name] then
        return false, "Cannot find the faction."
    end
    if not target_player or target_player == "" then
        return false, "Usage: /f accept <player>"
    end

    local faction = factions.list[faction_name]
    if not factions.can_manage(player_name, faction_name) then
        return false, "Only the faction leader or a co-leader can accept invitations."
    end

    factions.clean_expired_invitations()

    if not pending_get("join_requests", faction_name, target_player)
            and not pending_get("invitations", faction_name, target_player) then
        return false, "No pending invitation or request found for " .. target_player .. "."
    end

    if factions.get_player_faction(target_player) then
        pending_set("join_requests", faction_name, target_player, nil)
        pending_set("invitations", faction_name, target_player, nil)
        return false, target_player .. " is already in a faction."
    end

    faction.members[target_player] = "membre"
    pending_clear_player(target_player)
    factions.save_factions()

    core.chat_send_player(target_player, "Your request to join faction '" .. faction_name .. "' has been accepted.")
    return true, target_player .. " joined your faction."
end

-- Function for join a faction (player side, needs an invitation)
function factions.join(player_name, faction_name)
    if not factions.list[faction_name] then
        return false, "Cannot find the faction."
    end

    factions.clean_expired_invitations()

    if not pending_get("invitations", faction_name, player_name) then
        return false, "You do not have an active invitation to join this faction."
    end

    if factions.get_player_faction(player_name) then
        return false, "You are already in a faction."
    end

    factions.list[faction_name].members[player_name] = "membre"
    pending_clear_player(player_name)
    factions.save_factions()
    notify_managers(faction_name, player_name .. " joined your faction.")
    return true, "You just joined the faction '" .. faction_name .. "'."
end

-- Function for refuse a join request / cancel an invitation (leader/co-leader side)
function factions.refuse_invite(player_name, target_player)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false, "You are not in a faction."
    end
    if not factions.can_manage(player_name, faction_name) then
        return false, "Only the faction leader or a co-leader can refuse requests."
    end
    if not target_player or target_player == "" then
        return false, "Usage: /f refuse <player>"
    end

    local had_request = pending_get("join_requests", faction_name, target_player)
    local had_invite = pending_get("invitations", faction_name, target_player)
    if not had_request and not had_invite then
        return false, "No pending invitation or request found for " .. target_player .. "."
    end

    pending_set("join_requests", faction_name, target_player, nil)
    pending_set("invitations", faction_name, target_player, nil)

    if had_request then
        core.chat_send_player(target_player, "Your request to join faction '" .. faction_name .. "' has been refused.")
        return true, "You refused the join request of " .. target_player .. "."
    end
    return true, "The invitation for " .. target_player .. " has been cancelled."
end

-- Function for decline an invitation (invited player side)
function factions.decline_invite(player_name, faction_name)
    if not faction_name or faction_name == "" then
        return false, "Usage: /f decline <faction>"
    end
    if not pending_get("invitations", faction_name, player_name) then
        return false, "You haven't got any invite to join the faction '" .. faction_name .. "'."
    end
    pending_set("invitations", faction_name, player_name, nil)
    notify_managers(faction_name, player_name .. " declined the invitation to join your faction.")
    return true, "You refused the faction invite from the faction '" .. faction_name .. "'."
end

-- Function for cancel your own join request
function factions.cancel_join_request(player_name, faction_name)
    if not pending_get("join_requests", faction_name, player_name) then
        return false, "You didn't ask to join this faction."
    end
    pending_set("join_requests", faction_name, player_name, nil)
    return true, "You have cancelled your join request."
end

-- Function for kick someone in your faction
function factions.kick(player_name, faction_name, target_player)
    if not factions.list[faction_name] then
        return false, "Cannot find the faction."
    end

    local faction = factions.list[faction_name]
    if faction.leader ~= player_name and faction.members[player_name] ~= "co-leader" then
        return false, "You have no authority to kick players."
    end

    if not faction.members[target_player] then
        return false, target_player .. " is not in your faction."
    end

    if target_player == player_name then
        return false, "You cannot kick yourself out of your own faction."
    end

    if target_player == faction.leader then
        return false, target_player .. " cannot be kick because he is the leader."
    end

    faction.members[target_player] = nil
    factions.save_factions()
    core.chat_send_player(target_player, "You have been kicked from the faction '" .. faction_name .. "'.")
    return true, target_player .. " was kick from the faction."
end

-- Function for list the factions
function factions.list_factions()
    local faction_list = "List of the factions :\n"
    for faction_name, _ in pairs(factions.list) do
        faction_list = faction_list .. faction_name .. "\n"
    end
    return faction_list
end

-- Function for show the faction menu
function factions.show_menu(player_name)
    local faction_name = factions.get_player_faction(player_name)
    local formspec_menu

    if faction_name then
        local faction = factions.list[faction_name]

        local members = {}
        for member_name, role in pairs(faction.members) do
            table.insert(members, core.formspec_escape(member_name .. " (" .. role .. ")"))
        end
        table.sort(members)

        formspec_menu =
            "size[10,8]" ..
            "background[-4,-3;18,14;background1.png]" ..
            "label[0,1;Faction: " .. core.formspec_escape(faction_name) .. "]" ..
            "label[0,2;Chief: " .. core.formspec_escape(faction.leader) .. "]" ..
            "label[0,3;Members:]" ..
            "dropdown[0,3.5;5.5,2;member_list;" .. table.concat(members, ",") .. ";1]" ..
            "image_button[3,6;3,1;Leave.png;quitfac;]" ..
            "image_button[6,6;3,1;relations.png;relations;]" ..
            "image_button[6,1;3,1;See_claims.png;look_claims;]" ..
            "image_button[3,1;3,1;home.png;go_home;]"

        if factions.can_manage(player_name, faction_name) then
            formspec_menu = formspec_menu ..
                "image_button[0,6;3,1;Invit.png;invite;]" ..
                "image_button[6,4;3,1;Expel.png;kick;]" ..
                "image_button[6,5;3,1;roles.png;roles;]"
        end
    else
        formspec_menu =
            "size[10,4]" ..
            "background[-4,-3;18,10;background1.png]" ..
            "label[3,0;You don't have a faction ?]" ..
            "image_button[1,1;3,1;Create_faction.png;create_faction;]" ..
            "image_button[4.5,1;3,1;join_faction.png;join_faction;]" ..
            "image_button[2,2;5,1.5;invitations.png;invitform;]"
    end

    core.show_formspec(player_name, "factions:menu", formspec_menu)
end

-- Formspec for create your faction
function factions.show_create_menu(player_name)
    local formspec =
        "size[4,4]" ..
        "background[-2,-2;8,8;background1.png]"..
        "label[0.9,0.5;Create your faction]"..
        "field[0.5,1.5;3.5,1;target_name;Name of the faction:;]"..
        "image_button[-0.1,2.2;2,1;Cancel.png;cancel;]" ..
        "image_button[1.9,2.2;2,1;Validate.png;create;]"
    core.show_formspec(player_name, "factions:create", formspec)
end

-- Formspec for join a faction
function factions.show_join_form(player_name)
    local faction_list = ""
    local names = {}
    for faction_name, _ in pairs(factions.list) do
        table.insert(names, faction_name)
    end
    table.sort(names)
    faction_list = table.concat(names, ",")

    local formspec =
        "size[4,4]" ..
        "background[-2,-2;8,8;background1.png]" ..
        "label[0.6,0.5;Choose a faction]" ..
        "dropdown[0,1.3;4,1;target_faction;" .. faction_list .. ";1]"..
        "image_button[0,2.5;2,1;Cancel.png;cancel;]" ..
        "image_button[1.9,2.5;2,1;Validate.png;join_fac;]"
    core.show_formspec(player_name, "factions:join_faction", formspec)
end

-- Formspec for invite someone in your faction
function factions.show_invit_form(player_name)
    local faction_list = ""
    factions.clean_expired_invitations()
    local names = {}
    for faction_name, t in pairs(factions.pending.invitations) do
        if t[player_name] and factions.list[faction_name] then
            table.insert(names, faction_name)
        end
    end
    table.sort(names)
    faction_list = table.concat(names, ",")
    local label = #names > 0 and "Faction that invited you" or "No invitation"
    local formspec =
        "size[6,6]" ..
        "background[-2,-2;10,10;background1.png]" ..
        "label[1.5,1;" .. label .. "]" ..
        "dropdown[0.8,2.3;4,1;target_faction;" .. faction_list .. ";1]" ..
        "image_button[0.8,3.5;2,1;Cancel.png;cancel;]" ..
        "image_button[2.7,3.5;2,1;Validate.png;join_fac;]" ..
        "button[1.75,4.6;2,0.8;decline_fac;Decline]"
    core.show_formspec(player_name, "factions:invit_form", formspec)
end


-- Formspec for show the relations of the factions
function factions.show_relations_form(player_name)
    local faction_name = factions.get_player_faction(player_name)
    local faction = faction_name and factions.list[faction_name]
    if not faction then
        return
    end
    local allies_list = ""
    local enemies_list = ""

    if relations.data[faction_name] then
        for member, relation in pairs(relations.data[faction_name]) do
            if relation == "ALLIE" then
                allies_list = allies_list .. member .. ","
            elseif relation == "ENEMY" or relation == "ASKTRUCE" then 
                if relations.data[member] and relations.data[member][faction_name] == "ASKTRUCE" then
                    enemies_list = enemies_list .. member .. " (truce request),"
                else
                    enemies_list = enemies_list .. member .. ","
                end
            elseif relation == "NEUTRAL" then
                if relations.data[member] and relations.data[member][faction_name] == "ASKALLY" then
                     allies_list = allies_list .. member .. " (alliance request),"
                end
            end
        end
        allies_list = allies_list:sub(1, -2)
        enemies_list = enemies_list:sub(1, -2)
    else
        allies_list = "No ally"
        enemies_list = "No enemies"
    end

    local formspec_relation = ""
    if player_name == faction.leader then
        formspec_relation =
        "size[6,6]" ..
        "background[-2,-2;10,10;background1.png]" ..
        "label[0,1;Allies]" ..
        "label[2.7,1;Enemies]" ..
        "dropdown[0,1.5;2.7;allies_dropdown;" .. allies_list .. ";1;size=10]" ..
        "dropdown[2.7,1.5;2.7;enemies_dropdown;" .. enemies_list .. ";1]" ..
        "field[0.5,3.5;1.8,0.5;set_allies;Put ally;]" ..
        "field[4.1,3.5;1.8,0.5;set_ennemi;Put enemy;]" ..
        "image_button[0.2,4;1.8,0.8;Attribute.png;put_allies;]" ..
        "image_button[0.2,4.8;1.8,0.8;Remove.png;remove_allie;]" ..
        "image_button[3.8,4;1.8,0.8;Attribute.png;put_ennemi;]" ..
        "image_button[3.8,4.8;1.8,0.8;Remove.png;remove_ennemy;]" ..
        "image_button[2,0;2,0.8;Back.png;cancel;]"
        
    else
        formspec_relation =
            "size[6,6]" ..
            "background[-2,-2;10,10;background1.png]" ..
            "label[0.5,1;Allies]" ..
            "label[3,1;Enemies]" ..
            "dropdown[0.5,1.5;2.2;allies_dropdown;" .. allies_list .. ";1]" ..
            "dropdown[3,1.5;2.2;enemies_dropdown;" .. enemies_list .. ";1]" ..
            "image_button[2,0;2,0.8;Back.png;cancel;]"
    end

    core.show_formspec(player_name, "factions:relations_form", formspec_relation)
end



-- Function for set the home of your faction
function factions.set_faction_home(player_name)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false, "You don't belong to any faction."
    end

    local player = core.get_player_by_name(player_name)
    if not player then
        return false, "Can't find the player."
    end

    local pos = player:get_pos()
    factions.homes[faction_name] = pos

    factions.save_homes()

    return true, "Your faction's home has been successfully set."
end

-- Function for go to the faction home 
function factions.go_to_faction_home(player_name)
    local faction_name = factions.get_player_faction(player_name)

    if not faction_name then
        return false, "Your not in a faction."
    end

    if not factions.homes[faction_name] then
        return false, "No home has been defined for your faction.."
    end
    local home_pos = factions.homes[faction_name]

    local faction = factions.list[faction_name]
    if faction.members[player_name] == "waiting" then
        return false
    end

    local player = core.get_player_by_name(player_name)
    player:set_pos(home_pos)
    return true, "Teleport to faction home of '" .. faction_name .. "'."
end

-- Formspec for the roles of the faction
function factions.show_roles_form(player_name)
    local faction_name = factions.get_player_faction(player_name)
    local faction = faction_name and factions.list[faction_name]
    if not faction or not factions.can_manage(player_name, faction_name) then
        return
    end

    local member_list = ""
    local role_list = ""

    local player_role = faction.members[player_name] or ""

    if player_role == "factionleader" then
        role_list = "co-leader,membre,conseiller"
    elseif player_role == "co-leader" then
        role_list = "membre,conseiller"
    end

    for member, info in pairs(faction.members) do
        if info ~= "factionleader" and info ~= "waiting" then
            member_list = member_list .. member .. ","
        end
    end

    member_list = member_list:sub(1, -2)

    local formspec =
        "size[4,4]" ..
        "background[-2,-2;9,9;background1.png]" ..
        "label[2,0;Assign roles]" ..
        "dropdown[0.9,1;3.5;target_member;" .. member_list .. ";0]" ..
        "dropdown[0.9,2.1;3.5;target_role;" .. role_list .. ";0]" .. 
        "image_button[1,3.1;3,1;Attribute.png;assign_role;]" ..
        "image_button[0,0;2,0.8;Back.png;cancel;]"

    core.show_formspec(player_name, "factions:roles", formspec)
end

-- Formspec for invite someone
function factions.show_invite_form(player_name)
    local formspec =
        "size[4,2]" ..
        "background[-2,-1.5;8,6;background5.png]" ..
        "label[0,0;Invite a player]" ..
        "field[0.5,1;3.5,1;target_player;Name of the player;]" ..
        "image_button[0.5,1.6;3,1;Validate.png;invite_confirm;]" ..
        "image_button[2,0;2,0.8;Back.png;cancel;]"

    core.show_formspec(player_name, "factions:invite", formspec)
end

-- Function for check if your the chief of your faction
local function is_chefdefac(player)
    local faction_name = factions.get_player_faction(player)
    if not faction_name then
        return false, "You are not in any faction."
    end

    local faction = factions.list[faction_name]
    local player_name = player:get_player_name()
    if player_name == faction.leader then
        return true
    end
end

-- Function which cancel the damage if your allie with the victim or in the same faction
core.register_on_punchplayer(
    function(puncher, victim)
        if not puncher or not victim then
            return
        end

        local puncher_name = victim:get_player_name()
        local victim_name = puncher:get_player_name()

        local puncher_faction = factions.get_player_faction(puncher_name)
        local victim_faction = factions.get_player_faction(victim_name)

        if puncher_faction and victim_faction and puncher_faction == victim_faction then
            core.chat_send_player(puncher_name, "You cannot hit a member of your own faction.")
            return true
        end

        if relations.data[puncher_faction] and relations.data[puncher_faction][victim_faction] == "ALLIE" and
           relations.data[victim_faction] and relations.data[victim_faction][puncher_faction] == "ALLIE" then
            core.chat_send_player(puncher_name, "You cannot hit a member of an allied faction.")
            return true
        end
    end
)

-- Formspec for confirm the leaving
local function show_quit_confirmation(player)
    local formspec =
        "size[5,3]" ..
        "background[-2,-2;9,7;background1.png]" ..
        "label[0.5,0.5;Are you sure you want to leave the faction? ?]" ..
        "image_button[2.5,2;2,0.8;Validate.png;confirm_quit;]" ..
        "image_button[2.5,2;2,0.8;Cancel.png;cancel_quit;]"
    core.show_formspec(player:get_player_name(), "factions:quit_confirmation", formspec)
end

-- Formspec for kick someone in your faction
function factions.show_kick_form(player_name)
    local formspec =
        "size[8,5]" ..
        "background[-2,-2;12,9;background1.png]" ..
        "field[1,1.5;6,1;target_player;Name of the player;]" ..
        "label[2,0.5;Enter the name of the player to kick]" ..
        "image_button[0.8,2.2;3,1;Expel.png;kick_confirm;]" ..
        "image_button[3.8,2.2;3,1;Cancel.png;cancel;]"

    core.show_formspec(player_name, "factions:kick", formspec)
end

-- Function for promote someone to chief of the faction
factions.pending_promote = {}
function factions.promote_to_chefdefac(player_name, target_member)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false, "You are not in a faction."
    end

    local faction = factions.list[faction_name]

    if not faction.members[target_member] then
        return false, target_member .. " is not a member of the faction."
    end

    local formspec =
        "size[5,3]" ..
        "background[-2,-2;9,7;background1.png]" ..
        "label[0.5,0.5;Are you sure you want to promote " .. target_member .. " to faction leader ?]" ..
        "button[0.5,1.5;2,1;confirm_promote;Confirmer]" .. "button[2.5,1.5;2,1;cancel_promote;Annuler]"

    factions.pending_promote[player_name] = target_member

    core.show_formspec(player_name, "promote_confirmation", formspec)
end

-- Function for quit your faction
function factions.quit(player_name)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false, "You are not in any faction."
    end

    local faction = factions.list[faction_name]
    local player_rank = faction.members[player_name]

    if player_name == faction.leader then
        local co_leaders = {}
        for member, role in pairs(faction.members) do
            if role == "co-leader" then
                table.insert(co_leaders, member)
            end
        end

        if #co_leaders > 0 then
            factions.transfer_leadership(faction_name, player_name, co_leaders[1])
            return true, "A co-leader has taken your place as faction leader."
        else
            factions.dissolve_faction(faction_name, player_name)
            return true, "The faction was disbanded because no co-leader was available."
        end
    else
        faction.members[player_name] = nil
        core.chat_send_player(player_name, "You just left the faction '" .. faction_name .. "'.")
        factions.save_factions()
        return true, ""
    end
end

-- Function for dissolve a faction
function factions.dissolve_faction(faction_name, player_name)
    local faction = factions.list[faction_name]
    factions.list[faction_name] = nil
    relations.data[faction_name] = nil
    factions.remove_claims(faction_name)
    pending_clear_faction(faction_name)
    if factions.homes[faction_name] then
        factions.homes[faction_name] = nil
        factions.save_homes()
    end

    for other_faction, _ in pairs(relations.data) do
        relations.data[other_faction][faction_name] = nil
    end

    relations.save_relations(true)
    core.chat_send_player(player_name, "The faction '" .. faction_name .. "'  was disbanded.")
    factions.save_factions()
end

-- Faction for transfer the leadership
function factions.transfer_leadership(faction_name, old_leader, new_leader)
    local faction = factions.list[faction_name]

    if not faction or not faction.members[new_leader] then
        return false, "The new leader chosen is invalid."
    end

    faction.leader = new_leader
    faction.members[new_leader] = "factionleader"

    faction.members[old_leader] = nil

    core.chat_send_player(new_leader, "You are now the leader of the faction'" .. faction_name .. "'.")
    core.chat_send_player(old_leader, "You have transferred the leadership of the faction to " .. new_leader .. ".")

    factions.save_factions()
    return true
end

-- Function for send a join invite to a player in a faction
factions.send_join_invite = function(player_name, faction_name)
    if faction_name == nil or faction_name == "" or not factions.list[faction_name] then
        return false, "Please select a valid faction."
    end
    if factions.get_player_faction(player_name) then
        return false, "You are already in a faction."
    end
    -- Invited already: join directly
    if pending_get("invitations", faction_name, player_name) then
        return factions.join(player_name, faction_name)
    end
    if pending_get("join_requests", faction_name, player_name) then
        return false, "You already asked to join '" .. faction_name .. "'."
    end
    -- Record a join request (player asked to join); do NOT create an invitation entry
    pending_set("join_requests", faction_name, player_name, os.time())
    -- Offline leaders get one summarized reminder on login (see register_on_joinplayer)
    notify_managers(faction_name, player_name .. " wants to join your faction, to accept, do: /f accept " ..
        player_name .. " else, do: /f refuse " .. player_name)
    return true, "Your join request has been sent to '" .. faction_name .. "'."
end

-- Formspec for quit confirm
function show_quit_confirmation(player_name)
    local formspec =
        "size[5,3]" ..
        "background[-2,-2;9,7;background1.png]" ..
        "label[0.5,0.5;Are you sure you want to leave the faction?]" ..
        "image_button[0.5,2;2,0.8;Validate.png;confirm_quit;]" ..
        "image_button[2.5,2;2,0.8;Cancel.png;cancel_quit;]"
    core.show_formspec(player_name, "factions:quit_confirmation", formspec)
end

-- Function for assign a role to someone in your faction
function factions.assign_role(player_name, target_member, role)
    local faction_name = factions.get_player_faction(player_name)

    if not faction_name then
        return false, "You are not in a faction."
    end

    local faction = factions.list[faction_name]
    local my_role = faction.members[player_name]

    if not faction.members[target_member] then
        return false, target_member .. " is not a member of the faction."
    end

    -- Server side checks: the roles form can be forged by a client
    local allowed
    if faction.leader == player_name then
        allowed = {["co-leader"] = true, membre = true, conseiller = true}
    elseif my_role == "co-leader" then
        allowed = {membre = true, conseiller = true}
    else
        return false, "Only the faction leader or a co-leader can assign roles."
    end
    if not allowed[role] then
        return false, "You cannot assign the role " .. role .. "."
    end
    if target_member == faction.leader or target_member == player_name then
        return false, "You cannot change the role of " .. target_member .. "."
    end
    if my_role == "co-leader" and faction.members[target_member] == "co-leader" then
        return false, "A co-leader cannot change the role of another co-leader."
    end

    faction.members[target_member] = role
    factions.save_factions()
    return true, target_member .. " was assigned the role " .. role .. "."
end

-- Function for get the faction of a player
function factions.get_player_faction(player_name)
    for faction_name, faction in pairs(factions.list) do
        if faction.members[player_name] then
            return faction_name
        end
    end
    return nil
end

-- The field center which decide everything :D
core.register_on_player_receive_fields(
    function(player, formname, fields)
        local player_name = player:get_player_name()

        if formname == "factions:menu" then
            if fields.invite then
                factions.show_invite_form(player_name) 
            elseif fields.kick then
                factions.show_kick_form(player_name)
            elseif fields.quitfac then
                show_quit_confirmation(player_name)
            elseif fields.roles then
                factions.show_roles_form(player_name) 
            elseif fields.create_faction then
                factions.show_create_menu(player_name)
            elseif fields.join_faction then
                factions.show_join_form(player_name)
            elseif fields.invitform then
                factions.show_invit_form(player_name)
            elseif fields.relations then
                factions.show_relations_form(player_name)
            elseif fields.look_claims then
                factions.show_claims(player_name)
            elseif fields.go_home then
                local _, msg = factions.go_to_faction_home(player_name)
                if msg then
                    core.chat_send_player(player_name, msg)
                end
            end

        elseif formname == "factions:quit_confirmation" then
            if fields.confirm_quit then
                local success, msg = factions.quit(player_name)
                core.chat_send_player(player_name, msg)
                factions.show_menu(player_name)
            elseif fields.cancel_quit then
                factions.show_menu(player_name)
            end

        elseif formname == "factions:kick" then
            if fields.kick_confirm then
                local target_player = fields.target_player
                local faction_name = factions.get_player_faction(player_name)
    
                if target_player and target_player ~= "" then
                    local success, msg = factions.kick(player_name, faction_name, target_player)
                    core.chat_send_player(player_name, msg)
                else
                    core.chat_send_player(player_name, "Error: Please enter a valid name.")
                end
    
                factions.show_menu(player_name)
            elseif fields.cancel then
                factions.show_menu(player_name) 
            end
        
        elseif formname == "promote_confirmation" then
            if fields.confirm_promote then
                -- The target is remembered server side: never trust a client-sent name here
                local target_member = factions.pending_promote[player_name]
                factions.pending_promote[player_name] = nil
                local faction_name = factions.get_player_faction(player_name)
                local faction = faction_name and factions.list[faction_name]
                if not target_member or not faction or faction.leader ~= player_name
                        or not faction.members[target_member] then
                    return true
                end
                faction.members[player_name] = "co-leader"
                faction.members[target_member] = "factionleader"
                faction.leader = target_member
                factions.save_factions()
                core.chat_send_player(player_name, target_member .. " was promoted to faction leader.")
            elseif fields.cancel_promote then
                factions.show_menu(player_name)
            end
            
        elseif formname == "factions:create" then
            if fields.cancel then
                factions.show_menu(player_name)
            elseif fields.create then
                local target_name = fields.target_name
                if target_name and target_name ~= "" then
                    local faction_name = fields.target_name
                    if factions.list[faction_name] then
                        core.chat_send_player(player_name, "The faction " .. target_name .." already exist.")
                        return false
                    elseif factions.is_only_spaces(faction_name) then
                        core.chat_send_player(player_name, "Your faction name must contain characters.")
                        return false
                    elseif not factions.is_length_between_3_and_10(faction_name) then
                        core.chat_send_player(player_name, "Your faction name must be between 3 and 10 characters.")
                        return false
                    else
                        core.chat_send_player(player_name, "You just created the faction " .. target_name .. ".")
                    end
                    local success, message = factions.create(player_name, target_name)
                    factions.show_menu(player_name)
                    core.chat_send_player(player_name, message)
                    factions.save_factions()
                    return success
                else
                    core.chat_send_player(player_name, "Invalid faction name.")
                    factions.show_create_menu(player_name)
                end
            end
            
        elseif formname == "factions:join_faction" then
            if fields.cancel then
                factions.show_menu(player_name)
            elseif fields.join_fac then
                local target_faction = fields.target_faction
                if target_faction == nil or target_faction == "" then
                    factions.show_menu(player_name)
                    core.chat_send_player(player_name, "Please enter a valid name.")
                    return false
                end
                local _, msg = factions.send_join_invite(player_name, target_faction)
                core.chat_send_player(player_name, msg)
                factions.show_menu(player_name)
            end
            
        elseif formname == "factions:invit_form" then
            if fields.cancel then
                factions.show_menu(player_name)
            elseif fields.join_fac or fields.decline_fac then
                local target_faction = fields.target_faction
                if target_faction == nil or target_faction == "" then
                    core.chat_send_player(player_name, "Select a valid faction.")
                    return true
                end
                local _, msg
                if fields.decline_fac then
                    _, msg = factions.decline_invite(player_name, target_faction)
                else
                    _, msg = factions.join(player_name, target_faction)
                end
                core.chat_send_player(player_name, msg)
                factions.show_menu(player_name)
            end



        elseif formname == "factions:relations_form" then
            local target_faction, new_relation
            local your_faction = factions.get_player_faction(player_name)
        
            if fields.cancel then
                factions.show_menu(player_name)
                return true
            end
        
            -- Traitement des autres champs
            if fields.put_allies then
                target_faction = fields.set_allies
                new_relation = "ALLIE"
            elseif fields.remove_allie then
                target_faction = fields.set_allies
                new_relation = "NEUTRAL"
            elseif fields.put_ennemi then
                target_faction = fields.set_ennemi
                new_relation = "ENEMY"
            elseif fields.remove_ennemy then
                target_faction = fields.set_ennemi
                new_relation = "NEUTRAL"
            else
                return false
            end
        
            if not target_faction or target_faction == "" then
                return false, core.chat_send_player(player_name, "Please enter a faction name.")
            elseif your_faction == target_faction then
                return false, core.chat_send_player(player_name, "You cannot define your own political status.")
            elseif not factions.list[target_faction] then
                return false, core.chat_send_player(player_name, "No faction with that name.")
            end
        
            local success, message = relations.set_relation(player_name, your_faction, target_faction, new_relation)
            return success, message
            
            
        elseif formname == "factions:quit_confirmation" then
            if fields.confirm_leader then
                factions.quit(player_name) 
                return true
            elseif fields.cancel_quit then
                factions.show_menu(player_name)
            end
        elseif formname == "factions:invite" then
            if fields.invite_confirm then
                local target_player = fields.target_player
                if target_player and target_player ~= "" then
                    local success, msg =
                        factions.invite(player_name, factions.get_player_faction(player_name), target_player)
                    core.chat_send_player(player_name, msg)
                end
                factions.show_menu(player_name)
            elseif fields.cancel then
                factions.show_menu(player_name)
            end

        elseif formname == "factions:roles" then
            if fields.assign_role then
                local target_member = fields.target_member
                local target_role = fields.target_role
                local faction_name = factions.get_player_faction(player_name)
    
                if target_member and target_member ~= "" and target_role and target_role ~= "" then
                    local success, msg = factions.assign_role(player_name, target_member, target_role)
                    core.chat_send_player(player_name, msg)
                end
    
                factions.show_menu(player_name)
            elseif fields.cancel then
                factions.show_menu(player_name)
            end
        end
    end
)
