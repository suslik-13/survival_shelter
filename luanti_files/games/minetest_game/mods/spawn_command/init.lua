
spawn_command = {}
spawn_command.pos = {x=0, y=3, z=0}
local cursed_world_exists = minetest.get_modpath("cursed_world")

if minetest.setting_get_pos("static_spawnpoint") then
    spawn_command.pos = minetest.setting_get_pos("static_spawnpoint")
end

function teleport_to_spawn(name)

    local player = minetest.get_player_by_name(name)
    if player == nil then
        -- just a check to prevent the server crashing
        return false
    end
    local pos = player:get_pos()
    
    	-- custom start
			
			if is_sethome_protect(pos) then
				minetest.chat_send_player(name, "** You cannot spawn from this territory! **")
				return
			end	
	
	-- custom end
    
    
    if math.abs(spawn_command.pos.x-pos.x)<20 and math.abs(spawn_command.pos.z-pos.z)<20 then
        minetest.chat_send_player(name, "Already close to spawn!")
    elseif cursed_world_exists and _G['cursed_world'] ~= nil and    --check global table for cursed_world mod
        cursed_world.location_y and cursed_world.dimension_y and
        pos.y < (cursed_world.location_y + cursed_world.dimension_y) and    --if player is in cursed world, stay in cursed world
        pos.y > (cursed_world.location_y - cursed_world.dimension_y)
    then   --check global table for cursed_world mod
        --minetest.chat_send_player(name, "T"..(cursed_world.location_y + cursed_world.dimension_y).." "..(cursed_world.location_y - cursed_world.dimension_y))
        local spawn_pos = vector.round(spawn_command.pos);
        spawn_pos.y = spawn_pos.y + cursed_world.location_y;
        player:set_pos(spawn_pos)
        minetest.chat_send_player(name, "Teleported to spawn!")
    else
        player:set_pos(spawn_command.pos)
        minetest.chat_send_player(name, "Teleported to spawn!")
    end
end

-- custom start

function is_spawn_protect(pos)
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

minetest.register_chatcommand("spawn", {
    description = "Teleport you to spawn point.",
    func = teleport_to_spawn,
})

