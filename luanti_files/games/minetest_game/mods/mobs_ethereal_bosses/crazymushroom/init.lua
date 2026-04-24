
-- SOUND :
-- https://freesound.org/people/Volvion/sounds/609780/ (CC0)
-- https://freesound.org/people/newagesoup/sounds/348244/ (CC0)

mobs:register_mob("crazymushroom:crazymushroom", {
--	stay_near = {"ethereal:mushroom_dirt", 10},
	nametag = "Crazy Mushroom Boss" ,
	type = "monster",
	passive = false,
	attack_npcs = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 8,
	damage = 18,
--	knockback = 2,
	hp_min = 1200,
	hp_max = 1200,
	armor = 80,
	collisionbox = {-0.7, -0.7, -0.7, 0.7,3.5, 0.7},
	visual = "mesh",
	visual_size = {x = 13, y = 13},
	mesh = "crazymushroom2.b3d",
	--rotate = 180,
	textures = {
		{"crazymushrrom2.png"},
	},
--	glow = 2,
	blood_texture = "ethereal_mushroom_sapling.png",
	makes_footstep_sound = true,
	sounds = {
		random = "crazyman",
--		attack = "",
--		death = "",
	},

	walk_velocity = 2,
	run_velocity = 4,
	jump_height = 5,
	stepheight = 3.0,
	floats = 0,
	view_range = 35,
	drops = {
		{name = "ebitems:glove_glove", chance = 1, min = 1, max = 1},
		{name = "ebitems:crazymushrrom_trophy", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 1,
	light_damage = 0,
	animation = {
		speed_normal = 20,
		speed_run = 20,
		stand_start = 0,
		stand_end = 0,
		walk_start = 20,
		walk_end = 60,
		run_start = 70,
		run_end = 90,
		punch_start = 100,
		punch_end = 120,
	},


	--do_custom = function(self, dtime)
	--end,

	
	--- REFERENCIA DO MINECLONE2 BOSS?
	on_die = function(self, pos) -- POSIÇÃO
		if minetest.get_modpath("awards") then
			-- CONSEGUIR RADIUS ( POSIÇÃO ,55 NODES?)
			for _,players in pairs(minetest.get_objects_inside_radius(pos, 55)) do
				-- SE PLAYER
				if players:is_player() then
					-- DESBLOQUEAR CONQUISTAS?
					awards.unlock(players:get_player_name(), "crazym")
				end
			end
		end
	end
})


-- ADICIONANDO ATAQUE QUE MUDA O POSIÇÃO


minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir)
  if name ~= nil and hitter:get_luaentity().name == "crazymushroom:crazymushroom" then
    player:set_pos({x=player:get_pos().x+2,y=player:get_pos().y+1,z=player:get_pos().z})
    minetest.sound_play("punch_boxing", {pos = pos, gain = 0.5})
  end
end)

mobs:spawn({
	name = "crazymushroom:crazymushroom",
	nodes = {"ethereal:mushroom_dirt", "ethereal:mushroom"},
	max_light = 7,
	interval = 60,
	chance = 300000,
	max_height = 200,
	min_height = 0,
})


mobs:register_egg("crazymushroom:crazymushroom", "crazymushroom",
		"ethereal_mushroom_block.png", 1)
