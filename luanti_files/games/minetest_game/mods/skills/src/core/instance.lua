--
-- skill instance management: start/stop/enable/disable, lifecycle management: passive casting, basic checks...
--



local S = core.get_translator("skills")
local NS = function(string) return string end

local get_player_by_name = core.get_player_by_name
local string_metatable = getmetatable("")





--
--
-- CALLBACKS
--
--

core.register_on_joinplayer(function(player)
	-- after to make sure other mods initialized
	core.after(0, function()
		skills.cast_passive_skills(player:get_player_name())
	end)
end)



core.register_on_leaveplayer(function(player, timed_out)
	local pl_name = player:get_player_name()
	local pl_skills = pl_name:get_unlocked_skills()

	for skill_name, def in pairs(pl_skills) do
		def:stop()
	end
end)



core.register_on_respawnplayer(function(player)
	skills.cast_passive_skills(player:get_player_name())
end)





--
--
-- PUBLIC API
--
--

function skills.cast_skill(pl_name, skill_name, ...)
	local skill = pl_name:get_skill(skill_name)

	if skill then
		return skill:cast(...)
	else
		return false
	end
end
string_metatable.__index["cast_skill"] = skills.cast_skill



function skills.start_skill(pl_name, skill_name, ...)
	local skill = pl_name:get_skill(skill_name)

	if skill then
		return skill:start(...)
	else
		return false
	end
end
string_metatable.__index["start_skill"] = skills.start_skill



function skills.stop_skill(pl_name, skill_name)
	local skill = pl_name:get_skill(skill_name)

	if skill then
		return skill:stop()
	else
		return false
	end
end
string_metatable.__index["stop_skill"] = skills.stop_skill



function skills.enable_skill(pl_name, skill_name)
	local skill = pl_name:get_skill(skill_name)

	if not skill then return false end

	return skill:enable()
end
string_metatable.__index["enable_skill"] = skills.enable_skill



function skills.disable_skill(pl_name, skill_name)
	local skill = pl_name:get_skill(skill_name)

	if not skill then return false end

	return skill:disable()
end
string_metatable.__index["disable_skill"] = skills.disable_skill



function skills.basic_checks_in_order_to_work(skill, ...)
	-- Check if this item (skill or state) is blocked by any active logic
	local pl_skills = skills.player_skills[skill.pl_name]
	for item_name, item_instance in pairs(pl_skills) do
		if item_instance.is_active and item_name ~= skill.internal_name then
			-- Use the appropriate utility function based on what we're trying to start
			local is_blocked = false
			if skill.is_state then
				is_blocked = skills.should_state_be_blocked(skill.internal_name, item_instance)
			else
				is_blocked = skills.should_skill_be_blocked(skill.internal_name, item_instance)
			end
			
			if is_blocked then
				return false
			end
		end
	end

	local player = get_player_by_name(skill.pl_name)

	if not player then return false end
	if (skill.stop_on_death or skill.stop_on_death == nil) and player:get_hp() <= 0 then return false end

	if not skill.data.__enabled then
		if skills.settings.chat_warnings.disabled ~= false then
			skills.error(skill.pl_name, S("You can't use the @1 skill now", skill.name))
		end

		return false
	end

	return true
end



function skills.add_state(pl_name, state_name, ...)
	skills.import_player_from_db(pl_name)

	if not skills.does_state_exist(state_name) then
		skills.log("warning", "Tried to add state that doesn't exist: " .. state_name .. " to " .. pl_name, true)
		return false
	end

	state_name = state_name:lower()

	-- If state doesn't exist for player, unlock it automatically
	if not skills.player_skills[pl_name] or not skills.player_skills[pl_name][state_name] then
		skills.init_empty_subtable(skills.player_skills, pl_name)
		skills.init_empty_subtable(skills.player_skills[pl_name], state_name)
		skills.init_empty_subtable(skills.player_skills[pl_name][state_name], "data")

		local pl_state = skills.construct_player_skill(pl_name, state_name)
		if not pl_state then
			skills.log("error", "Failed to construct player state: " .. state_name .. " for " .. pl_name, true)
			-- Clean up the empty tables we created
			if skills.player_skills[pl_name] and skills.player_skills[pl_name][state_name] then
				skills.player_skills[pl_name][state_name] = nil
			end
			return false
		end
		skills.player_skills[pl_name][state_name] = pl_state
	end

	local state = pl_name:get_state(state_name)
	if state then
		return state:start(...)
	else
		skills.log("error", "Failed to get valid state instance for " .. state_name .. " - got: " .. tostring(state), true)
		return false
	end
end
string_metatable.__index["add_state"] = skills.add_state



function skills.remove_state(pl_name, state_name)
	local state = pl_name:get_state(state_name)

	if state then
		return state:stop()
	end
end
string_metatable.__index["remove_state"] = skills.remove_state
