--
-- skill validation, registration APIs
--

local S = core.get_translator("skills")
local NS = function(string) return string end

local function validate_skill_def(internal_name, def) end
local function validate_prefix_config(internal_name, def) end
local function initialize_def(internal_name, def) end
local function initialize_callbacks(def) end
local function join_defs(s1, s2) end
local function extract_logic(def) end





--
--
-- PUBLIC API
--
--

function skills.register_skill(internal_name, def)
	local prefix = string.split(internal_name, ":")[1]
	local config = skills.prefix_configs[prefix]

	if config and config.base_layers then
		skills.register_skill_based_on(config.base_layers, internal_name, def)
	else
		skills.register_single_skill(internal_name, def)
	end
end



function skills.register_single_skill(internal_name, def)
	validate_skill_def(internal_name, def)
	def = initialize_def(internal_name, def)
	skills.registered_skills[internal_name:lower()] = def
end



function skills.register_layer(internal_name, def)
	validate_skill_def(internal_name, def)
	def.is_layer = true
	skills.register_single_skill(internal_name, def)
end



function skills.register_state(internal_name, def)
	validate_skill_def(internal_name, def)
	def.is_state = true
	skills.register_single_skill(internal_name, def)
end



function skills.register_state_based_on(original, variant_name, def)
	def.is_state = true -- mark as state before calling
	skills.register_skill_based_on(original, variant_name, def)
end



function skills.register_prefix_config(prefix, config)
	validate_prefix_config(prefix, config)
	skills.prefix_configs[prefix] = config
end



function skills.register_skill_based_on(original, variant_name, def)
	validate_skill_def(variant_name, def)

	def.internal_name = variant_name:lower()
	def.is_layer = false -- to avoid inheriting this from lower layers

	local is_state = def.is_state -- check if it's marked as a state

	local layers = {}

	-- getting the base layers
	local prefix = string.split(def.internal_name, ":")[1]
	local config = skills.prefix_configs[prefix]
	if config and config.base_layers then
		layers = table.copy(config.base_layers)
	end

	-- adding the original state/skill, if it's a string
	if type(original) == "string" then
		table.insert(layers, original)
	else
		-- insert all elements of original in the layers
		for _, name in ipairs(original) do
			local item_type = is_state and "State/skill" or "Skill"
			skills.assert(
				skills.registered_skills[name:lower()],
				item_type .. " '" .. name .. "' does not exist but '" .. variant_name .. "' is based on it. Make sure to register it first."
			)
			table.insert(layers, name)
		end
	end

	-- composing the layers
	local previous = nil
	for _, name in ipairs(layers) do
		local current = table.copy(skills.get_def(name))

		if previous then
			previous = join_defs(previous, current)
		else
			previous = current
		end
	end
	def = join_defs(previous, extract_logic(def))
	
	-- Explicitly set the is_state property based on intention
	if is_state then
		def.is_state = true -- ensure the final result is still marked as a state
	else
		def.is_state = nil -- ensure skills don't inherit is_state from layers
	end

	skills.registered_skills[def.internal_name] = def
end



function skills.get_skill_def(skill_name)
	skills.log("warning", ("skills.get_skill_def('%s') is deprecated, use skills.get_def('%s') instead"):format(skill_name, skill_name))

	return skills.get_def(skill_name)
end



function skills.get_def(skill_name)
	if not skills.registered_skills[skill_name:lower()] then
		return false
	end

	return skills.registered_skills[skill_name:lower()]
end



function skills.get_state_def(state_name)
	if not skills.registered_skills[state_name:lower()] then
		return false
	end
	
	local def = skills.registered_skills[state_name:lower()]
	if not def.is_state then
		return false
	end

	return def
end



function skills.does_skill_exist(skill_name)
	return
		skill_name
		and skills.registered_skills[skill_name:lower()]
		and not skills.registered_skills[skill_name:lower()].is_layer
		and not skills.registered_skills[skill_name:lower()].is_state
end



function skills.does_state_exist(state_name)
	return
		state_name
		and skills.registered_skills[state_name:lower()]
		and skills.registered_skills[state_name:lower()].is_state
end



function skills.does_layer_exist(layer_name)
	return
		layer_name
		and skills.registered_skills[layer_name:lower()]
		and skills.registered_skills[layer_name:lower()].is_layer
end



function skills.get_registered_skills(prefix)
	local registered_skills = {}

	for name, def in pairs(skills.registered_skills) do
		if def.is_layer or def.is_state then goto continue end

		if prefix and name:sub(1, #prefix + 1) == prefix .. ":" then
			registered_skills[name] = def
		elseif prefix == nil then
			registered_skills[name] = def
		end

		::continue::
	end

	return registered_skills
end



function skills.get_registered_layers(prefix)
	local registered_layers = {}

	for name, def in pairs(skills.registered_skills) do
		if not def.is_layer then goto continue end

		if prefix and name:sub(1, #prefix + 1) == prefix .. ":" then
			registered_layers[name] = def
		elseif prefix == nil then
			registered_layers[name] = def
		end

		::continue::
	end

	return registered_layers
end



function skills.get_registered_states(prefix)
	local registered_states = {}

	for name, def in pairs(skills.registered_skills) do
		if not def.is_state then goto continue end

		if prefix and name:sub(1, #prefix + 1) == prefix .. ":" then
			registered_states[name] = def
		elseif prefix == nil then
			registered_states[name] = def
		end

		::continue::
	end

	return registered_states
end





--
--
-- PRIVATE FUNCTIONS
--
--

local function validate_def(table_id, params, def)
	local function is_list(t)
		return type(t) == "table" and #t > 0 and t[1] ~= nil and not (type(next(t)) == "string" and t._id)
	end

	for name, param in pairs(params) do
		local value = def[name]
		if value == nil or skills.is_dynamic_value(value) or value == "@@nil" then
			goto continue
		end

		if param.type == "list" then
			skills.assert(is_list(value), table_id .. ": The field " .. name .. " must be a list (ordered numeric indexes)")
		else
			local type_matches = false
			if type(param.type) == "table" then
				-- multiple allowed types
				for _, allowed_type in ipairs(param.type) do
					if type(value) == allowed_type then
						type_matches = true
						break
					end
				end
				if not type_matches then
					local type_list = table.concat(param.type, " or ")
					skills.assert(false, table_id .. ": The field '" .. name .. "' must be a " .. type_list)
				end
			else
				-- single type
				skills.assert(type(value) == param.type, table_id .. ": The field '" .. name .. "' must be a " .. param.type)
			end
		end

		-- validate subelements
		if param.subelements then
			for subname, subparam in pairs(param.subelements) do
				local subvalue = value[subname]
				if subvalue == nil or subvalue == "@@nil" or skills.is_dynamic_value(subvalue) then
					-- the subelement is optional or being overridden to nil
					goto continue
				end

				local name_chain = name .. "." .. subname
				if param.subelements[subname].parent then
					name_chain = param.subelements[subname].parent .. "." .. name_chain
				end

				if subparam.type == "list" then
					skills.assert(
						is_list(subvalue),
						table_id .. ": The subelement " .. name_chain .. " must be a list (ordered numeric indexes)"
					)
				else
					skills.assert(
						type(subvalue) == subparam.type,
						table_id .. ": The subelement " .. name_chain .. " must be a " .. subparam.type
					)
				end
			end
		end

		::continue::
	end

	return true
end



function validate_skill_def(internal_name, def)
	local params = {
		name = {type = "string"},
		description = {type = "string"},
		sounds = {
			type = "table",
			subelements = {
				cast = {type = "table"},
				start = {type = "table"},
				stop = {type = "table"},
				bgm = {type = "table"},
			}
		},
		attachments = {
			type = "table",
			subelements = {
				particles = {type = "list"},
				entities = {type = "list"},
			}
		},
		loop_params = {
			type = "table",
			subelements = {
				cast_rate = {type = "number"},
				duration = {type = "number"},
			}
		},
		celestial_vault = {
			type = "table",
			subelements = {
				sky = {type = "table"},
				moon = {type = "table"},
				sun = {type = "table"},
				stars = {type = "table"},
				clouds = {type = "table"},
			}
		},
		blocks_other_skills = {type = "table"},
		stop_on_death = {type = "boolean"},
		passive = {type = "boolean"},
		hud = {type = "list"},
		physics = {type = "table"},
		data = {type = "table"},
		monoids = {
			type = "table",
			optional = true,
		},
		can_cast = {type = "function"},
		can_start = {type = "function"},
		on_start = {type = "function"},
		on_stop = {type = "function"},
	}

	validate_def(internal_name, params, def)
end



function validate_prefix_config(prefix, def)
	local params = {
		base_layers = {type = "list"},
	}

	validate_def(prefix, params, def)
end



function initialize_def(internal_name, def)
	def.internal_name = internal_name
	def.description = def.description
	def.sounds = def.sounds or {}
	def.attachments = def.attachments or {}
	def.cooldown_timer = 0
	def.is_active = false
	def.data = def.data or {}
	def.on_start = def.on_start or function () return true end
	def.on_stop = def.on_stop or function () return true end
	def.data = def.data or {}
	def.data.__enabled = true

	if def.attachments.entities then
		core.register_on_mods_loaded(function()
			for _, entity in ipairs(def.attachments.entities) do
				skills.set_expiring_entity(entity.name)
			end
		end)
	end

	local sounds = def.sounds
	if sounds.bgm then
		if not skills.is_sound_pool(sounds.bgm) then
			sounds.bgm.loop = true
		else
			for _, sound in ipairs(sounds.bgm) do
				sound.loop = true
			end
		end
	end

	initialize_callbacks(def)

	return def
end



function extract_logic(def)
	def.logic = def.cast or function() end
	return def
end



function initialize_callbacks(def)
	-- copying cast to preserve the unwrapped version
	extract_logic(def)

	def.cast = function(self, ...)
		return skills.cast(self, ...)
	end

	def.start = function(self, ...)
		return skills.start(self, ...)
	end

	def.stop = function(self, cancelled)
		return skills.stop(self, cancelled)
	end

	def.add_entity = function(self, pos, name)
		return skills.add_entity(self, pos, name)
	end

	def.disable = function(self)
		if not self.data.__enabled then return false end

		self:stop()
		self.data.__enabled = false

		return true
	end

	def.enable = function(self)
		if self.data.__enabled then return false end

		self.data.__enabled = true
		if self.passive then
			self.pl_name:start_skill(self.internal_name)
		end

		return true
	end

	return def
end



function join_defs(s1, s2)
	local excluded = {
		-- since these are just the wrappers
		cast = true,
		start = true,
		stop = true,
		add_entity = true,
		-- these are not customizable
		disable = true,
		enable = true
	}

	for key, value in pairs(s1) do
		if not excluded[key] and type(s1[key]) == "function" and type(s2[key]) == "function" then
			local original_s1_func = s1[key]

			s1[key] = function(self, ...)
				if original_s1_func(self, ...) ~= false then
					return s2[key](self, ...)
				else
					return false
				end
			end
		end
	end

	-- to copy functions that are not in s1
	return skills.override_params(s1, s2)
end
