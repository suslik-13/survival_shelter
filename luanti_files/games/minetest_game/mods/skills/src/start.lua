local function change_celestial_vault(skill) end



function skills.start(self, ...)
	if self.can_start and not self:can_start(...) then
		return false
	end

	local attachments = self.attachments
	local loop_params = self.loop_params
	local sounds = self.sounds

	if not skills.basic_checks_in_order_to_work(self, ...) then
		self:stop()
		return false
	end

	-- not a loopable skill or already started
	if (not loop_params and not self.on_start and not self.on_stop) or self.is_active then
		return false
	end

	if self.cooldown_timer > 0 then
		skills.print_remaining_cooldown_seconds(self)
		return false
	end

	self.is_active = true
	self.__last_start_timestamp = core.get_us_time() -- Add timestamp
	self.__varargs = {...} -- Store varargs for dynamic values

	-- Create hud
	if self.hud then
		self.__hud = {}

		for i, hud_element in ipairs(self.hud) do
			local name = hud_element.name
			self.__hud[name] = self.player:hud_add(hud_element)
		end
	end

	-- Attach entities
	if attachments.entities then
		for i, entity_def in ipairs(attachments.entities) do
			skills.attach_expiring_entity(self, entity_def)
		end
	end

	-- Change physics_override
	if self.physics then
		if not self.physics.operation then
			self.physics.operation = "multiply"
		end
		local operation = self.physics.operation -- multiply/divide/add/sub

		for property, value in pairs(self.physics) do
			if property ~= "operation" then
				_G["skills"][operation .. "_physics"](self.pl_name, property, value)
			end
		end
	end

	-- Apply monoids
	if self.monoids then
		skills.apply_monoids(self)
		if self.monoids.checkout_branch_while_active then
			skills.checkout_skills_monoids(self)
		end
	end

	if self:on_start(...) == false then
		self:stop("cancelled")
		return false
	end

	-- Create particle spawners
	if attachments.particles then
		self.__particles = {}

		for i, spawner in ipairs(attachments.particles) do
			spawner.attached = self.player
			self.__particles[i] = core.add_particlespawner(spawner)
		end
	end

	change_celestial_vault(self)

	if self.blocks_other_skills then
		skills.block_other_skills(self)
	end
	
	if self.blocks_other_states then
		skills.block_other_states(self)
	end

	-- Play sounds
	skills.sound_play(self, sounds.start, true)
	self.__bgm = skills.sound_play(self, sounds.bgm)

	-- Stop skill after duration
	if loop_params and loop_params.duration then
		self.__stop_job = core.after(loop_params.duration, function() self:stop() end)
	end

	skills.start_cooldown(self)

	if loop_params and loop_params.cast_rate then
		self:cast(...)
	end

	return true
end



function change_celestial_vault(skill)
	local cel_vault = skill.celestial_vault or {}

	-- Change sky
	if cel_vault.sky then
		local pl = skill.player
		skill.__sky = pl:get_sky(true)
		pl:set_sky(cel_vault.sky)
	end

	-- Change moon
	if cel_vault.moon then
		local pl = skill.player
		skill.__moon = pl:get_moon()
		pl:set_moon(cel_vault.moon)
	end

	-- Change sun
	if cel_vault.sun then
		local pl = skill.player
		skill.__sun = pl:get_sun()
		pl:set_sun(cel_vault.sun)
	end

	-- Change stars
	if cel_vault.stars then
		local pl = skill.player
		skill.__stars = pl:get_stars()
		pl:set_stars(cel_vault.stars)
	end

	-- Change clouds
	if cel_vault.clouds then
		local pl = skill.player
		skill.__clouds = pl:get_clouds()
		pl:set_clouds(cel_vault.clouds)
	end
end
