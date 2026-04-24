dynamic_values = {
	-- key: skill_name.subtable1.subtable2.etc.key, values: dynamic value
}



skills.dynamic_properties_metatable = {
	-- filtering access to the table, getting dynamic values from an external table
	__index = function(t, key)
		local id = rawget(t, "_id")
		local skill = rawget(t, "_skill")

		if not id then
			skills.log("error", "skills.dynamic_properties_metatable.__index called without _id on table " .. dump(t), true)
		elseif not skill then
			skills.log("error", "skills.dynamic_properties_metatable.__index called without _skill on table " .. dump(t), true)
		end

		-- Check for dynamic value using the full hierarchical ID
		if key then
			local full_id = id .. "." .. key
			if dynamic_values[full_id] then
				return skills.get_value(skill, dynamic_values[full_id])
			end
		end

		local value = rawget(t, key)
		if value ~= nil then
			return value
		end

		-- Fallback to original metatable for skill methods
		local original_metatable = rawget(t, "_original_metatable")
		if original_metatable and original_metatable.__index then
			if type(original_metatable.__index) == "function" then
				return original_metatable.__index(t, key)
			elseif type(original_metatable.__index) == "table" then
				return original_metatable.__index[key]
			end
		end

		return nil
	end,

	-- never storing dynamic values, but storing them in a separate table instead
	__newindex = function(t, key, value)
		if skills.is_dynamic_value(value) then
			local id = rawget(t, "_id")
			if key then
				local full_id = id .. "." .. key
				dynamic_values[full_id] = value
			end
			rawset(t, key, nil)
		else
			rawset(t, key, value)
		end
	end
}


function skills.does_table_contain_dynamic_values(t)
	for key, val in pairs(t) do
		if skills.is_dynamic_value(val) then return true end
		if type(val) == "table" then
			if skills.does_table_contain_dynamic_values(val) then return true end
		end
	end
	return false
end



function skills.make_dynamic_properties_table(skill, id, table, recursive, prev_table)
	if type(table) ~= "table" or not skills.does_table_contain_dynamic_values(table) then return table end

	table._skill = skill
	-- For root skill object, use just the skill name instead of adding another level
	if id == "skill" and not prev_table then
		table._id = skill.internal_name
		-- Store original metatable for fallback
		table._original_metatable = getmetatable(table)
	else
		local prev_id = (prev_table and prev_table._id) or skill.internal_name
		table._id = prev_id .. "." .. id
	end

	if recursive == nil then recursive = true end
	if recursive then
		for key, value in pairs(table) do
			-- ASSUMING: there are no other circular references other than _skill
			if type(value) == "table" and key ~= "_skill" then
				skills.make_dynamic_properties_table(skill, key, value, true, table)
			end
		end
	end

	-- reconstructing table, storing dynamic values in a separate table
	for key, value in pairs(table) do
		skills.dynamic_properties_metatable.__newindex(table, key, value)
	end

	return setmetatable(table, skills.dynamic_properties_metatable)
end



function skills.dynamic_value(func)
	return {
		dynamic_value = true,
		get_value = func
	}
end



function skills.get_value(skill, val, ...)
	if val.get_value then
		-- Pass skill first, then the stored varargs from the skill
		local stored_varargs = skill.__varargs or {}
		return val.get_value(skill, unpack(stored_varargs))
	else
		return val
	end
end



function skills.is_dynamic_value(val)
	return type(val) == "table" and val.dynamic_value
end



function skills.cleanup_direct_dynamic_properties(skill_internal_name)
	if dynamic_values[skill_internal_name] then
		dynamic_values[skill_internal_name] = nil
	end
end
