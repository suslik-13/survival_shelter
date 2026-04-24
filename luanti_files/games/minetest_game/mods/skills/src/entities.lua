local expire_entities = {} -- "entity" = true



function skills.register_expiring_entity(name, def)
	core.register_entity(name, def)
	skills.set_expiring_entity(name)
end



function skills.add_entity(skill, pos, name)
	if expire_entities[name] then
		return core.add_entity(pos, name, core.serialize({pl_name = skill.pl_name, skill_name = skill.internal_name}))
	else
		skills.log("error", "Tried to spawn an entity that isn't expiring: " .. name, true)
		return false
	end
end



function skills.set_expiring_entity(name)
	local on_step = core.registered_entities[name].on_step or function(_, _, _) end
	local on_activate = core.registered_entities[name].on_activate or function(_, _, _) end

	local function remove(self)
		local handled = false
		if self.on_remove then handled = self:on_remove() end
		if not handled then self.object:remove() end
	end

	-- Overriding the entity's callbacks & properties
	if not expire_entities[name] then
		core.registered_entities[name].initial_properties = core.registered_entities[name].initial_properties or {}
		core.registered_entities[name].initial_properties.static_save = false
		core.registered_entities[name].pl_name = ""


		-----------------
		-- ON ACTIVATE --
		-----------------

		core.registered_entities[name].on_activate = function(self, staticdata, dtime_s)
			staticdata = core.deserialize(staticdata) or {}

			if type(staticdata) ~= "table" or not staticdata.pl_name or not staticdata.skill_name then
				self.object:remove()
				return
			end

			self.pl_name = staticdata.pl_name
			self.skill = self.pl_name:get_skill(staticdata.skill_name)
			self.player = self.skill.player

			if not self.skill or not self.skill.is_active then
				self.object:remove()
				return
			end

			on_activate(self, staticdata, dtime_s)
		end


		-------------
		-- ON STEP --
		-------------

		core.registered_entities[name].on_step = function(self, dtime, moveresult)
			-- if spawned by a skill, remove the entity if the skill has stopped
			if self.skill and not self.skill.is_active then
				remove(self)
				return
			end

			on_step(self, dtime, moveresult)
		end

		expire_entities[name] = true
	end
end



function skills.attach_expiring_entity(skill, def)
	local pos = def.pos
	local name = def.name
	local bone = def.bone or ""
	local rotation = def.rotation or {x = 0, y = 0, z = 0}
	local forced_visible = def.forced_visible or false

	local entity = skill:add_entity(pos, name)
	if not entity then
		skills.log("error", skill.internal_name .. " skill tried to attach an entity that isn't expiring: " .. name, true)
		return false
	end
	entity:set_attach(skill.player, bone, pos, rotation, forced_visible)
end
