
--=============================== MUSHROOM TOOLS : =============================================================================

minetest.register_tool("eamoretools:pick_mushroom", {
	description = "Mushroom Pickaxe",
	inventory_image = "mushroom_pick.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=2.0, [3]=1.00}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})



minetest.register_tool("eamoretools:shovel_mushroom", {
	description = "Mushroom Shovel",
	inventory_image = "mushroom_shovel.png",
	wield_image = "mushroom_shovel.png",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})


minetest.register_tool("eamoretools:axe_mushroom", {
	description = "Mushroom Axe",
	inventory_image = "mushroom_axe.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			choppy={times={[1]=3.00, [2]=2.00, [3]=1.30}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})



minetest.register_tool("eamoretools:sword_mushroom", {
	description = "Mushroom Sword",
	inventory_image = "mushroom_sword.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})


-- CRAFT :

minetest.register_craft({
    type = "shaped",
    output = "eamoretools:pick_mushroom",
    recipe = {
         {"flowers:mushroom_red","flowers:mushroom_red","flowers:mushroom_red"},
        {"","default:stick",""},
        {"", "default:stick",""}
    }
})


minetest.register_craft({
    type = "shaped",
    output = "eamoretools:shovel_mushroom",
    recipe = {
         {"","flowers:mushroom_red",""},
        {"","default:stick",""},
        {"", "default:stick",""}
    }
})


minetest.register_craft({
    type = "shaped",
    output = "eamoretools:axe_mushroom",
    recipe = {
        {"flowers:mushroom_red","flowers:mushroom_red",""},
        {"flowers:mushroom_red","default:stick",""},
        {"", "default:stick",""}
    }
})

minetest.register_craft({
    type = "shaped",
    output = "eamoretools:sword_mushroom",
    recipe = {
        {"","flowers:mushroom_red",""},
        {"","flowers:mushroom_red",""},
        {"", "default:stick",""}
    }
})


--========================= NATURE TOOLS : ===========================================================================
-- Sound whip : https://freesound.org/people/CGEffex/sounds/93100/

minetest.register_tool("eamoretools:naturewhip", {
	description = "Nature Whip",
	inventory_image = "Nature_Whip.png",
	range = 15,
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=3,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=30, maxlevel=1},
		},
		damage_groups = {fleshy=4, knockback=2},
	},
	sound = {
	breaks = "default_tool_breaks",
	punch_use = "whip",

	},
})



minetest.register_tool("eamoretools:naturerod", {
	description = "Nature Rod",
	wield_scale = {x = 1.5, y = 3.1, z = 1.5},
	inventory_image = "Nature_Rod.png",
	range = 15,
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=3,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4, knockback=2},
	},
	sound = {
	breaks = "default_tool_breaks"
	},
})


-- CRAFT :

minetest.register_craft({
    type = "shaped",
    output = "eamoretools:naturewhip",
    recipe = {
        {"","natureguardian:natureroots",""},
        {"natureguardian:natureroots","default:stick",""},
        {"", "default:stick",""}
    }
})


minetest.register_craft({
    type = "shaped",
    output = "eamoretools:naturerod",
    recipe = {
        {"","default:flint",""},
        {"","natureguardian:natureroots",""},
        {"", "default:stick",""}
    }
})