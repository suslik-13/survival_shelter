-- Fixes to mobs_redo shared by every mob (BACKLOG 16). A dying mob keeps the
-- cause of death with the puncher object in it; a tame or npc mob saved then
-- (shutdown, unload during the death animation) crashed the serializer. The
-- cause is left out of the saved data and kept for the death drops.
core.register_on_mods_loaded(function()
	local mobs = rawget(_G, "mobs")
	local class = mobs and mobs.mob_class
	if not (class and class.mob_staticdata) then
		return
	end
	local mob_staticdata = class.mob_staticdata
	class.mob_staticdata = function(self, ...)
		local cause = self.cause_of_death
		self.cause_of_death = nil
		local ok, sd = pcall(mob_staticdata, self, ...)
		self.cause_of_death = cause
		if not ok then
			error(sd, 0)
		end
		return sd
	end
end)
