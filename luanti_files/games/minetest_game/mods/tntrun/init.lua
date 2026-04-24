local S = minetest.get_translator("tntrun")
tntrun = {}
dofile(minetest.get_modpath("tntrun") .. "/settings.lua")

local player_jump = tntrun.player_jump
local player_speed = tntrun.player_speed


arena_lib.register_minigame("tntrun", {
  celebration_time = 10,
  load_time = 10,
  prefix = "[Sp] ",
  hub_spawn_point = tntrun.hubspawnpoint,
  queue_waiting_time = 20,
  show_minimap = true,
  properties = {
    tnt_area_pos_1 = {{x = 0, y = 0, z = 0}},
    tnt_area_pos_2 = {{x = 0, y = 0, z = 0}},
  },
  in_game_physics = {
    speed = player_speed,
    jump = player_jump,
  },

  disabled_damage_types = {"punch"},
  hotbar = {
    slots = 1,
    background_image = "tntrun_gui_hotbar.png"
  },

})

minetest.register_privilege("tntrun", S("Needed for Tntrun"))

if not minetest.get_modpath("lib_chatcmdbuilder") then
    dofile(minetest.get_modpath("tntrun") .. "/chatcmdbuilder.lua")
end
dofile(minetest.get_modpath("tntrun") .. "/nodes.lua")
dofile(minetest.get_modpath("tntrun") .. "/auto.lua")
dofile(minetest.get_modpath("tntrun") .. "/tnt.lua")


ChatCmdBuilder.new("tntrun", function(cmd) -- In music is a music Cusade by KevinMacLeod which should using for one map

  -- create arena
  cmd:sub("create :arena", function(name, arena_name)
      arena_lib.create_arena(name, "tntrun", arena_name)
  end)

  cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
      arena_lib.create_arena(name, "tntrun", arena_name, min_players, max_players)
  end)

  -- remove arena
  cmd:sub("remove :arena", function(name, arena_name)
      arena_lib.remove_arena(name, "tntrun", arena_name)
  end)

  -- list of the arenas
  cmd:sub("list", function(name)
      arena_lib.print_arenas(name, "tntrun")
  end)

  -- enter editor mode
  cmd:sub("edit :arena", function(sender, arena)
      arena_lib.enter_editor(sender, "tntrun", arena)
  end)

  -- enable and disable arenas
  cmd:sub("enable :arena", function(name, arena)
      arena_lib.enable_arena(name, "tntrun", arena)
  end)

  cmd:sub("disable :arena", function(name, arena)
      arena_lib.disable_arena(name, "tntrun", arena)
  end)

end, {
  description = [[

    (/help tntrun)

    Use this to configure your arena:
    - create <arena name> [min players] [max players]
    - edit <arena name>
    - enable <arena name>

    Other commands:
    - remove <arena name>
    - disable <arena>
    ]],
    privs = {
        tntrun = true
    },
})


arena_lib.on_enable("tntrun", function(arena, p_name)
  if #arena.tnt_area_pos_1 ~= #arena.tnt_area_pos_2 then
    minetest.chat_send_player(p_name,"Missing params in the positions")
    return false
  end
  return true
end)
