minetest.register_node("deco:stopsign", {
	description = "stop sign",
	drawtype = "mesh",
	mesh = "stopsign.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	--wield_image = "stop_sign.png",
	tiles = {"stop_sign.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:stopsign",
	sounds = default.node_sound_metal_defaults(),
	
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
	},
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:stopsign",
    recipe = {
        {"","wool:red",""},
        {"","default:steel_ingot",""},
        {"","default:steel_ingot",""}
      }
})



---- trashcan :
minetest.register_node("deco:trashcan", {
	description = "trashcan",
	drawtype = "mesh",
	mesh = "trashcan.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	--wield_image = "trashcan.png",
	tiles = {"trashcan.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:trashcan",
	sounds = default.node_sound_metal_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	},
	
	
})


minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:trashcan",
    recipe = {
        {"","",""},
        {"","default:steel_ingot",""},
        {"","bucket:bucket_empty",""}
    }
         
})

---- ZCOIN -------------------------------------
--[[
minetest.register_craftitem("deco:zcoin", {
	description = "Zcoin",
	inventory_image = "",

})
]]
---- VENDING MACHINE :
minetest.register_node("deco:vendingmachine", {
	description = "Vending machine",
	drawtype = "mesh",
	mesh = "vending_machine.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	--wield_image = "monitor.png",
	tiles = {"vending_machine.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	-- light_source = 8,
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:vendingmachine",
	sounds = default.node_sound_metal_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.4, 0.5},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.4, 0.5},
	},

	 on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        minetest.chat_send_player(player:get_player_name(), "This machine is empty!")
    end,
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:vendingmachine",
    recipe = {
        {"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
        {"default:steel_ingot","wool:red","default:steel_ingot"},
        {"default:steel_ingot","default:steel_ingot","default:steel_ingot"}
    }
         
})


---- RADIO :
--- Sound : https://freesound.org/people/arialfa07/sounds/516618/
minetest.register_node("deco:radio", {
	description = "Radio",
	drawtype = "mesh",
	mesh = "radio.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"radio.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:radio",
	sounds = default.node_sound_metal_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.2, 0.3},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.2, 0.3},
	},

	 on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        -- Play a sound to the player at the node position
        minetest.sound_play("radioo", {
            pos = pos,
            gain = 1.0,
            max_hear_distance = 10,
        })
    end,
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:radio",
    recipe = {
        {"","",""},
        {"","default:steel_ingot",""},
        {"","wool:black",""}
    }
         
})


---- TABLE :
minetest.register_node("deco:table", {
	description = "Table",
	drawtype = "mesh",
	mesh = "table.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"table.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:table",
	sounds = default.node_sound_wood_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	},
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:table",
    recipe = {
        {"group:wood","group:wood","group:wood"},
        {"default:stick","","default:stick"},
        {"default:stick","","default:stick"}
    }
         
})


---- COMPUTER :
minetest.register_node("deco:computer", {
	description = "Computer",
	drawtype = "mesh",
	mesh = "computer.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"computerr.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:computer",
	sounds = default.node_sound_metal_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.4, -0.5, -0.001, 0.4, 0.1, 0.15},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	},
	
	 on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local formspec = "size[8,8;]image[-0.9,-0.3;12,11;pc.png]"
        minetest.show_formspec(player:get_player_name(), "mymod:img_formspec", formspec) -- falta a imagem
    end
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:computer",
    recipe = {
        {"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
        {"default:steel_ingot","default:glass","default:steel_ingot"},
        {"","default:steel_ingot",""}
    }
         
})


---- ARMCHAIR :
minetest.register_node("deco:armchair", {
	description = "Armchair",
	drawtype = "mesh",
	mesh = "armchair.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"armchair.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:armchair",
	sounds = default.node_sound_wood_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.4, -0.5, -0.4, 0.4, -0.1, 0.4},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.4, -0.5, -0.4, 0.4, -0.1, 0.4},
	},

	--[[

	 can_dig = function(pos, player)
	        -- Verificando se há um jogador na posição
	        local objs = minetest.get_objects_inside_radius(pos, 0.5)
	        for _, obj in ipairs(objs) do
	            if obj:is_player() then
	                return false
	            end
	        end

	        -- Verificando se há um objeto próximo
	        local objects = minetest.get_objects_inside_radius(pos, 0.1)
	        for _, object in ipairs(objects) do
	            if object:is_player() then
	                return false
	            end
	        end

	        return true
	    end,

	]]

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player = clicker:get_player_name() 
        local player_pos = minetest.get_player_by_name(player):get_pos() 
        minetest.get_player_by_name(player):set_pos(pos) 

        -- Animação
        --minetest.get_player_by_name(player):set_animation({x = 81,  y = 160}, 30, 0)
        minetest.after(0.2, function()
        minetest.get_player_by_name(player):set_animation({x = 81,  y = 160}, 30, 0)
        end)
   		end,


	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:armchair",
    recipe = {
        {"","","wool:red"},
        {"wool:red","wool:red","wool:red"},
        {"wool:red","","wool:red"}
    }
 })




---- ARMCHAIR :
minetest.register_node("deco:hospital_gurney", {
	description = "Hospital Gurney",
	drawtype = "mesh",
	mesh = "maca_hospital.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"hospital_gurney.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:hospital_gurney",
	sounds = default.node_sound_wood_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.3, 1.0},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.3, 1.0},
	},



	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player = clicker:get_player_name() 
        local player_pos = minetest.get_player_by_name(player):get_pos() 
        minetest.get_player_by_name(player):set_pos({x=pos.x,y=pos.y+3,z=pos.z}) 

        -- Animação
        --minetest.get_player_by_name(player):set_animation({x = 162,  y = 166}, 30, 0)
        minetest.after(0.2, function()
        minetest.get_player_by_name(player):set_animation({x = 162,  y = 166}, 30, 0)
        end)
   		end,
		

	
})



---- SHELVING :
minetest.register_node("deco:shelving", {
	description = "Shelving",
	drawtype = "mesh",
	mesh = "shelving.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"shalving.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:shelving",
	sounds = default.node_sound_metal_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.2, 0.5},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.2, 0.5},
	},
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:shelving",
    recipe = {
        {"default:steel_ingot","","default:steel_ingot"},
        {"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
        {"default:steel_ingot","","default:steel_ingot"}
    }
})



---- MEDICINE BOX :   ( Não tem craft
minetest.register_node("deco:medicinebox", {
	description = "Medicine Box",
	drawtype = "mesh",
	mesh = "medicine_box.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"medicine_box.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {oddly_breakable_by_hand = 3},
	
	
	drop = {
		--max_items = 5,
		items = {
			{
				items = {'itemx:bandaid 1'},
				rarity = 1,
			},
			{
				items = {'itemx:medicalkit 1'},
				rarity = 7,
			},
			
			

		}
	},
	
	sounds = default.node_sound_leaves_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,fundo,fron,direita,top,tras
		fixed = {-0.2, -0.5, -0.3, 0.2, -0.4, 0.2},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.2, -0.5, -0.3, 0.2, -0.4, 0.2},
	},
	
	
})


---- TRAFFIC CONE:
minetest.register_node("deco:trafficcone", {
	description = "Traffic Cone",
	drawtype = "mesh",
	mesh = "traffic_cone.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"traffic_cone.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:trafficcone",
	
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
	},
	
	
})


minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:trafficcone 5",
    recipe = {
        {"","wool:orange",""},
        {"","wool:white",""},
        {"wool:orange","wool:orange","wool:orange"}
    }
 })


---- TRAFFIC POLE:
minetest.register_node("deco:trafficpole", {
	description = "Traffic Pole",
	drawtype = "mesh",
	mesh = "traffic_pole.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"traffic_pole.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:trafficpole",
	
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.3, 0.2},
	},
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:trafficpole 3",
    recipe = {
        {"","wool:orange",""},
        {"","wool:white",""},
        {"","wool:orange",""}
    }
 })



---- ROAD BLOCK:
minetest.register_node("deco:trafficblock", {
	description = "Traffic Block",
	drawtype = "mesh",
	mesh = "road_block.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"road_block.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	drop = "deco:roadblock",
	
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.5, -0.5, -0.3, 0.5, 0.3, 0.3},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.5, -0.5, -0.3, 0.5, 0.3, 0.3},
	},
	
	
})

minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "deco:trafficblock 8",
    recipe = {
        {"wool:red","wool:white","wool:red"},
        {"wool:red","wool:white","wool:red"},
        {"default:steel_ingot","","default:steel_ingot"}
    }
 })



---- Cardboard box:
minetest.register_node("deco:cardboardbox", {
	description = "Cardboard Box",
	drawtype = "nodebox",
	--mesh = "road_block.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {
	
	"cardboardbox_top.png", 
	"cardboardbox_side.png",
	"cardboardbox_side.png",
	"cardboardbox_side.png",
	"cardboardbox_front.png",
	"cardboardbox_front.png",
	
	
	},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {oddly_breakable_by_hand = 3},
	
	
	drop = {
		--max_items = 5,
		items = {
		
		-- Foods:
			
			
			{
				items = {'foodx:canned_beans'},
				rarity = 2,
			},
			
			{
				items = {'foodx:canned_tomato'},
				rarity = 1,
			},
		}
							

		
	},
	
	
	sounds = default.node_sound_leaves_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.1, 0.3},
	},
	
	
})


---- Cardboard box:
minetest.register_node("deco:gravestone", {
	description = "Gravestone",
	drawtype = "mesh",
	mesh = "gravestone.obj",
	tiles = {
	
	"gravestone_dirt.png", 
	
	
	},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {oddly_breakable_by_hand = 3},
	
	
	drop = {
		max_items = 1,
		items = {

		-- Bullets :
			{
				items = {'default:dirt'},
				rarity = 3,
			},
			
			{
				items = {'zarmor:hat_head 1'},
				rarity = 3,
			},

			{
				items = {'zarmor:tennis_feet 1'},
				rarity = 3,
			},
			
			{
				items = {'zarmor:rabbit_mask 1'},
				rarity = 4,
			},
			
			{
				items = {'zarmor:Jacketpink_torso 1'},
				rarity = 5,
			},

			{
				items = {'zarmor:Jacket_torso 1'},
				rarity = 5,
			},
			
			{
				items = {'zarmor:boots_policeboots 1'},
				rarity = 6,
			},

			{
				items = {'zarmor:jeanspants_legs 1'},
				rarity = 6,
			},
	}

		
	},
	
	
	sounds = default.node_sound_stone_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.2, -0.5, -0.1, 0.2, 0.4, 0.1},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.2, -0.5, -0.1, 0.2, 0.4, 0.1},
	},
	
	
})


--- GRAVESTONE DECO MAP :
minetest.register_decoration({
    deco_type = "simple",
    place_on = {
    "default:dirt_with_coniferous",
    "default:dirt_with_coniferous_litter",
    "default:dirt_with_grass",
    "default:dirt_with_snow"
    },
    sidelen = 80,
    place_offset_y = 0,
	biomes = {"underground"},
    flags = "force_placement,all_floors",
    fill_ratio = 0.0002,
	y_max = 50,
    y_min = 0,
    decoration ="deco:gravestone",
})




--[[
minetest.register_craft({   ------ CRaFT
    type = "shaped",
    output = "fortification:barbedwire2",
    recipe = {
        {"default:steel_ingot","","default:steel_ingot"},
        {"","default:steel_ingot",""},
        {"default:steel_ingot","","default:steel_ingot"}
    }
})
]]



---- BEDS :
minetest.register_node("deco:dirtybeds", {
	description = "Dirty beds",
	drawtype = "mesh",
	mesh = "bedx.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"bedx.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	--drop = " ",
	sounds = default.node_sound_wood_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.01, 1.5},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.01, 1.5},
	},

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
       
    	 minetest.chat_send_player(player:get_player_name(), "That bed is contaminated, you can't sleep in it!")
       
    end,
    
	
})



---- VASES :
minetest.register_node("deco:vases", {
	description = "Vases",
	drawtype = "mesh",
	mesh = "vases.obj",
	--visual_size = {x=1, y=1},
	--inventory_image = "",
	tiles = {"vases.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = minetest.rotate_node,
	sunlight_propagates = true,
	walkable = true, 
	floodable = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	--drop = " ",
	sounds = default.node_sound_wood_defaults(),
	
	selection_box = {
		type = "fixed",
		--    esqueda,altura,tras..,direita ,negativo aumenta para baixo, positivo aumenta para cima
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},
	
	node_box = {
		type = "fixed", 
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},

  
	
})