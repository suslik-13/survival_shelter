local after = core.after
local get_us_time = core.get_us_time


function skills.cast(self, ...)
	-- Store varargs for dynamic values
	self.__varargs = {...}
	
	-- if not looped then can_start is checked too
	if not self.loop_params and self.can_start and not self:can_start(...) then
		return false
	end
	if self.can_cast and not self:can_cast(...) then
		return false
	end

	if not skills.basic_checks_in_order_to_work(self, ...) then
		self:stop()
		return false
	end

	-- if skill stopped
	if
		(not self.is_active and (self.loop_params or self.passive))
		or self.__is_stopping
	then
		return false
	end

	if self.cooldown_timer > 0 and not self.loop_params then
		skills.print_remaining_cooldown_seconds(self)
		return false
	end

	-- calculate dtime
	local current_us_time = get_us_time()
	if not self.__last_us_time then
		local server_step = core.settings:get("dedicated_server_step")
		local intended_rate =
			(self.loop_params and self.loop_params.cast_rate ~= 0 and self.loop_params.cast_rate) or server_step
		self.__last_us_time = current_us_time
		self.__dtime = intended_rate
	else
		self.__dtime = (current_us_time - self.__last_us_time) / 1000000
		self.__last_us_time = current_us_time
	end

	if self:logic(...) == false then
		self:stop()
		return false
	end

	skills.sound_play(self, self.sounds.cast, true)

	if self.loop_params and self.loop_params.cast_rate then
		after(self.loop_params.cast_rate, self.cast, self, ...)
	end

	if not self.loop_params then
		skills.start_cooldown(self)
	end

	return true
end
