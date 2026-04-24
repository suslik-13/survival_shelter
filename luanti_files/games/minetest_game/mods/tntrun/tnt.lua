local recursive_time = 0.1

local S = minetest.get_translator("tntrun")

minetest.register_node("tntrun:tnt",{
  tiles = {"tnt_top.png", "tnt_bottom.png", "tnt_side.png"},
  groups = {cracky = 3},
  description = "TNT in tntrun",

  on_punch = function(pos, node, puncher)
    if puncher:get_wielded_item():get_name() == "tntrun:torch" then
      minetest.swap_node(pos, {name = "tntrun:tnt_falling"})
      minetest.registered_nodes["tntrun:tnt_falling"].on_construct(pos)
    end
  end,
  drops = "tntrun:tnt",
})

minetest.register_node("tntrun:tnt_falling",{
  groups = {falling_node = 2, cracky = 3},
  tiles = {
    {
      name = "tnt_top_burning_animated.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1,
      }
    },
    "tnt_bottom.png", "tnt_side.png"
    },
  not_in_creative_inventory = true,
  drops = "tntrun:tnt",
  on_construct = function(pos)
    minetest.get_node_timer(pos):start(4)
    minetest.check_for_falling(pos)
  end,
  on_timer = function(pos)
    minetest.remove_node(pos)
    minetest.swap_node(pos, {name = "air"})
  end,
})

minetest.register_craftitem("tntrun:torch",{
  inventory_image = "default_torch_on_floor.png",
  description = S("Torch for TNT")
})


arena_lib.on_start("tntrun", function(arena)
  tnt_loop(arena)
end)

function tnt_loop(arena)

  if not arena.in_game then return end

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)
    local pos = player:get_pos()
    pos.y = pos.y - 1
    if minetest.get_node(pos).name == "tntrun:tnt" then
      minetest.after(1, function()
      minetest.remove_node(pos)
      minetest.swap_node(pos, {name = "tntrun:tnt_falling"})
      minetest.registered_nodes["tntrun:tnt_falling"].on_construct(pos)
    end)
  end
end

  minetest.after(recursive_time, function() tnt_loop(arena) end)
end
