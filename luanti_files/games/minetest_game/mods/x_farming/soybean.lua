--[[
    X Farming. Extends Luanti farming mod with new plants, crops and ice fishing.
    Copyright (C) 2025 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to juraj.vajda@gmail.com
--]]

local S = core.get_translator(core.get_current_modname())

-- SOYBEAN
x_farming.register_plant('x_farming:soybean', {
    description = S('Soybean Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Soybean Seed'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_soybean_seed.png',
    steps = 7,
    minlight = 13,
    maxlight = 14,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 3,
})

-- needed
core.override_item('x_farming:soybean', {
    description = S('Soybean') .. '\n' .. S('Compost chance') .. ': 65%',
    short_description = S('Soybean'),
    groups = {
        -- X Farming
        compost = 65,
        -- MCL
        compostability = 65
    },
})

core.register_craftitem('x_farming:bottle_soymilk', {
    description = S('Soymilk Bottle'),
    short_description = S('Soymilk Bottle'),
    tiles = { 'x_farming_bottle_soymilk.png' },
    inventory_image = 'x_farming_bottle_soymilk.png',
    wield_image = 'x_farming_bottle_soymilk.png',
    groups = { vessel = 1 },
    sounds = x_farming.node_sound_thin_glass_defaults(),
})

core.register_craftitem('x_farming:bottle_soymilk_raw', {
    description = S('Raw Soymilk Bottle'),
    short_description = S('Raw Soymilk Bottle'),
    tiles = { 'x_farming_bottle_soymilk_raw.png' },
    inventory_image = 'x_farming_bottle_soymilk_raw.png',
    wield_image = 'x_farming_bottle_soymilk_raw.png',
    groups = { vessel = 1, dig_immediate = 3, attached_node = 1 },
})

core.register_craft({
    type = 'shapeless',
    output = 'x_farming:bottle_soymilk_raw',
    recipe = {
        'x_farming:soybean',
        'x_farming:soybean',
        'x_farming:soybean',
        'x_farming:soybean',
        'x_farming:soybean',
        'x_farming:bottle_water'
    }
})

---crate
x_farming.register_crate('crate_soybean_3', {
    description = S('Soybean Crate'),
    short_description = S('Soybean Crate'),
    tiles = { 'x_farming_crate_soybean_3.png' },
    _custom = {
        crate_item = 'x_farming:soybean'
    }
})

core.register_on_mods_loaded(function()
    local deco_place_on = {}
    local deco_biomes = {}

    -- MTG
    if core.get_modpath('default') then
        table.insert(deco_place_on, 'default:dirt_with_grass')
        table.insert(deco_biomes, 'grassland')
    end

    -- Everness
    if core.get_modpath('everness') then
        table.insert(deco_place_on, 'everness:dirt_with_crystal_grass')
        table.insert(deco_biomes, 'everness:crystal_forest')
    end

    -- MCL
    if core.get_modpath('mcl_core') then
        table.insert(deco_place_on, 'mcl_core:dirt_with_grass')
        table.insert(deco_biomes, 'Plains')
    end

    if next(deco_place_on) and next(deco_biomes) then
        core.register_decoration({
            name = 'x_farming:soybean',
            deco_type = 'simple',
            place_on = deco_place_on,
            sidelen = 16,
            noise_params = {
                offset = -0.1,
                scale = 0.1,
                spread = { x = 50, y = 50, z = 50 },
                seed = 4242,
                octaves = 3,
                persist = 0.7
            },
            biomes = deco_biomes,
            y_max = 31000,
            y_min = 1,
            decoration = {
                'x_farming:soybean_5',
                'x_farming:soybean_6',
                'x_farming:soybean_7'
            },
            param2 = 3,
        })
    end
end)
