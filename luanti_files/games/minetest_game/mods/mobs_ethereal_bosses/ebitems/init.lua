
-- Obsidian Sword ( Não faz mais parte do jogo, mas n estar removida)

minetest.register_tool("ebitems:sword_obsidian", {
	wield_scale = {x = 1.5, y = 1.5, z = 2.5},
	description = "Obsidian Sword",
	inventory_image = "obsidian_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 1,
		groupcaps = {
			snappy = {
				times = {[1] = 1.70, [2] = 0.70, [3] = 0.25},
				uses = 80,
				maxlevel = 3
			},
		},
		damage_groups = {fleshy = 12},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})


-- ESPADA FLAMEJANTE :

minetest.register_tool("ebitems:flaming_sword", {
	wield_scale = {x = 1.5, y = 1.5, z = 2.5},
	description = "Flaming Sword",
	inventory_image = "flaming_sword.png",
	light =12 ,
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 1,
		groupcaps = {
			snappy = {
				times = {[1] = 1.70, [2] = 0.70, [3] = 0.25},
				uses = 80,
				maxlevel = 3
			},
		},
		damage_groups = {fleshy = 12 , fire=1},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1},

	

})


-- LUVA DE COGUMELO ===========================================================================

if minetest.global_exists("armor") and armor.elements then
	table.insert(armor.elements, "hand")
end


if minetest.get_modpath("3d_armor") then

	armor:register_armor("ebitems:glove_glove", {
		description = "Glove",
		inventory_image = "ebitems_inv_glove_glove.png",
		groups = {
			armor_hand = 2, armor_heal = 2, armor_use = 40,
			physics_speed = 0.5, physics_jump = 0.5
		},
	})
end




-- TROFÉUS : =================================================================================

minetest.register_node("ebitems:frostyqueen_trophy", {
	description = "Frosty Queen Trophy",
	drawtype = "mesh",
	mesh = "trofeus_ethreal.obj",
	tiles = {"trufeus_frostyqueen.png"},
	use_texture_alpha = "clip",
	wield_scale = {x = 1, y = 1, z = 1},
	groups = {dig_immediate = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	-- CAIXA DE COLISÃO :
	selection_box = {
		type = "fixed", -- fica no formato da caixa se ajustado
		fixed = {
			{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5},
		},
	},
})

minetest.register_node("ebitems:crazymushrrom_trophy", {
	description = "Crazy Mushrrom Trophy",
	drawtype = "mesh",
	mesh = "trofeus_ethreal.obj",
	tiles = {"trufeus_crazymushroom.png"},
	use_texture_alpha = "clip",
	wield_scale = {x = 1, y = 1, z = 1},
	groups = {dig_immediate = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	-- CAIXA DE COLISÃO :
	selection_box = {
		type = "fixed", -- fica no formato da caixa se ajustado
		fixed = {
			{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5},
		},
	},
})

minetest.register_node("ebitems:heated_trophy", {
	description = "Heated Trophy",
	drawtype = "mesh",
	mesh = "trofeus_ethreal.obj",
	tiles = {"trufeus_heated.png"},
	use_texture_alpha = "clip",
	wield_scale = {x = 1, y = 1, z = 1},
	groups = {dig_immediate=3},
	paramtype = "light",
	paramtype2 = "facedir",
	-- CAIXA DE COLISÃO :
	paramtype2 = "facedir",
	selection_box = {
		type = "fixed", -- fica no formato da caixa se ajustado
		fixed = {
			{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5},
		},
	},
})




---- ITENS : ========================================================================================

-- CURA MILAGROSA :
-- Sound : https://freesound.org/people/craigglenday/sounds/517173/ (CC0)

minetest.register_craftitem("ebitems:miraclehealing", {
	description = "Miracle Healing ",
	inventory_image = "miraclehealing.png",
	stack_max = 1,
	groups = {vessel = 1},
	-- função para recuperar vida simples
	on_use = function(itemstack, user, pointed_thing,pos)
		local hp = user:get_hp() -- usuario consegue o valor atual de sua vida
		if hp ~= 20 then -- comparando vida
			user:set_hp(hp + 10)  -- atribuindo mais 10 de vida
		end

		minetest.sound_play("bebendo", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 5,
		}, true)

		local pos = user:get_pos()

		for i = 1, 30 do

			minetest.add_particle({
				pos = pos,
				acceleration = 0,
				velocity = {
					x = math.random(-3, 3),
					y = math.random(-3, 3),
					z = math.random(-3, 3)
				},
				-- x ou y ,ou z  = random (-3 right , 3 left )
				size = 2,
				expirationtime = 2.0,
				collisiondetection = false,
				vertical = false,
				texture = "curam.png",
				glow = 8,
			})
		end

		return  "vessels:glass_bottle"
	end
})

minetest.register_craft({
	output = "ebitems:miraclehealing 3",
	recipe = {
		{"", "default:diamond", ""},
		{"depthseye:deye", "depthseye:deye", "depthseye:deye"},
		{"", "vessels:glass_bottle", ""}
	}
})


-- Add [toolranks] mod support if found
if minetest.get_modpath("toolranks") then

	-- Helper function
	local function add_tool(name, desc, afteruse)

		minetest.override_item(name, {
			original_description = desc,
			description = toolranks.create_description(desc, 0, 1),
			after_use = afteruse and toolranks.new_afteruse
		})
	end

	add_tool("ebitems:sword_obsidian", "Black Sword", true)
	add_tool("ebitems:flaming_sword", "Flaming Sword", true)
end


-- =================== Achievements  ============================================================

if minetest.get_modpath("awards") then

	awards.register_award("crazym", {
		title = "Crazy Mushroom",
		description = "Find the Mad Mushroom and defeat him to unlock the next achievement...",
		icon = "acm.png",
		background = "awards_bg_mining.png",
		prizes = {"ebitems:crazymushrrom_trophy"},
	})

	awards.register_award("heatedboss", {
		title = "Heated Boss",
		description = "Now you need to find the Obsidian Monster...",
		icon = "heated_a.png",
		background = "awards_bg_mining.png",
		requires = {"crazym"},
		prizes = {"ebitems:heated_trophy"},
	})

	awards.register_award("frostyqueenboss", {
		title = "Frosty Queen",
		description = "Beautiful and with a frozen heart, defeating the queen's warriors is your challenge...",
		icon = "queem.png",
		background = "awards_bg_mining.png",
		requires = {"heatedboss"},
		prizes = {"ebitems:frostyqueen_trophy"},
	})
end
