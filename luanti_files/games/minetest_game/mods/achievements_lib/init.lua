local version = "1.0.0"

dofile(minetest.get_modpath("achievements_lib") .. "/api.lua")
dofile(minetest.get_modpath("achievements_lib") .. "/player_manager.lua")

minetest.log("action", "[ACHIEVEMENTS_LIB] Mod initialised, running version " .. version)
