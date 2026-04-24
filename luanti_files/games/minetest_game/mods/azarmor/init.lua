
-- SOBREVIVENTE:
armor:register_armor("zarmor:hat_head", {
    description = "Hat",
    inventory_image = "inv_hat.png",
    groups = {armor_head=1, armor_heal=6, armor_use=300,
        physics_speed=-0.02, physics_gravity=0.02},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})

armor:register_armor("zarmor:Jacket_torso", {
    description = "Jacket",
    inventory_image = "inv_Jacket.png",
    groups = {armor_torso=1, armor_heal=6, armor_use=300,
        physics_speed=-0.05, physics_gravity=0.05},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})


armor:register_armor("zarmor:jeanspants_legs", {
    description = "jeans pants",
    inventory_image = "inv_jeanspants.png",
    groups = {armor_legs=1, armor_heal=6, armor_use=300,
        physics_speed=-0.04, physics_gravity=0.04},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})


armor:register_armor("zarmor:tennis_feet", {
    description = "Tennis",
    inventory_image = "inv_tennis.png",
    groups = {armor_feet=1, armor_heal=6, armor_use=300,
        physics_speed=-0.02, physics_gravity=0.02},
    armor_groups = {fleshy=10},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})


------ TODOS OS ITENS ABAIXO SÃO SAQUES : ===================================================================

-- MASCARA DE GÁS :
armor:register_armor("zarmor:gas_mask", {
        description = "Gas Mask",
        inventory_image = "gas_mask_inv.png",
        groups = {armor_head=1, armor_heal=0, armor_use=800,
            physics_speed=-0.01, physics_gravity=0.01},
        armor_groups = {fleshy=10},
        damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    })

-- rabbit mask :
armor:register_armor("zarmor:rabbit_mask", {
        description = "Rabbit Mask",
        inventory_image = "rabbit_mask_inv.png",
        groups = {armor_head=1, armor_heal=0, armor_use=800,
            physics_speed=-0.01, physics_gravity=0.01},
        armor_groups = {fleshy=10},
        damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    })


-- BULLERTPROOF VEST + BOOTS + JOELHEIRA :
armor:register_armor("zarmor:chestplate_bulletproofvest", {
        description = "Bulletproof Vest",
        inventory_image = "bulletproofvest_inv.png",
        groups = {armor_torso=1, armor_heal=0, armor_use=800,
            physics_speed=-0.04, physics_gravity=0.04},
        armor_groups = {fleshy=15},
        damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    })


armor:register_armor("zarmor:dressshirt_torso", {
    description = "Dress Shirt",
    inventory_image = "inv_dressshirt.png",
    groups = {armor_torso=1, armor_heal=6, armor_use=300,
        physics_speed=-0.05, physics_gravity=0.05},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})


armor:register_armor("zarmor:Jacketpink_torso", {
    description = "Jacket Pink",
    inventory_image = "inv_Jacketpink.png",
    groups = {armor_torso=1, armor_heal=6, armor_use=300,
        physics_speed=-0.05, physics_gravity=0.05},
    armor_groups = {fleshy=15},
    damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
})


armor:register_armor("zarmor:boots_policeboots", {
        description = "Police Boots",
        inventory_image = "policeboots_inv.png",
        groups = {armor_feet=1, armor_heal=0, armor_use=800,
            physics_speed=0.2, physics_gravity=0.01},
        armor_groups = {fleshy=10},
        damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    })


armor:register_armor("zarmor:leggings_kneepad", {
        description = "Knee Pad",
        inventory_image = "inv_kneepad.png",
        groups = {armor_legs=1, armor_heal=0, armor_use=800,
            physics_speed=-0.03, physics_gravity=0.03},
        armor_groups = {fleshy=15},
        damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
    })


------ ITEMS NÃO SÃO SAQUES, SÃO CRAFTAVEIS : ===============================================================

-- TAMPA DE LATA DE LIXO :

armor:register_armor("zarmor:trashcanlid_shield", {
        description = "Trash Can Lid",
        inventory_image = "trashcalid_inv.png",
        groups = {armor_shield=1, armor_heal=0, armor_use=2000},
        armor_groups = {fleshy=8},
        damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=2},
        reciprocate_damage = true,

        --[[
        on_damage = function(player, index, stack)
            
        end,
        on_destroy = function(player, index, stack)
            
        end,
        ]]
    })

    --- Craft com tin :

    minetest.register_craft({
    type = "shaped",
    output = "zarmor:trashcanlid_shield 1",
    recipe = {
        {"","default:tin_ingot",""},
        {"default:tin_ingot","","default:tin_ingot"},
        {"","default:tin_ingot",""}
    }
})



-- MILITARY : Equivalente a gold

armor:register_armor("zarmor:helmet_military", {
        description = "Military Helmet",
        inventory_image = "zarmor_helmet_military_inv.png",
        groups = {armor_head=1, armor_heal=6, armor_use=300,
            physics_speed=-0.02, physics_gravity=0.02},
        armor_groups = {fleshy=10},
        damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
    })

armor:register_armor("zarmor:chestplate_military", {
        description = "Military Chestplate",
        inventory_image = "zarmor_chestplate_military_inv.png",
        groups = {armor_torso=1, armor_heal=6, armor_use=300,
            physics_speed=-0.05, physics_gravity=0.05},
        armor_groups = {fleshy=15},
        damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
    })

armor:register_armor("zarmor:leggings_military", {
        description = "Military Leggings",
        inventory_image = "zarmor_leggings_military_inv.png",
        groups = {armor_legs=1, armor_heal=6, armor_use=300,
            physics_speed=-0.04, physics_gravity=0.04},
        armor_groups = {fleshy=15},
        damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
    })


armor:register_armor("zarmor:boots_military", {
        description = "Military Boots",
        inventory_image = "zarmor_boots_military_inv.png",
        groups = {armor_feet=1, armor_heal=6, armor_use=300,
            physics_speed=0.3, physics_gravity=0.02},
        armor_groups = {fleshy=10},
        damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
    })


---------------- craft :

   minetest.register_craft({
    type = "shaped",
    output = "zarmor:helmet_military 1",
    recipe = {
        {"default:gold_ingot","dye:dark_green","default:gold_ingot"},
        {"default:gold_ingot","","default:gold_ingot"},
        {"","",""}
    }
})


   minetest.register_craft({
    type = "shaped",
    output = "zarmor:chestplate_military 1",
    recipe = {
        {"default:gold_ingot","","default:gold_ingot"},
        {"default:gold_ingot","dye:dark_green","default:gold_ingot"},
        {"default:gold_ingot","default:gold_ingot","default:gold_ingot"}
    }
})


   minetest.register_craft({
    type = "shaped",
    output = "zarmor:leggings_military 1",
    recipe = {
        {"default:gold_ingot","dye:dark_green","default:gold_ingot"},
        {"default:gold_ingot","","default:gold_ingot"},
        {"default:gold_ingot","","default:gold_ingot"}
    }
})


 minetest.register_craft({
    type = "shaped",
    output = "zarmor:boots_military 1",
    recipe = {
        {"default:gold_ingot","","default:gold_ingot"},
        {"dye:brown","","dye:brown"},
        {"","",""}
    }
})


-- JUGGERNAUT : Equivalente a diamante

armor:register_armor("zarmor:helmet_Juggernaut", {
        description = "Juggernaut Helmet",
        inventory_image = "inv_helmet_Juggernaut.png",
        groups = {armor_head=1, armor_heal=6, armor_use=66},
        armor_groups = {fleshy=13},
        damage_groups = {cracky=2, snappy=1, level=3},
    })


    armor:register_armor("zarmor:chestplate_Juggernaut", {
        description = "Juggernaut Chestplate",
        inventory_image = "inv_chestplate_Juggernaut.png",
        groups = {armor_torso=1, armor_heal=6, armor_use=66},
        armor_groups = {fleshy=18},
        damage_groups = {cracky=2, snappy=1, level=3},
    })


    armor:register_armor("zarmor:leggings_Juggernaut", {
        description = "Juggernaut Leggings",
        inventory_image = "inv_leggings_Juggernaut.png",
        groups = {armor_legs=1, armor_heal=6, armor_use=66},
        armor_groups = {fleshy=18},
        damage_groups = {cracky=2, snappy=1, level=3},
    })


    armor:register_armor("zarmor:boots_Juggernaut", {
        description = "Juggernaut Boots",
        inventory_image = "inv_boots_Juggernaut.png",
        groups = {armor_feet=1, armor_heal=6, armor_use=66},
        armor_groups = {fleshy=13},
        damage_groups = {cracky=2, snappy=1, level=3},
    })



    armor:register_armor("zarmor:shield_Juggernaut", {
        description = "Juggernaut Shield",
        inventory_image = "inv_shield_Juggernaut.png",
        groups = {armor_shield=1, armor_heal=6, armor_use=66},
        armor_groups = {fleshy=13},
        damage_groups = {cracky=2, snappy=1, level=3},
        reciprocate_damage = true,
       
    })



    ---------------- craft :

   minetest.register_craft({
    type = "shaped",
    output = "zarmor:helmet_Juggernaut 1",
    recipe = {
        {"default:diamond","dye:black","default:diamond"},
        {"default:diamond","","default:diamond"},
        {"","",""}
    }
})


   minetest.register_craft({
    type = "shaped",
    output = "zarmor:chestplate_Juggernaut 1",
    recipe = {
        {"default:diamond","","default:diamond"},
        {"default:diamond","dye:black","default:diamond"},
        {"default:diamond","default:diamond","default:diamond"}
    }
})


   minetest.register_craft({
    type = "shaped",
    output = "zarmor:leggings_Juggernaut 1",
    recipe = {
        {"default:diamond","dye:black","default:diamond"},
        {"default:diamond","","default:diamond"},
        {"default:diamond","","default:diamond"}
    }
})


 minetest.register_craft({
    type = "shaped",
    output = "zarmor:boots_Juggernaut 1",
    recipe = {
        {"default:diamond","","default:diamond"},
        {"dye:black","","dye:black"},
        {"","",""}
    }
})



  minetest.register_craft({
    type = "shaped",
    output = "zarmor:shield_Juggernaut 1",
    recipe = {
        {"default:diamond","default:diamond","default:diamond"},
        {"default:diamond","default:diamond","default:diamond"},
        {"","dye:black",""}
    }
})
