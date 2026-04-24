local function remove_userdata(t) end
local function keep_just_data(t) end
local function filter_states(t) end

local storage = core.get_mod_storage()



core.register_on_mods_loaded(function()
	skills.update_db()
end)



-- Saving player skills to the DB.
-- This function only saves the skills tables structure and their data, like:
-- "player1": {
--     {"mod:skill1" = {data: {...}},
--     {"mod:skill2" = {data: {...}}
-- }
function skills.update_db(just_once, end_callback, total_transactions, pl_data)
	local max_db_transactions_per_step = 20
	local transactions = 0
	total_transactions = total_transactions or 0

	pl_data = pl_data or filter_states(table.copy(skills.player_skills))
	if total_transactions == 0 then keep_just_data(pl_data) end

	-- save at most max_db_transactions_per_step records
	-- and call this function again after one step if
	-- there are more
	local i = 0
	for pl_name, data in pairs(pl_data) do
		i = i + 1

		if transactions == max_db_transactions_per_step then
			total_transactions = total_transactions + transactions

			core.after(0, function()
				skills.update_db(just_once, end_callback, total_transactions, pl_data)
			end)

			return
		end

		if i > total_transactions then -- avoid saving again the same records
			local old_data = core.deserialize(storage:get_string("pl_data:" .. pl_name))
			-- we keep the old data that couldn't get loaded (e.g. temporarily disabled mods)
			local final_data = skills.override_params(old_data, data)
			storage:set_string("pl_data:" .. pl_name, core.serialize(final_data))
			transactions = transactions + 1
		end
	end

	if end_callback then end_callback() end

	if not just_once then
		core.after(10, skills.update_db)
	end
end



function skills.import_player_from_db(pl_name)
	if skills.player_skills[pl_name] then
		return skills.player_skills[pl_name]
	end

	skills.player_skills[pl_name] = core.deserialize(storage:get_string("pl_data:" .. pl_name)) or {}

	for skill_name, data in pairs(skills.player_skills[pl_name]) do
		local constructed_skill = skills.construct_player_skill(pl_name, skill_name)

		-- Remove corrupted/old entries from database
		if not(type(data) == "table") or data.is_state then
			skills.log("warning", "Removing corrupted entry from database: " .. skill_name .. " for player " .. pl_name)
			skills.player_skills[pl_name][skill_name] = nil
			goto continue
		end
		
		if constructed_skill then
			skills.player_skills[pl_name][skill_name] = constructed_skill

		else
			-- if the skill became a layer, remove it
			skills.player_skills[pl_name][skill_name] = nil
		end
		
		::continue::
	end

	return skills.player_skills[pl_name]
end



-- calls callback(pl_name, skills) for each player in the DB
function skills.for_each_player_in_db(callback)
	local storage_table = storage:to_table()
	local string_match = string.match

	for record_key, value in pairs(storage_table.fields) do
		if string_match(record_key, "pl_data:") then
			local pl_name = record_key:gsub("pl_data:", "")
			callback(pl_name, skills.import_player_from_db(pl_name))
		end
	end

	skills.update_db("just_once", function()
		-- removing offline players from player_skills
		local is_online = core.get_player_by_name
		for pl_name, _ in pairs(skills.player_skills) do
			if not is_online(pl_name) then
				skills.player_skills[pl_name] = nil
			end
		end
	end)
end



function skills.remove_unregistered_skills_from_db()
	skills.for_each_player_in_db(function(pl_name, pl_skills)
		for skill_name, def in pairs(pl_skills) do
			if not skills.get_def(skill_name) then pl_skills[skill_name] = nil end
		end
	end)
end



function remove_userdata(t)
	for key, value in pairs(t) do
		if type(value) == "table" then remove_userdata(value) end
		if core.is_player(value) or type(value) == "userdata" or type(value) == "function" then t[key] = nil end
	end
end



function keep_just_data(t)
	if type(t) ~= "table" then
		skills.log("error", "keep_just_data received " .. type(t) .. " instead of table: " .. tostring(t))
		return
	end

	for pl_name, skills_table in pairs(t) do
		if type(skills_table) ~= "table" then
			skills.log("error", "Player " .. pl_name .. " has " .. type(skills_table) .. " instead of table: " .. tostring(skills_table))
			goto continue
		end

		for name, table in pairs(skills_table) do
			if type(table) ~= "table" then
				skills.log("error", "Skill/State " .. name .. " for player " .. pl_name .. " has " .. type(table) .. " instead of table: " .. tostring(table))
				goto continue_inner
			end

			-- Exclude states from being saved (states are ephemeral)
			if table.is_state then
				skills_table[name] = nil
				goto continue_inner
			end

			for key, value in pairs(table) do
				if key ~= "data" then
					table[key] = nil
				else
					remove_userdata(table.data)
				end
			end
			::continue_inner::
		end
		::continue::
	end
end



function filter_states(data)
	local filtered_data = {}

	for pl_name, skills_table in pairs(data) do
		filtered_data[pl_name] = {}

		for skill_name, skill_data in pairs(skills_table) do
			if not skill_data.is_state then
				filtered_data[pl_name][skill_name] = skill_data
			end
		end
	end

	return filtered_data
end
