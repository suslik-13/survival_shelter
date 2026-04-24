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

-- CORN
x_farming.register_plant('x_farming:corn', {
    description = S('Corn Seed') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Corn Seed'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_corn_seed.png',
    steps = 10,
    minlight = 13,
    maxlight = 14,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 3,
})

-- needed
local corn_def = {
    description = S('Corn') .. '\n' .. S('Compost chance') .. ': 50%',
    short_description = S('Corn'),
    groups = {
        -- X Farming
        compost = 50,
        -- MCL
        compostability = 50,
    },
}

core.override_item('x_farming:corn', corn_def)

core.override_item('x_farming:corn_6', {
    visual_scale = 2.0,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, 0.6, 0.25 }
    }
})

core.override_item('x_farming:corn_7', {
    visual_scale = 2.0,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, 0.6, 0.25 }
    }
})

core.override_item('x_farming:corn_8', {
    visual_scale = 2.0,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, 0.6, 0.25 }
    }
})

core.override_item('x_farming:corn_9', {
    visual_scale = 2.0,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, 0.6, 0.25 }
    }
})

core.override_item('x_farming:corn_10', {
    visual_scale = 2.0,
    selection_box = {
        type = 'fixed',
        fixed = { -0.25, -0.5, -0.25, 0.25, 0.6, 0.25 }
    }
})

-- Popped corn
local popperd_corn_def = {
    description = S('Popped corn') .. '\n' .. S('Compost chance') .. ': 50%\n'
        .. core.colorize(x_farming.colors.brown, S('Hunger') .. ': 1'),
    short_description = S('Popped corn'),
    inventory_image = 'x_farming_corn_pop.png',
    groups = {
        -- MTG
        compost = 50,
        -- MCL
        food = 2,
        eatable = 2,
        compostability = 50
    },
}

if core.get_modpath('farming') then
    popperd_corn_def.on_use = core.item_eat(1)
end

if core.get_modpath('mcl_farming') then
    popperd_corn_def.on_place = core.item_eat(1)
    popperd_corn_def.on_secondary_use = core.item_eat(1)
end

core.register_craftitem('x_farming:corn_pop', popperd_corn_def)

-- Popcorn
local popcorn_def = {
    description = S('Popcorn') .. '\n' .. S('Compost chance') .. ': 65%\n'
        .. core.colorize(x_farming.colors.brown, S('Hunger') .. ': 5'),
    short_description = S('Popcorn'),
    drawtype = 'mesh',
    mesh = 'x_farming_corn_popcorn.obj',
    tiles = { 'x_farming_corn_popcorn_mesh.png' },
    use_texture_alpha = 'clip',
    inventory_image = 'x_farming_corn_popcorn.png',
    wield_image = 'x_farming_corn_popcorn.png',
    paramtype = 'light',
    is_ground_content = false,
    walkable = true,
    selection_box = {
        type = 'fixed',
        fixed = { -0.3, -0.5, -0.3, 0.3, 0.4, 0.3 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -0.3, -0.5, -0.3, 0.3, 0.25, 0.3 }
    },
    groups = {
        -- MTG
        dig_immediate = 3,
        attached_node = 1,
        -- X Farming
        compost = 65,
        -- MCL
        food = 2,
        eatable = 2,
        compostability = 65,
        handy = 1,
        deco_block = 1,
        fire_encouragement = 60,
        fire_flammability = 100,
        dig_by_water = 1,
        destroy_by_lava_flow = 1,
    },
    sounds = x_farming.node_sound_leaves_defaults(),
    on_use = core.item_eat(5),
    sunlight_propagates = true,
    _mcl_saturation = 0.6,
    _mcl_blast_resistance = 0,
    _mcl_hardness = 0,
}

if core.get_modpath('mcl_farming') then
    popcorn_def.on_secondary_use = core.item_eat(5)
end

core.register_node('x_farming:corn_popcorn', popcorn_def)

---crate
x_farming.register_crate('crate_corn_3', {
    description = S('Corn Crate'),
    short_description = S('Corn Crate'),
    tiles = { 'x_farming_crate_corn_3.png' },
    _custom = {
        crate_item = 'x_farming:corn'
    }
})

core.register_on_mods_loaded(function()
    local deco_place_on = {}
    local deco_biomes = {}

    -- MTG
    if core.get_modpath('default') then
        table.insert(deco_place_on, 'default:sand')
        table.insert(deco_biomes, 'sandstone_desert')
    end

    -- Everness
    if core.get_modpath('everness') then
        table.insert(deco_place_on, 'everness:forsaken_desert_sand')
        table.insert(deco_biomes, 'everness:forsaken_desert')
    end

    -- MCL
    if core.get_modpath('mcl_core') then
        table.insert(deco_place_on, 'mcl_core:sand')
        table.insert(deco_biomes, 'Desert')
    end

    if next(deco_place_on) and next(deco_biomes) then
        core.register_decoration({
            name = 'x_farming:corn',
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
                'x_farming:corn_6',
                'x_farming:corn_7',
                'x_farming:corn_8',
                'x_farming:corn_9',
                'x_farming:corn_10',
            },
            param2 = 3,
        })
    end
end)
