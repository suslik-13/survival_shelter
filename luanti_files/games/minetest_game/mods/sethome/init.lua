-- sethome/init.lua

sethome = {}

-- Load support for MT game translation.
local S = minetest.get_translator("sethome")


local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
	local input = io.open(homes_file, "r")
	if not input then
		return -- no longer an error
	end

	-- Iterate over all stored positions in the format "x y z player" for each line
	for pos, name in input:read("*a"):gmatch("(%S+ %S+ %S+)%s([%w_-]+)[\r\n]") do
		homepos[name] = minetest.string_to_pos(pos)
	end
	input:close()
end

loadhomes()

sethome.set = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player or not pos then
		return false
	end
	local player_meta = player:get_meta()
	player_meta:set_string("sethome:home", minetest.pos_to_string(pos))

	-- remove `name` from the old storage file
	if not homepos[name] then
		return true
	end
	local data = {}
	local output = io.open(homes_file, "w")
	if output then
		homepos[name] = nil
		for i, v in pairs(homepos) do
			table.insert(data, string.format("%.1f %.1f %.1f %s\n", v.x, v.y, v.z, i))
		end
		output:write(table.concat(data))
		io.close(output)
		return true
	end
	return true -- if the file doesn't exist - don't return an error.
end

sethome.get = function(name)
	local player = minetest.get_player_by_name(name)
	local player_meta = player:get_meta()
	local pos = minetest.string_to_pos(player_meta:get_string("sethome:home"))
	if pos then
		return pos
	end

	-- fetch old entry from storage table
	pos = homepos[name]
	if pos then
		return vector.new(pos)
	else
		return nil
	end
end

sethome.go = function(name)
	local pos = sethome.get(name)
	local player = minetest.get_player_by_name(name)
	if player and pos then
		player:set_pos(pos)
		return true
	end
	return false
end

-- custom start

function is_sethome_protect(pos)
  local no_bones_areas = {
    {x1=1126.0, y1=7, z1=2004, x2=1177.0, y2=35, z2=2055.0},
    {x1=5810.0, y1=13, z1=2772, x2=5888.0, y2=27, z2=2813.0},
    {x1=5456.0, y1=-50, z1=25544, x2=5570.0, y2=140, z2=25653.0},
    {x1=24955.0, y1=-100, z1=-14428, x2=25096.0, y2=130, z2=-14282.0},
    -- можно добавить дополнительные запрещенные зоны здесь
  }
  
  for _, area in ipairs(no_bones_areas) do
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

minetest.register_privilege("home", {
	description = S("Can use /sethome and /home"),
	give_to_singleplayer = false
})

minetest.register_chatcommand("home", {
	description = S("Teleport you to your home point"),
	privs = {home = true},
	func = function(name)
	
	-- custom start
			local position = minetest.get_player_by_name(name):get_pos()
			
			if is_sethome_protect(position) then
				return false, S("** It is forbidden to go home position from this area! **")
			end	
	
	-- custom end
	
	
		if sethome.go(name) then
			return true, S("Teleported to home!")
		end
		return false, S("Set a home using /sethome")
	end,
})

minetest.register_chatcommand("sethome", {
	description = S("Set your home point"),
	privs = {home = true},
	func = function(name)	
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		-- custom start
		if player then
		
			local position = player:get_pos()
			if is_sethome_protect(position) then
				return false, S("** It is forbidden to set up a home position in this area! **")
			else
				if player and sethome.set(name, player:get_pos()) then
					return true, S("Home set!")
				end
			end	
		end
			-- custom end	
			
		
		
		return false, S("Player not found!")
	end,
})
