function skills.error(pl_name, msg)
	core.chat_send_player(pl_name, core.colorize("#f47e1b", "[!] " .. msg))
	core.sound_play("skills_error", {to_player = pl_name})
end



function skills.print(pl_name, msg)
	core.chat_send_player(pl_name, msg)
end



---@param level string none, error, warning, action, info (default), verbose
function skills.log(level, msg, stacktrace)
	if stacktrace then
		stacktrace = "\n" .. debug.traceback()
	else
		stacktrace = ""
	end

	if not msg then
		msg = level
		level = "info"
	end
	core.log(level, "[SKILLS] " .. msg .. stacktrace)
end



function skills.assert(condition, msg)
	assert(condition, "[SKILLS] " .. msg)
end



function skills.override_params(original, new)
	local output = table.copy(original or {})

	for key, new_value in pairs(new) do
		if new_value == "@@nil" then
			-- Directly set to nil, don't recurse
			output[key] = nil
		elseif type(new_value) == "table" and output[key] and type(output[key]) == "table" then
			output[key] = skills.override_params(output[key], new_value)
		elseif type(new_value) ~= "function" then
			output[key] = new_value
		elseif not original[key] then
			output[key] = new_value
		end
	end

	return output
end



-- Generic blocking logic that works for both skills and states
function skills.should_logic_be_blocked(item_name, blocker_skill, blocker_field)
	local item_def = skills.get_def(item_name)
	if not item_def then return false end

	local blocker_def = blocker_skill[blocker_field]

	if not blocker_def or type(blocker_def) ~= "table" then
		return false
	end

	local item_prefix = item_name:match("^([^:]+):")

	-- Check mode and filtering
	if blocker_def.mode == "all" then
		return item_name ~= blocker_skill.internal_name
	elseif blocker_def.mode == "whitelist" then
		if not blocker_def.allowed then return true end -- No allowed list means block all except self

		-- Check if item is in allowed list (by prefix or full name)
		for _, allowed_item in ipairs(blocker_def.allowed) do
			if item_name == allowed_item or (item_prefix and item_prefix == allowed_item) then
				return false -- Item is allowed, don't block it
			end
		end
		return item_name ~= blocker_skill.internal_name -- Block if not in whitelist and not self
	elseif blocker_def.mode == "blacklist" then
		-- Block items in the blocked list
		if not blocker_def.blocked then return false end -- No blocked list means don't block anything

		-- Check if item is in blocked list (by prefix or full name)
		for _, blocked_item in ipairs(blocker_def.blocked) do
			if item_name == blocked_item or (item_prefix and item_prefix == blocked_item) then
				return true -- Item is in blacklist, block it
			end
		end
		return false -- Not in blacklist, don't block
	end

	return false
end



function skills.should_skill_be_blocked(skill_name, blocker_skill)
	return skills.should_logic_be_blocked(skill_name, blocker_skill, "blocks_other_skills")
end



function skills.block_other_skills(skill)
	local pl_skills = skills.player_skills[skill.pl_name]
	if not pl_skills then return end

	for skill_name, skill_instance in pairs(pl_skills) do
		if not skill_instance.is_state and skill_instance.is_active then
			if skills.should_skill_be_blocked(skill_name, skill) then
				skill.pl_name:stop_skill(skill_name)
			end
		end
	end
end



function skills.cast_passive_skills(pl_name)
	for name, def in pairs(skills.get_unlocked_skills(pl_name)) do
		if def.passive and def.data.__enabled then
			pl_name:start_skill(name)
		end
	end
end



function skills.get_active_skills_stack(pl_name, prefix, filter_predicate)
	local active_skills = skills.get_active_skills(pl_name, prefix)
	local final_skills = {}

	-- sort by skill.__last_start_timestamp [1: earliest, 2: latest]
	table.sort(active_skills, function(a, b)
		return a.__last_start_timestamp < b.__last_start_timestamp
	end)

	if filter_predicate then
		for name, skill in pairs(active_skills) do
			if filter_predicate(skill) then
				table.insert(final_skills, skill)
			end
		end
	else
		final_skills = active_skills
	end

	return final_skills
end



function skills.should_state_be_blocked(state_name, blocker_skill)
	return skills.should_logic_be_blocked(state_name, blocker_skill, "blocks_other_states")
end



function skills.block_other_states(skill)
	-- Get all active states for the player
	local pl_skills = skills.player_skills[skill.pl_name]
	if not pl_skills then return end

	for state_name, state_instance in pairs(pl_skills) do
		if state_instance.is_state and state_instance.is_active then
			if skills.should_state_be_blocked(state_name, skill) then
				-- Stop the state but don't remove it entirely
				state_instance:stop()
			end
		end
	end
end
