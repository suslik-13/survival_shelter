
local S = protector.intllib

-- get static spawn position
local statspawn = minetest.string_to_pos(minetest.settings:get("static_spawnpoint"))
		or {x = 0, y = 2, z = 0}

-- is spawn protected
local protector_spawn = 53

-- is night-only pvp enabled
local protector_night_pvp = true


-- custom start

function is_pvp_area(pos)
  local no_pvp_areas = {
    {x1=5810, y1=13, z1=2772, x2=5888, y2=27, z2=2813},
    {x1=1126.0, y1=7, z1=2004, x2=1177.0, y2=35, z2=2055.0},
    {x1=4052, y1=-100, z1=-4827, x2=4184, y2=100, z2=-4693},
    {x1=-30912, y1=-2, z1=-30912, x2=-30894, y2=12, z2=-30883},
    -- можно добавить дополнительные запрещенные зоны здесь
  }
  
  for _, area in ipairs(no_pvp_areas) do
	    	if pos.x >= area.x1 and pos.x <= area.x2 and
	       	pos.y >= area.y1 and pos.y <= area.y2 and
	        pos.z >= area.z1 and pos.z <= area.z2 then
      -- игрок находится в запрещенной зоне
      		return true
    		end
  	end
  
  -- игрок не находится в запрещенной зоне
  	return false
end


-- custom end


-- custom start

function is_area_protect(pos)
  local no_pvp_areas = {
    {x1=80.0, y1=-12, z1=-109, x2=106.0, y2=26, z2=-72.0},
    {x1=12086.0, y1=9900, z1=17188, x2=12416.0, y2=11111, z2=17542.0},
    {x1=4432.0, y1=-1, z1=5490, x2=4502.0, y2=68, z2=5545.0},
    -- можно добавить дополнительные запрещенные зоны здесь
  }
  
  for _, area in ipairs(no_pvp_areas) do
	    	if pos.x >= area.x1 and pos.x <= area.x2 and
	       	pos.y >= area.y1 and pos.y <= area.y2 and
	        pos.z >= area.z1 and pos.z <= area.z2 then
      -- игрок находится в запрещенной зоне
      		return true
    		end
  	end
  
  -- игрок не находится в запрещенной зоне
  	return false
end


-- custom end


-- disables PVP in your own protected areas
if true --minetest.settings:get_bool("enable_pvp")
and true then

	if minetest.register_on_punchplayer then

		minetest.register_on_punchplayer(function(player, hitter,
				time_from_last_punch, tool_capabilities, dir, damage)

			if not player
			or not hitter then
				print("[MOD] Protector - on_punchplayer called with nil objects")
			end

			if not hitter:is_player() then
				return false
			end

			-- no pvp at spawn area
			local pos = player:get_pos()

			if pos.x < statspawn.x + protector_spawn
			and pos.x > statspawn.x - protector_spawn
			and pos.y < statspawn.y + protector_spawn
			and pos.y > statspawn.y - protector_spawn
			and pos.z < statspawn.z + protector_spawn
			and pos.z > statspawn.z - protector_spawn then
				return true
			end
			
			-- custom start
			
			if is_pvp_area(pos) then
				return false
			end
			
			if is_area_protect(pos) then
				return true
			end
			
			
			-- custom end

			-- do we enable pvp at night time only ?
			if protector_night_pvp then

				-- get time of day
				local tod = minetest.get_timeofday() or 0

				if tod > 0.2 and tod < 0.8 then
					--
				else
					return false
				end
			end

			-- is player being punched inside a protected area ?
			if minetest.is_protected(pos, hitter:get_player_name()) then
				return true
			end

			return false

		end)
	else
		print("[MOD] Protector - pvp_protect not active, update your version of Minetest")

	end
else
	print("[MOD] Protector - pvp_protect is disabled")
end
