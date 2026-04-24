-- Инициализация сундука сокровищ
minetest.register_node("treasure_chest:treasure_chest", {
    description = "Treasure Chest",
    tiles = {
        "treasurechest_u.png",
        "treasurechest_d.png",
        "treasurechest_r.png",
        "treasurechest_l.png",
        "treasurechest_b.png",
        "treasurechest_f.png"
    },
    paramtype2 = "facedir",
    groups = {cracky=2},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec",
            "size[8,9]"..
            "list[current_name;main;0,0.5;8,4;]"..
            "list[current_player;main;0,4.85;8,1;]"..
            "list[current_player;main;0,6.08;8,3;8]"..
            "listring[]"..
            "bgcolor[#080808BB;true]"..
            "background[5,5;1,1;gui_formbg.png;true]"..
            "background[4,4;1,1;gui_formbg.png;true]"..
            "background[3,3;1,1;gui_formbg.png;true]"..
            "background[2,2;1,1;gui_formbg.png;true]"..
            "background[1,1;1,1;gui_formbg.png;true]"..
            "background[0,0;8,4;gui_formbg.png;true]")
        meta:set_string("infotext", "Treasure Chest")
        local inv = meta:get_inventory()
        inv:set_size("main", 8*4)
    end,
})

-- Функция, которая генерирует набор предметов для сундука
local function generate_treasure()
    local treasure = {}
    -- Каждый предмет имеет вероятность появления и диапазон количества штук
    -- Пример: {item = "default:diamond", chance = 0.5, min = 1, max = 3}
    -- Это означает, что в сундуке может появиться от 1 до 3 алмазов с вероятностью 50%
    table.insert(treasure, {item = "default:diamond", chance = 0.5, min = 1, max = 3})
    table.insert(treasure, {item = "default:gold_ingot", chance = 0.2, min = 1, max = 5})
    table.insert(treasure, {item = "default:steel_ingot", chance = 0.8, min = 3, max = 7})
    table.insert(treasure, {item = "default:pick_diamond", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "default:sword_diamond", chance = 0.8, min = 1, max = 1})
    table.insert(treasure, {item = "default:axe_diamond", chance = 0.8, min = 1, max = 1})
    table.insert(treasure, {item = "default:shovel_diamond", chance = 0.8, min = 1, max = 1})
    
    table.insert(treasure, {item = "default:mese_crystal", chance = 0.5, min = 1, max = 5})
    table.insert(treasure, {item = "x_obsidianmese:sword", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "x_obsidianmese:sword_engraved", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "x_obsidianmese:pick", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "default:mese", chance = 0.5, min = 1, max = 5})
    table.insert(treasure, {item = "default:diamondblock", chance = 0.5, min = 1, max = 5})
    table.insert(treasure, {item = "x_obsidianmese:pick_engraved", chance = 0.2, min = 1, max = 1})
    
    table.insert(treasure, {item = "3d_armor:boots_diamond", chance = 0.5, min = 1, max = 1})
    table.insert(treasure, {item = "3d_armor:chestplate_diamond", chance = 0.5, min = 1, max = 1})
    table.insert(treasure, {item = "3d_armor:leggings_diamond", chance = 0.8, min = 1, max = 1})
    table.insert(treasure, {item = "3d_armor:helmet_diamond", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "shields:shield_diamond", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "x_obsidianmese:mese_apple", chance = 0.5, min = 1, max = 5})
    table.insert(treasure, {item = "moreores:mithril_lump", chance = 0.8, min = 1, max = 5})
    
    table.insert(treasure, {item = "3d_armor:boots_nether", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "3d_armor:chestplate_nether", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "3d_armor:leggings_nether", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "3d_armor:helmet_nether", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "shields:shield_nether", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "default:brick", chance = 0.8, min = 1, max = 99})
    table.insert(treasure, {item = "x_farming:cactus_brick", chance = 0.8, min = 1, max = 99})
    
    table.insert(treasure, {item = "default:dirt_with_grass", chance = 0.6, min = 1, max = 99})
    table.insert(treasure, {item = "mobs:honey_block", chance = 0.6, min = 1, max = 99})
    table.insert(treasure, {item = "bakedclay:white", chance = 0.6, min = 1, max = 99})
    table.insert(treasure, {item = "caverealms:glow_amethyst", chance = 0.2, min = 1, max = 99})
    table.insert(treasure, {item = "default:chest_locked", chance = 0.8, min = 1, max = 5})
    table.insert(treasure, {item = "default:desert_cobble", chance = 0.5, min = 1, max = 99})
    table.insert(treasure, {item = "ethereal:crystal_dirt", chance = 0.2, min = 1, max = 3})
    
    table.insert(treasure, {item = "ethereal:golden_apple", chance = 0.5, min = 1, max = 3})
    table.insert(treasure, {item = "fireflies:firefly_bottle", chance = 0.3, min = 1, max = 1})
    table.insert(treasure, {item = "mobs:egg", chance = 0.3, min = 1, max = 99})
    table.insert(treasure, {item = "x_farming:coffee_cup_hot", chance = 0.2, min = 1, max = 1})
    table.insert(treasure, {item = "x_farming:corn_popcorn", chance = 0.5, min = 1, max = 10})
    table.insert(treasure, {item = "x_farming:fries", chance = 0.5, min = 1, max = 5})
    table.insert(treasure, {item = "x_farming:kiwi_wood", chance = 0.2, min = 1, max = 99})
    
    table.insert(treasure, {item = "xdecor:baricade", chance = 0.1, min = 1, max = 99})
    table.insert(treasure, {item = "xdecor:coalstone_tile", chance = 0.1, min = 1, max = 99})
    table.insert(treasure, {item = "caverealms:glow_obsidian", chance = 0.1, min = 1, max = 99})
    table.insert(treasure, {item = "caverealms:hot_cobble", chance = 0.2, min = 1, max = 99})
    table.insert(treasure, {item = "default:obsidian", chance = 0.1, min = 1, max = 99})
    table.insert(treasure, {item = "currency:safe", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "ethereal:bamboo_block", chance = 0.6, min = 1, max = 99})
    
    table.insert(treasure, {item = "cannon73:ball", chance = 0.5, min = 1, max = 5})
    table.insert(treasure, {item = "mobs_birds:gull", chance = 0.1, min = 1, max = 1})
    table.insert(treasure, {item = "default:apple", chance = 0.6, min = 1, max = 99})



-- Сгенерировать набор предметов
local generated_treasure = {}
for _, item in ipairs(treasure) do
    if math.random() < item.chance then
        local count = math.random(item.min, item.max)
        table.insert(generated_treasure, {item = item.item, count = count})
    end
end
return generated_treasure

end

-- Функция, которая очищает сундук от предыдущих предметов
local function clear_treasure_chest(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_list("main", {})
end

-- Функция, которая заполняет сундук сокровищ новым набором предметов
local function fill_treasure_chest(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local treasure = generate_treasure()
	for _, item in ipairs(treasure) do
		inv:add_item("main", ItemStack(item.item.." "..item.count))
	end
end

local function get_time_difference(last_time)
    local current_time = os.time()
    local time_diff = os.difftime(current_time, last_time)
    return time_diff
end


hour = 3600
half_hour = 1800
twenty_minutes = 1200
five_minutes = 300


--local chest_pos = {x=5849.0, y=23.0, z=2793}

local function refill_chest()
    local chests = minetest.find_nodes_in_area({x=5810.0, y=13, z=2772}, {x=5888.0, y=27, z=2813.0}, "treasure_chest:treasure_chest")
        for _, pos in ipairs(chests) do
            clear_treasure_chest(pos)
            fill_treasure_chest(pos)
            minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest is full! **"))
        end
    minetest.after(60, function()
    minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 75 hours **"))
    minetest.after(97200, function()
	    minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 48 hours **"))
	    minetest.after(86400, function()
		    minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 24 hour **"))
		    minetest.after(82800, function()
		    	minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 1 hour **"))
		    		minetest.after(twenty_minutes, function()
		    			minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 10 minutes **"))
		    			minetest.after(five_minutes, function()
		    				minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 5 minutes **"))
			    				minetest.after(240, function()
			    				
			    				minetest.chat_send_all(minetest.colorize("yellow", "** PVP Arena: The treasure chest will be filled in 1 minute **"))
			    				minetest.after(60, function()
								refill_chest()
								end)
						end)	
					end)	
				end)
		    end)
	    end)
    end)	
    end)    
end

minetest.register_on_mods_loaded(function()
    minetest.after(60, refill_chest)
end)

