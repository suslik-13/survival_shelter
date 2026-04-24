local S

if minetest.get_translator ~= nil then
    S = minetest.get_translator(minetest.get_current_modname())
else
    S = function(str)
        return(str)
    end
end

--
-- Armor
--

if minetest.get_modpath("3d_armor") then
    armor:register_armor("legendary_armor:helmet_legendary", {
        description = S("Crown"),
        inventory_image = "legendary_armor_helmet_inv.png",
        light_source = 7, -- Texture will have a glow when dropped
        groups = {armor_head=1, armor_heal=20, armor_use=0, armor_fire=5, physics_jump=1.5, physics_speed = 1.75, armor_water=1, armor_feather=1,
			not_in_creative_inventory=1},
        armor_groups = {fleshy=20, radiation=100},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("legendary_armor:chestplate_legendary", {
        description = S("Legendary Mese Chestplate"),
        inventory_image = "legendary_armor_chestplate_inv.png",
        light_source = 7, -- Texture will have a glow when dropped
        groups = {armor_torso=1, armor_heal=20, armor_use=0, armor_fire=5, armor_water=1,
			not_in_creative_inventory=1},
        armor_groups = {fleshy=20, radiation=100},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("legendary_armor:leggings_legendary", {
        description = S("Legendary Mese Leggings"),
        inventory_image = "legendary_armor_leggings_inv.png",
        light_source = 7, -- Texture will have a glow when dropped
        groups = {armor_legs=1, armor_heal=15, armor_use=0, armor_fire=5,
			not_in_creative_inventory=1},
        armor_groups = {fleshy=20, radiation=100},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("legendary_armor:boots_legendary", {
        description = S("Legendary Mese Boots"),
        inventory_image = "legendary_armor_boots_inv.png",
        light_source = 7, -- Texture will have a glow when dropped
        groups = {armor_feet=1, armor_heal=8, armor_use=0, armor_fire=5, physics_jump=1, physics_speed = 1,
			not_in_creative_inventory=1},
        armor_groups = {fleshy=15, radiation=100},
		damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("legendary_armor:shield_legendary", {
        description = S("Legendary Mese Shield"),
        inventory_image = "legendary_armor_shield_inv.png",
        light_source = 7, -- Texture will have a glow when dropped
        groups = {armor_shield=1, armor_heal=20, armor_use=0, armor_fire=10,
			not_in_creative_inventory=1},
        armor_groups = {fleshy=20, radiation=100},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })
end


--
-- Armor Crafts
--
--[[
if minetest.get_modpath("3d_armor") then
    minetest.register_craft({
        output = "legendary_armor:helmet_legendary",
        recipe = {
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "", "legendary_armor:ingot"},
            {"", "", ""},
        }
    })

    minetest.register_craft({
        output = "legendary_armor:chestplate_legendary",
        recipe = {
            {"legendary_armor:ingot", "", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
        }
    })

    minetest.register_craft({
        output = "legendary_armor:leggings_legendary",
        recipe = {
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "", "legendary_armor:ingot"},
        }
    })

    minetest.register_craft({
        output = "legendary_armor:boots_legendary",
        recipe = {
            {"legendary_armor:ingot", "", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "", "legendary_armor:ingot"},
        }
    })

    minetest.register_craft({
        output = "legendary_armor:shield_legendary",
        recipe = {
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
            {"", "legendary_armor:ingot", ""},
        }
    })
end
--]]
--
-- Tools
--
if minetest.get_modpath("default") then
    minetest.register_tool("legendary_armor:pickaxe", {
        description = S("Legendary Mese Pickaxe"),
        inventory_image = "legendary_armor_pick.png",
        tool_capabilities = {
            full_punch_interval = 0.5,
            max_drop_level=1,
            groupcaps={
                cracky = {times={[3]=0.25, [2]=0.65, [1]=1}, uses=10000, maxlevel=80},
            },
            damage_groups = {fleshy=2},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {pickaxe = 5, }
    })
    
    minetest.register_tool("legendary_armor:shovel", {
        description = S("Legendary Mese Shovel"),
        inventory_image = "legendary_armor_shovel.png",
        tool_capabilities = {
            full_punch_interval = 0.5,
            max_drop_level=1,
            groupcaps={
                crumbly = {times={[1]=0.5, [2]=0.25, [3]=0}, uses=10000, maxlevel=80},
            },
            damage_groups = {fleshy=2},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {shovel = 5}
    })
    
    minetest.register_tool("legendary_armor:axe", {
        description = S("Legendary Mese Axe"),
        inventory_image = "legendary_armor_axe.png",
        tool_capabilities = {
            full_punch_interval = 0.5,
            max_drop_level=1,
            groupcaps={
                choppy = {times={[1]=0.5, [2]=0.25, [3]=0}, uses=10000, maxlevel=80},
            },
            damage_groups = {fleshy=2},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {axe = 5}
    })
    
    minetest.register_tool("legendary_armor:sword", {
        description = S("Legendary Mese Sword"),
        inventory_image = "legendary_armor_sword.png",
        tool_capabilities = {
            full_punch_interval = .5,
            max_drop_level=1,
            groupcaps={
                snappy={times={[1]=0.0125, [2]=0.0, [3]=0}, uses=10000, maxlevel=80},
            },
            damage_groups = {fleshy=15, burn=2},
        },
        sound = {breaks = "default_tool_breaks"},
        groups = {sword = 5}
    })
    
end

--
-- Tool Crafts
--
--[[
if minetest.get_modpath("default") then
    minetest.register_craft({
        output = "legendary_armor:pickaxe",
        recipe = {
            {"legendary_armor:ingot", "legendary_armor:ingot", "legendary_armor:ingot"},
            {"", "default:stick", ""},
            {"", "default:stick", ""},
        }
    })
    
    minetest.register_craft({
        output = "legendary_armor:axe",
        recipe = {
            {"legendary_armor:ingot", "legendary_armor:ingot", ""},
            {"legendary_armor:ingot", "default:stick", ""},
            {"", "default:stick", ""},
        }
    })
    
    minetest.register_craft({
        output = "legendary_armor:shovel",
        recipe = {
            {"", "legendary_armor:ingot", ""},
            {"", "default:stick", ""},
            {"", "default:stick", ""},
        }
    })
    
    minetest.register_craft({
        output = "legendary_armor:sword",
        recipe = {
            {"", "legendary_armor:ingot", ""},
            {"", "legendary_armor:ingot", ""},
            {"", "default:stick", ""},
        }
    })
    
end
--]]
--
-- Ingots
--
--[[
if minetest.get_modpath("default") then
    minetest.register_craftitem("legendary_armor:ingot", {
        description = "Legendary Mese Ingot",
        inventory_image = "legendary_armor_ingot.png",
    })

end


--
-- Ingots Crafts
--
if minetest.get_modpath("more_mese") then
    minetest.register_craft({
        type = "shapeless",
        output = "legendary_armor:ingot 8",
        recipe = {"more_mese:legendary_block", "more_mese:legendary_block"}
    })
end

if minetest.get_modpath("legendary_ore") then
    minetest.register_craft({
        type = "shapeless",
        output = "legendary_armor:ingot 8",
        recipe = {"legendary_ore:legendary_block", "legendary_ore:legendary_block"}
    })
end
--]]

--Config Scripts:

local speeed = 1.75
local graavity = 1
local juump = 1
 
armorconf = {}

function armorconf.get_formspec(name)

  local text = "Configure Your Armor Specs:"

  local formspec = {
    "formspec_version[4]",
    "size[5,6]",
    "label[0.3,0.5;", minetest.formspec_escape(text), "]",
    "field[0.3,1.25;4,0.8;sped;Speed:;" .. minetest.formspec_escape(string.format("%s", speeed)) .. "]",
    "field[0.3,2.5;4,0.8;grav;Gravity:;" .. minetest.formspec_escape(string.format("%s", graavity)) .. "]",
    "field[0.3,3.85;4,0.8;jum;Jump:;" .. minetest.formspec_escape(string.format("%s", juump)) .. "]",
    "button[.7,5;3,0.8;save;Save]"
  }

  return table.concat(formspec, "")
end


function armorconf.show_to(name)
  minetest.show_formspec(name, "armorconf:game", armorconf.get_formspec(name))
end

function stopCheating()
    if tonumber(juump) > 1 or tonumber(graavity) > 1 or tonumber(speeed) > 1 then
    end
end

function changePlayerStats(name)
    local player = minetest.get_player_by_name(name)

    if pcall(stopCheating) then
            
        --capping values
        if tonumber(graavity) > 3 then
            graavity = 3
        end
        if tonumber(speeed) > 3 then
            speeed = 3
        end
        if tonumber(juump) > 3 then
            juump = 3
        end
        if tonumber(graavity) < .1 then
            graavity = .1
        end
        if tonumber(speeed) < .1 then
            speeed = .1
        end
        if tonumber(juump) < .1 then
            juump = .1
        end
        minetest.chat_send_player(name, "Changes Saved!")
    else
        minetest.chat_send_all("Please only input numbers!")
    end    

    player:set_physics_override({
        gravity = graavity,
        speed = speeed,
        jump = juump
    })
end

minetest.register_on_player_receive_fields(function(player, formname, fields)

    if formname ~= "armorconf:game" then
        return
    end

    if fields.save then
        local pname = player:get_player_name()
        speeed = fields.sped
        graavity = fields.grav
        juump = fields.jum
        changePlayerStats(pname)
    end
end)

minetest.register_chatcommand("armorconfig", {

    func = function(name)

        local player = minetest.get_player_by_name(name)
        test=armor:get_weared_armor_elements(player)
    
        local keyset={}
        local n=0
    
        for k,v in pairs(test) do
            n=n+1
            keyset[n]=k
        end

        if test["feet"] == "legendary_armor:boots_legendary" and test["legs"] == "legendary_armor:leggings_legendary" and test["torso"] == "legendary_armor:chestplate_legendary" and test["head"] == "legendary_armor:helmet_legendary" then
            armorconf.show_to(name)
        
        else 
            minetest.chat_send_player(name, "You do not have a full set of legendary mese armor!")
        end
    end,
})

--armor elements:
--boots=feet
--chestplate=torso
--helmet=head
--leggings=legs

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

	add_tool("legendary_armor:pickaxe", "Legendary Pickaxe", true)
	add_tool("legendary_armor:axe", "Legendary Axe", true)
	add_tool("legendary_armor:shovel", "Legendary Shovel", true)
	add_tool("legendary_armor:sword", "Legendary Sword", true)
end

