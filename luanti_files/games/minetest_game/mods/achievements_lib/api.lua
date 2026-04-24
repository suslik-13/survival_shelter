achvmt_lib = {}



----------------------------------------------
---------------DICHIARAZIONI------------------
----------------------------------------------

local function update_storage() end

local storage = minetest.get_mod_storage()
local achievements = {}       -- KEY: mod; VALUE: {KEY: achievement ID; VALUE: {whatever properties}
local p_achievements = {}     -- KEY: p_name; VALUE: {KEY: mod, VALUE: {KEY: achievement ID VALUE: true/nil}}}


-- inizializzo storage caricando tutti i giocatori
for pl_name, mods in pairs(storage:to_table().fields) do
  p_achievements[pl_name] = minetest.deserialize(mods)
end




----------------------------------------------
-------------------CORPO----------------------
----------------------------------------------

function achvmt_lib.register_achievements(mod, mod_achievements)
  assert(achievements[mod] == nil, "[ACHIEVEMENTS_LIB] There was an attempt to register the mod " .. mod .. " more than once! Be sure you didn't call this function twice and you didn't install any suspicious mod")
  achievements[mod] = mod_achievements
end



function achvmt_lib.unlock_achievement(p_name, mod, achvmt_ID)

  local achievement = achievements[mod][achvmt_ID]

  if achievement == nil then return end
  if p_achievements[p_name][mod][achvmt_ID] ~= nil then return end

  p_achievements[p_name][mod][achvmt_ID] = true
  update_storage(p_name)

end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function achvmt_lib.has_player_achievement(p_name, mod, achvmt_ID)
  return p_achievements[p_name][mod][achvmt_ID] ~= nil
end



function achvmt_lib.is_player_in_storage(p_name, mod)
  if p_achievements[p_name] then
    if mod and p_achievements[p_name][mod] then
      return true
    else
      return false
    end
  else
    return false
  end
end



-- INTERNAL USE ONLY
function achvmt_lib.add_player_to_storage(p_name)

  if not minetest.get_player_by_name(p_name) then
    minetest.log("Warning", "[ACHIEVEMENTS_LIB] Player " .. p_name .. " must be online in order to be added to the storage!")
    return end

  if not p_achievements[p_name] then
    p_achievements[p_name] = {}
  end

  local update_storage = false

  for mod, _ in pairs(achievements) do
    if not achvmt_lib.is_player_in_storage(p_name, mod) then
      p_achievements[p_name][mod] = {}
      update_storage = true
    end
  end

  if update_storage then
    storage:set_string(p_name, minetest.serialize(p_achievements[p_name]))
  end
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function achvmt_lib.get_achievement(mod, achvmt_ID)
  return achievements[mod][achvmt_ID]
end



function achvmt_lib.get_player_achievements(p_name, mod)
  return p_achievements[p_name][mod]
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function update_storage(p_name)
  storage:set_string(p_name, minetest.serialize(p_achievements[p_name]))
end





----------------------------------------------
------------------DEPRECATED------------------
----------------------------------------------

function achvmt_lib.add_achievement(p_name, mod, achvmt_ID)
	minetest.log("warning", "[ACHIEVEMENTS_LIB] (" .. mod .. ") achvmt_lib.add_achievement is deprecated: use unlock_achievement instead")
	achvmt_lib.unlock_achievement(p_name, mod, achvmt_ID)
end
