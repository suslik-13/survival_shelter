local S = minetest.get_translator("tntrun")

arena_lib.on_load("tntrun", function(arena)
  for k = 1, #arena.tnt_area_pos_1 do
    local pos1 = arena.tnt_area_pos_1[k]
    local pos2 = arena.tnt_area_pos_2[k]
    local x1 = pos1.x
    local x2 = pos2.x
    local y1 = pos1.y
    local y2 = pos2.y
    local z1 = pos1.z
    local z2 = pos2.z
    if x1 > x2 then
        local temp = x2
        x2 = x1
        x1 = temp
    end
    if y1 > y2 then
        local temp = y2
        y2 = y1
        y1 = temp
    end
    if z1 > z2 then
        local temp = z2
        z2 = z1
        z1 = temp
    end

    for x = x1,x2 do
        for y = y1,y2 do
            for z = z1,z2 do
                minetest.set_node({x=x,y=y,z=z}, {name="tntrun:tnt"})
            end
        end
    end
  end

  local item = ItemStack("tntrun:torch")

  for pl_name, stats in pairs(arena.players) do
      local player = minetest.get_player_by_name(pl_name)
      player:get_inventory():set_stack("main", 1, item)
  end

  for pl_name, stats in pairs(arena.players) do
    local message = S('How it work:')
    minetest.chat_send_player(pl_name,message)
    message = minetest.colorize('Yellow', S('Punch with torches TNT to fight with other players'))
    minetest.chat_send_player(pl_name,message)
    message = minetest.colorize('Red', S('But warning, the TNT on which you standing fall down'))
    minetest.chat_send_player(pl_name,message)
    arena.players[pl_name].lives = arena.lives

  end
end)

arena_lib.on_death('tntrun', function(arena, p_name, reason)
    arena_lib.remove_player_from_arena(p_name, 1)
end)

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	local stack = ItemStack("tntrun:torch")
	local taken = inv:remove_item("main", stack)
end)
