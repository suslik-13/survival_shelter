--
-- player's skill table management: obj ref handler, unlocking/removing API
--

local S = core.get_translator("skills")
local NS = function(string) return string end

local get_player_by_name = core.get_player_by_name

local function init_empty_subtable(t, st) end
local function get_pl_skill_data(pl_name, internal_name) end

local string_metatable = getmetatable("")

local on_unlocks = {
	globals = {},
	specific = {} -- {"skill_prefix" = {callback1, callback2...}}
}

local skill_metatable = {
	add_entity = function(self, pos, name) 
		return skills.add_entity(self, pos, name) 
	end
}





--
--
-- CALLBACKS
--
--

core.register_on_leaveplayer(function(player, timed_out)
	local pl_name = player:get_player_name()
	-- after to execute this callback after the other ones, so that when
	-- the player is removed from the game, the player object is still valid
	core.after(0, function()
		for name, def in pairs(skills.player_skills[pl_name]) do
			def.player = nil
		end
	end)
end)



core.register_on_joinplayer(function(player)
	local pl_name = player:get_player_name()

	skills.import_player_from_db(pl_name)

	-- setting the player objectref skills pointers
	for name, def in pairs(skills.player_skills[pl_name]) do
		def.player = player
	end
end)





--
--
-- PUBLIC API
--
--

function skills.unlock_skill(pl_name, skill_name)
	skills.import_player_from_db(pl_name)

	skill_name = skill_name:lower()

	if
		not skills.does_skill_exist(skill_name)
		or pl_name:has_skill(skill_name)
	then
		if not skills.does_skill_exist(skill_name) then
			skills.log("warning", "Tried to unlock skill that doesn't exist: " .. skill_name .. " to " .. pl_name, true)
		end
		return false
	end

	-- unlocking skill
	skills.init_empty_subtable(skills.player_skills, pl_name)
	skills.init_empty_subtable(skills.player_skills[pl_name], skill_name)
	skills.init_empty_subtable(skills.player_skills[pl_name][skill_name], "data")

	local pl_skill = skills.construct_player_skill(pl_name, skill_name)
	skills.player_skills[pl_name][skill_name] = pl_skill

	-- on_unlock callbacks
	local skill_prefix = skill_name:split(":")[1]
	if on_unlocks.specific[skill_prefix] then
		for _, specific_callback in pairs(on_unlocks.specific[skill_prefix]) do
			specific_callback(pl_skill)
		end
	end
	for _, global_callback in pairs(on_unlocks.globals) do global_callback(pl_skill) end

	if pl_skill.passive then pl_skill:start() end

	return true
end
string_metatable.__index["unlock_skill"] = skills.unlock_skill



function skills.register_on_unlock(func, prefix)
	if prefix then
		on_unlocks.specific[prefix] = on_unlocks.specific[prefix] or {}
		table.insert(on_unlocks.specific[prefix], func)
	else
		table.insert(on_unlocks.globals, func)
	end
end



function skills.remove_skill(pl_name, skill_name)
	skill_name = skill_name:lower()
	local skill = pl_name:get_skill(skill_name)

	if not skill then return false end

	skill:disable()
	skills.cleanup_direct_dynamic_properties(skill.internal_name)
	skills.player_skills[pl_name][skill_name] = nil

	return true
end
string_metatable.__index["remove_skill"] = skills.remove_skill



function skills.get_skill(pl_name, skill_name)
	skills.import_player_from_db(pl_name)
	local pl_skills = skills.player_skills[pl_name]

	if not skills.does_skill_exist(skill_name) or pl_skills[skill_name:lower()] == nil then
		return false
	end

	return pl_skills[skill_name:lower()]
end
string_metatable.__index["get_skill"] = skills.get_skill



function skills.has_skill(pl_name, skill_name)
	return pl_name:get_skill(skill_name) ~= false
end
string_metatable.__index["has_skill"] = skills.has_skill



function skills.get_unlocked_skills(pl_name, prefix)
	local skills = skills.get_registered_skills(prefix)
	local unlocked_skills = {}

	for name, def in pairs(skills) do
		if pl_name:has_skill(name) then
			unlocked_skills[name] = pl_name:get_skill(name)
		end
	end

	return unlocked_skills
end
string_metatable.__index["get_unlocked_skills"] = skills.get_unlocked_skills



-- returns ["name" = skill, ...]
function skills.get_active_skills(pl_name, prefix)
	local skills = skills.get_unlocked_skills(pl_name, prefix)
	local active_skills = {}

	for name, skill in pairs(skills) do
		if skill.is_active then
			active_skills[name] = skill
		end
	end

	return active_skills
end
string_metatable.__index["get_active_skills"] = skills.get_active_skills



-- returns ["name" = state, ...]
function skills.get_active_states(pl_name, prefix)
	skills.import_player_from_db(pl_name)
	local pl_skills = skills.player_skills[pl_name]
	local active_states = {}

	for name, state in pairs(pl_skills or {}) do
		if state.is_state and state.is_active then
			-- Check prefix filter if specified
			if prefix then
				local state_prefix = name:split(":")[1]
				if state_prefix == prefix then
					active_states[name] = state
				end
			else
				active_states[name] = state
			end
		end
	end

	return active_states
end
string_metatable.__index["get_active_states"] = skills.get_active_states



function skills.get_state(pl_name, state_name)
	skills.import_player_from_db(pl_name)
	local pl_skills = skills.player_skills[pl_name]

	if not skills.does_state_exist(state_name) or pl_skills[state_name:lower()] == nil then
		return false
	end

	return pl_skills[state_name:lower()]
end
string_metatable.__index["get_state"] = skills.get_state



function skills.construct_player_skill(pl_name, skill_name)
	-- Get definition - could be skill or state
	local def = skills.get_def(skill_name)

	if not def then
		skills.log("warning", "Cannot construct player skill: no definition found for " .. skill_name)
		return nil
	end

	-- Create new skill/state instance from definition
	local skill = table.copy(def)

	setmetatable(skill, {__index = skill_metatable})

	skill.pl_name = pl_name
	skill.player = get_player_by_name(pl_name)
	skill.data = get_pl_skill_data(pl_name, skill.internal_name)

	-- Process all dynamic properties in the entire skill definition
	skills.make_dynamic_properties_table(skill, "skill", skill, true)

	return skill
end





--
--
-- PRIVATE FUNCTIONS
--
--

function skills.init_empty_subtable(table, subtable_name)
	table[subtable_name] = table[subtable_name] or {}
end



function get_pl_skill_data(pl_name, skill_name)
	local skill_def = skills.get_def(skill_name)
	if not skill_def then
		skill_def = skills.get_state_def(skill_name)
	end

	if not skill_def then
		skills.log("error", "Cannot get skill/state data: no definition found for " .. skill_name)
		return {}
	end

	local pl_data = table.copy(skills.player_skills[pl_name][skill_name].data)

	-- Migration check: if old _enabled field exists, migrate to __enabled
	if pl_data._enabled ~= nil then
		pl_data.__enabled = pl_data._enabled
		pl_data._enabled = nil
		skills.log("info", "Migrated data._enabled to data.__enabled for player " .. pl_name .. " skill " .. skill_name)
	end

	-- adding any new data's properties declared in the def table
	-- to the already existing player's data table
	for key, def_value in pairs(skill_def.data) do
		if pl_data[key] == nil then pl_data[key] = def_value end

		-- if an old property's type changed, then reset it
		if type(pl_data[key]) ~= type(def_value) then pl_data[key] = def_value end
	end

	return pl_data
end

