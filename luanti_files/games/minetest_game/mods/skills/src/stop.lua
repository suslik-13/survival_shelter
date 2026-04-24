local function restore_celestial_vault(skill) end
local table_copy = table.copy


function skills.stop(self, cancelled)
	if not self.is_active or self.__is_stopping then return false end
	if not core.get_player_by_name(self.pl_name) then return false end

	local should_restart_passives = self.blocks_other_skills or self.blocks_other_states

	local bgm = table_copy(self.__bgm or {})
	local particles = table_copy(self.__particles or {})
	local hud = table_copy(self.__hud or {})

	self.__is_stopping = true

	-- I don't know. MT is weird or maybe my code is just bugged:
	-- without this after, if the skills ends very quickly the
	-- spawner and the sound simply... don't stop.
	core.after(0, function()
		-- Stop sound
		skills.sound_stop(bgm)

		-- Remove particles
		if particles then
			for i, spawner_id in pairs(particles) do
				core.delete_particlespawner(spawner_id)
			end
		end

		-- Remove hud
		if hud then
			for name, id in pairs(hud) do
				self.player:hud_remove(id)
			end
		end

		self.__is_stopping = false
		self.is_active = false
		
		-- Restart passive skills AFTER this skill/state is no longer active
		if should_restart_passives then
			skills.cast_passive_skills(self.pl_name)
		end
	end)

	self.__bgm = {}
	self.__hud = {}
	self.__particles = {}
	self.__stop_job = nil

	-- Reset physics
	if self.physics then
		local reverse = {
			["multiply"] = "divide",
			["divide"] = "multiply",
			["add"] = "sub",
			["sub"] = "add",
		}
		local operation = reverse[self.physics.operation] -- multiply/divide/add/sub

		for property, value in pairs(self.physics) do
			if property ~= "operation" then
				_G["skills"][operation .. "_physics"](self.pl_name, property, value)
			end
		end
	end

	-- Deapply monoids
	if self.monoids then
		skills.remove_monoids(self)
		skills.update_player_monoids_branches(self, self.pl_name)
	end

	if not cancelled then
		skills.sound_play(self, self.sounds.stop, true)
		restore_celestial_vault(self)
		self:on_stop()
	end

	self.__dtime = nil
	self.__last_us_time = nil

	-- remove state from player skills to avoid persistence
	if self.is_state then
		skills.player_skills[self.pl_name][self.internal_name] = nil
	end

	return true
end



function restore_celestial_vault(skill)
	local cel_vault = skill.celestial_vault or {}

	-- Restore sky
	if cel_vault.sky and skill.__sky then
		local pl = skill.player
		pl:set_sky(skill.__sky)
		skill.__sky = {}
	end

	-- Restore clouds
	if cel_vault.clouds and skill.__clouds then
		local pl = skill.player
		pl:set_clouds(skill.__clouds)
		skill.__clouds = {}
	end

	-- Restore moon
	if cel_vault.moon and skill.__moon then
		local pl = skill.player
		pl:set_moon(skill.__moon)
		skill.__moon = {}
	end

	-- Restore sun
	if cel_vault.sun and skill.__sun then
		local pl = skill.player
		pl:set_sun(skill.__sun)
		skill.__sun = {}
	end

	-- Restore stars
	if cel_vault.stars and skill.__stars then
		local pl = skill.player
		pl:set_stars(skill.__stars)
		skill.__stars = {}
	end
end
