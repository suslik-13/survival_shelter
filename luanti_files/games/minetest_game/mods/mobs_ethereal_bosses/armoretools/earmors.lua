-- nada

	if minetest.get_modpath("3d_armor") then

	armor:register_armor("eamoretools:helmet_roots", {
			description = "Roots Helmet",
			inventory_image = "roots_inv_helmet_roots.png",
			groups = {armor_head=1, armor_heal=6, armor_use=300,
				physics_speed=-0.02, physics_gravity=-0.1},
			armor_groups = {fleshy=10},
			damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
		})


		armor:register_armor("eamoretools:chestplate_roots", {
		description = "Roots Chestplate",
		inventory_image = "roots_inv_chestplate_roots.png",
		groups = {armor_torso=1, armor_heal=6, armor_use=300,
			physics_speed=-0.05, physics_gravity=-0.2},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	})

	end


	-- CRAFT :

	minetest.register_craft({
    type = "shaped",
    output = "eamoretools:helmet_roots",
    recipe = {
         {"natureguardian:natureroots","natureguardian:natureroots","natureguardian:natureroots"},
        {"natureguardian:natureroots","","natureguardian:natureroots"},
        {"", "",""}
    }
	})

	

	minetest.register_craft({
	    type = "shaped",
	    output = "eamoretools:chestplate_roots",
	    recipe = {
	         {"natureguardian:natureroots","","natureguardian:natureroots"},
	        {"natureguardian:natureroots","natureguardian:natureroots","natureguardian:natureroots"},
	        {"natureguardian:natureroots", "natureguardian:natureroots","natureguardian:natureroots"}
	    }
	})







