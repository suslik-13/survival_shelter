--[[

	Mobs Others - Adds the Snow Walkers mobs.
	Copyright © 2018, 2020 Hamlet and contributors.

	Licensed under the EUPL, Version 1.2 or – as soon they will be
	approved by the European Commission – subsequent versions of the
	EUPL (the "Licence");
	You may not use this work except in compliance with the Licence.
	You may obtain a copy of the Licence at:

	https://joinup.ec.europa.eu/software/page/eupl
	https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0863

	Unless required by applicable law or agreed to in writing,
	software distributed under the Licence is distributed on an
	"AS IS" basis,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
	implied.
	See the Licence for the specific language governing permissions
	and limitations under the Licence.

--]]


--
-- Snow Walker entity
--

mobs:register_mob('mobs_others:snow_walker', {
	--nametag = 'Snow Walker',
	type = 'monster',
	hp_min = minetest.PLAYER_MAX_HP_DEFAULT,
	hp_max = (minetest.PLAYER_MAX_HP_DEFAULT + 10),
	armor = 0,
	walk_velocity = 4,
	run_velocity = 5.2,
	stand_chance = 90,
	walk_chance = 10,
	jump = true,
	jump_height = 1.1,
	stepheight = 1.1,
	pushable = false,
	view_range = 8,
	damage = 8,
	knock_back = false,
	fear_height = 0,
	fall_damage = false,
	lava_damage = 9999,
	light_damage = 1,
	light_damage_min = 14,
	light_damage_max = 15,
	suffocation = 0,
	floats = 1,
	reach = 4,
	attack_chance = 1,
	attack_animals = true,
	attack_npcs = true,
	attack_players = true,
	group_attack = true,
	attack_type = 'dogfight',
	specific_attack = {'player', 'mobs_humans:human'},
	blood_amount = 0,
	pathfinding = 1,
	immune_to = {
		{'all'},
		{'mobs_others:sword_obsidian', 14},
		{'x_obsidianmese:sword', 14},
		{'x_obsidianmese:sword_bullet', 14},
		{'x_obsidianmese:sword_engraved', 14},
	},
	makes_footstep_sound = false,
	sounds = {
		attack = 'mobs_others_slash_attack',
		damage = 'default_cool_lava',
	},
	visual = 'mesh',
	visual_size = {x = 0.95, y = 1.15,},
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.88, 0.3},
	selectionbox = {-0.3, -1.0, -0.3, 0.3, 0.88, 0.3},
	textures = {'mobs_others_transparent'},
	mesh = 'mobs_others_character.b3d',
	animation = {
		stand_start = 0,
		stand_end = 80,
		stand_speed = 30,
		walk_start = 168,
		walk_end = 188,
		walk_speed = 30,
		run_start = 168,
		run_end = 188,
		run_speed = 35,
		punch_start = 189,
		punch_end = 199,
		punch_speed = 30,
	},
	replace_what = {'default:dirt', 'default:dirt_with_grass'},
	replace_with = 'default:dirt_with_snow',
	replace_rate = 10,
	replace_offset = -2,

	on_spawn = function(self)
		self.light_damage = mobs_others.fn_DamagePerSecond(self)
		self.textures = mobs_others.fn_RandomAppearence()

		self.object:set_properties({
			textures = self.textures
		})

		math.randomseed(os.time())

		local i_dice = math.random(1, 6)

		if (i_dice == 6) then
			local v_position = self.object:get_pos()

			minetest.add_entity(v_position, 'mobs_others:ice_monster')
		end
	end,

	on_die = function(self, pos)
		local position = {x = pos.x, y = (pos.y -1), z = pos.z}
		local node_name = minetest.get_node(position).name
		if (node_name == 'air') then
			minetest.set_node(position,
				{name = 'default:river_water_flowing'})
		end
	end
})


--
-- Snow monster entity
--

mobs:register_mob('mobs_others:ice_monster', {
	--nametag = 'Ice Monster',
	type = 'monster',
	hp_min = (minetest.PLAYER_MAX_HP_DEFAULT - 10),
	hp_max = minetest.PLAYER_MAX_HP_DEFAULT,
	armor = 95,
	walk_velocity = 1,
	run_velocity = 4,
	stand_chance = 75,
	walk_chance = 25,
	jump = true,
	jump_height = 1.1,
	stepheight = 1.1,
	pushable = true,
	view_range = 16,
	damage = 4,
	knock_back = true,
	fear_height = 3,
	lava_damage = 9999,
	light_damage = 1,
	light_damage_min = 14,
	light_damage_max = 15,
	suffocation = 0,
	floats = 1,
	reach = 4,
	attack_chance = 1,
	attack_animals = true,
	attack_npcs = true,
	attack_players = true,
	group_attack = true,
	attack_type = 'dogfight',
	specific_attack = {'player', 'mobs_humans:human'},
	blood_amount = 0,
	pathfinding = 1,
	immune_to = {
		{'all'},
		{'mobs_others:sword_obsidian', 14},
	},
	makes_footstep_sound = true,
	drops = {
		{name = "default:ice", chance = 4, min = 1, max = 2},
	},
	visual = 'mesh',
	visual_size = {x = 0.95, y = 1.15,},
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.88, 0.3},
	selectionbox = {-0.3, -1.0, -0.3, 0.3, 0.88, 0.3},
	textures = {'mobs_others_monster.png'},
	mesh = 'mobs_others_monster.b3d',
	animation = {
		stand_start = 0,
		stand_end = 40,
		stand_speed = 30,
		walk_start = 41,
		walk_end = 73,
		walk_speed = 30,
		run_start = 41,
		run_end = 73,
		run_speed = 35,
		punch_start = 74,
		punch_end = 106,
		punch_speed = 30,
	},
	replace_what = {'default:dirt', 'default:dirt_with_grass'},
	replace_with = 'default:dirt_with_snow',
	replace_rate = 10,
	replace_offset = -2,

	on_spawn = function(self)
		self.light_damage = mobs_others.fn_DamagePerSecond(self)
	end,

	on_die = function(self, pos)
		local position = {x = pos.x, y = (pos.y -1), z = pos.z}
		local node_name = minetest.get_node(position).name
		if (node_name == 'air') then
			minetest.set_node(position,
				{name = 'default:river_water_flowing'})
		end
	end
})
