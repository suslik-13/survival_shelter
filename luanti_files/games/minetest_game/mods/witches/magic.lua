witches.magic = {}

local magic_texture = "bubble.png"
local magic_animation = nil
local fireflies = false
if minetest.registered_nodes["fireflies:firefly"] then
  fireflies = true
  magic_texture = "fireflies_firefly_animated.png"
  magic_animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.5
  }
else
  magic_texture = "bubble.png"
  magic_animation = nil
end

local function pos_to_vol(pos,vol)
  local pv1 = {}
  local pv2 = {}

    pv1 = vector.subtract(pos,vector.divide(vol,2))
    pv2 = vector.add(pv1,vol)
    local rvol = {pv1,pv2}
  return rvol
end

function witches.magic.effect_area01(pos1,pos2,density)
  density = density or 100
minetest.add_particlespawner({
  amount=density,
  time=.1,
  minpos= pos1,
  maxpos= pos2,
  minvel=vector.new(0, 0, 0),
  maxvel=vector.new(0, 1, 0),
  minacc=vector.new(0, 0, 0),
  maxacc=vector.new(0, 1, 0),
  minexptime=.01,
  maxexptime=.5,
  minsize=1,
  maxsize=2,
  collisiondetection=false,
  texture= magic_texture,
  animation = magic_animation,
  glow = 10,
  --player = target:get_player_name()
})
end

function witches.magic.effect_line01(pos1,pos2,density)
  pos1 = vector.round(pos1)
  pos2 = vector.round(pos2)
  density = density or 10
  local dv = vector.direction(pos1, pos2)
  local vd = math.floor(vector.distance(pos1, pos2))
  local v_pos1 = pos1
  local v_pos2 = pos1

  for i=1,vd do
    v_pos2 = vector.add(v_pos1,dv)

      minetest.add_particlespawner({
        amount=density,
        time=.1,
        minpos= v_pos1,
        maxpos= v_pos2,
        minvel= vector.new(0, 0, 0),
        maxvel= vector.new(0, 1, 0),
        minacc= vector.new(0, 0, 0),
        maxacc= vector.new(0, 1, 0),
        minexptime=.01,
        maxexptime=.5,
        minsize=1,
        maxsize=2,
        collisiondetection=false,
        texture= magic_texture,
        animation = magic_animation,
        glow = 10,
        --player = target:get_player_name()
      })
    v_pos1 = v_pos2
  end
end

function witches.magic.teleport(self,target,strength,height)
  local description = "Yeet!" --thanks to ctate for naming this so accurately!
  local caster_pos = self.object:get_pos()
  local target_pos = {}
  minetest.sound_play(self.sounds.teleport or "witches_magic01", {
		pos = caster_pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
  }, true)
  strength = strength or 8
  height = height or 5
  if target then

    if target:is_player() then

      target_pos = target:get_pos()

    elseif target:get_luaentity() then
      --same for now...
      target_pos = target:get_pos()
    else
      return
    end
    --witches.stop_and_face(self,target_pos)

      local new_target_pos = vector.add(target_pos, vector.multiply(vector.direction(caster_pos, target_pos),strength))
    new_target_pos.y = target_pos.y + height

    --print(minetest.pos_to_string(target_pos))
    --print(minetest.pos_to_string(caster_pos))
    --print(minetest.pos_to_string(new_target_pos))

    target:set_pos(new_target_pos)
    witches.magic.effect_line01(caster_pos,new_target_pos,50)

    local vol =  pos_to_vol(caster_pos,vector.new(2,2,2))

    --print(minetest.pos_to_string(caster_pos))
    --print(minetest.pos_to_string(vol[1]))
    --print(minetest.pos_to_string(vol[2]))

    witches.magic.effect_area01(vol[1],vol[2],100)

    --witches.stop_and_face(self,new_target_pos)
  end

end

function witches.magic.polymorph(self, target, mob, duration)
  duration = duration or 0
  local caster_pos = self.object:get_pos()
  minetest.sound_play(self.sounds.polymorph or "witches_magic02", {
		pos = caster_pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
  }, true)

  local ent = target:get_luaentity()
  local ent_pos = ent.object:get_pos()

  --local ent_props = ent.object:get_properties()
  --local ent_name = ent.name
  --print(dump(ent_props))

  witches.magic.effect_line01(caster_pos,ent_pos,50)
  ent.object:remove()
  local vol_ent =  pos_to_vol(ent_pos,vector.new(2,2,2))

  --print(minetest.pos_to_string(caster_pos))
  --print(minetest.pos_to_string(vol[1]))
  --print(minetest.pos_to_string(vol[2]))

  witches.magic.effect_area01(vol_ent[1],vol_ent[2],200)

	mob = mob or witches.sheep[math.random(1, #witches.sheep)]
	if mob then
		local new_obj = minetest.add_entity(ent_pos, mob)
	end

end
--volume is a vector!
function witches.magic.splash(self,target,volume,height,node)
  volume = volume or vector.new(3,3,3)
  height = height or 0
  node = node or "default:water_flowing"
  local caster_pos = self.object:get_pos()
  local ent = target:get_luaentity()
  local ent_pos = ent.object:get_pos()
  local ent_pos_yoff = vector.add(ent_pos,vector.new(0,height,0))
  local vol = pos_to_vol(ent_pos_yoff,volume)
  minetest.sound_play(self.sounds.drench or "witches_water", {
    pos = ent_pos,
    gain = 1.0,
    max_hear_distance = self.sounds and self.sounds.distance or 32
  }, true
  )

  local air_nodes = minetest.find_nodes_in_area(vol[1],vol[2], {"air"})

  if air_nodes then
    for i=1, #air_nodes do

      minetest.add_node(air_nodes[i], {name=node})
      witches.magic.effect_area01(vol[1],vol[2],100)
     --print(node.." "..minetest.pos_to_string(air_nodes[i]))
      --minetest.spawn_falling_node(i)
    end
  end






end
-- witch wands in the hands of a player turn hostile mobs into sheep

local wand_range = 16
local wand_uses = 50
local wand_max_target_hp = 100 -- bosses are too strong for this spell

local function is_hostile_mob(ent)
  if not ent or not ent._cmi_is_mob or ent.tamed or ent.health <= 0 then
    return false
  end
  if ent.type == "monster" then return true end
  return ent.attack_players and not ent.passive
end

function witches.magic.wand_polymorph(itemstack, user, pointed_thing)
  if not user or not user:is_player() then return end

  local eye = vector.add(user:get_pos(),
      vector.new(0, user:get_properties().eye_height, 0))
  local look_end = vector.add(eye,
      vector.multiply(user:get_look_dir(), wand_range))

  local target
  for pointed in minetest.raycast(eye, look_end, true, false) do
    if pointed.type == "object" and pointed.ref ~= user then
      target = pointed.ref
      break
    elseif pointed.type == "node" then
      break
    end
  end

  local ent = target and target:get_luaentity()
  if not is_hostile_mob(ent) then
    -- not a spell target, so just hit whatever is in reach like a normal tool
    if pointed_thing.type == "object" then
      pointed_thing.ref:punch(user, 1.0, itemstack:get_tool_capabilities(),
          user:get_look_dir())
    end
    return
  end

  if (target:get_properties().hp_max or 0) > wand_max_target_hp then
    minetest.chat_send_player(user:get_player_name(),
        "This creature is too powerful for your wand!")
    return
  end

  local target_pos = target:get_pos()
  minetest.sound_play("witches_magic02", {
    pos = target_pos,
    gain = 1.0,
    max_hear_distance = 32
  }, true)
  witches.magic.effect_line01(eye, target_pos, 50)
  local vol = pos_to_vol(target_pos, vector.new(2,2,2))
  witches.magic.effect_area01(vol[1], vol[2], 200)

  target:remove()
  minetest.add_entity(target_pos, witches.sheep[math.random(1, #witches.sheep)])

  if not minetest.is_creative_enabled(user:get_player_name()) then
    itemstack:add_wear_by_uses(wand_uses)
  end
  return itemstack
end

for _, wand in ipairs({"witches:witch_wand_sp", "witches:witch_wand_btb"}) do
  minetest.override_item(wand, {on_use = witches.magic.wand_polymorph})
end
