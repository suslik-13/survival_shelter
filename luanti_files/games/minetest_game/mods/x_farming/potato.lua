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
local minlight = 13
local maxlight = 14

-- POTATO
x_farming.register_plant('x_farming:potato', {
    description = S('Planting Potato') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Planting Potato'),
    paramtype2 = 'meshoptions',
    inventory_image = 'x_farming_potato_seed.png',
    steps = 8,
    minlight = minlight,
    maxlight = maxlight,
    fertility = { 'grassland' },
    groups = { flammable = 4 },
    place_param2 = 3
})

-- needed
local potato_def = {
    description = S('Potato') .. '\n' .. S('Compost chance') .. ': 65%\n'
        .. core.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    short_description = S('Potato'),
    groups = {
        -- X Farming
        compost = 65,
        -- MCL
        food = 2,
        eatable = 1,
        compostability = 65,
        smoker_cookable = 1
    },
    _mcl_saturation = 0.6
}

if core.get_modpath('farming') then
    potato_def.on_use = core.item_eat(2)
end

if core.get_modpath('mcl_farming') then
    potato_def.on_place = core.item_eat(2)
    potato_def.on_secondary_use = core.item_eat(2)
end

core.override_item('x_farming:potato', potato_def)

-- add poisonous potato to drops
core.override_item('x_farming:potato_8', {
    drop = {
        items = {
            { items = { 'x_farming:potato' }, rarity = 1 },
            { items = { 'x_farming:potato' }, rarity = 2 },
            { items = { 'x_farming:poisonouspotato' }, rarity = 5 },
            { items = { 'x_farming:seed_potato' }, rarity = 1 },
            { items = { 'x_farming:seed_potato' }, rarity = 2 },
        }
    }
})

-- Baked Potato
local baked_potato_def = {
    description = S('Baked Potato') .. '\n' .. S('Compost chance') .. ': 85%\n'
        .. core.colorize(x_farming.colors.brown, S('Hunger') .. ': 6'),
    short_description = S('Baked Potato'),
    groups = {
        -- X Farming
        compost = 85,
        -- MCL
        food = 2,
        eatable = 5,
        compostability = 85
    },
    inventory_image = 'x_farming_potato_baked.png',
    _mcl_saturation = 6.0,
}

if core.get_modpath('farming') then
    baked_potato_def.on_use = core.item_eat(6)
end

if core.get_modpath('mcl_farming') then
    baked_potato_def.on_place = core.item_eat(6)
    baked_potato_def.on_secondary_use = core.item_eat(6)
end

core.register_craftitem('x_farming:bakedpotato', baked_potato_def)

-- Poisonouos Potato
local poisonouspotato_def = {
    description = S('Poisonous Potato') .. '\n'
        .. core.colorize(x_farming.colors.brown, S('Hunger') .. ': -6'),
    inventory_image = 'x_farming_potato_poisonous.png',
    groups = { food = 2, eatable = 2 },
    _mcl_saturation = 1.2,
}

if x_farming.hbhunger ~= nil or x_farming.hunger_ng ~= nil then
    poisonouspotato_def.description = poisonouspotato_def.description .. '\n'
        .. core.colorize(x_farming.colors.green, S('Poison') .. ': 5')
end

if core.get_modpath('farming') then
    poisonouspotato_def.on_use = core.item_eat(-6)
end

if core.get_modpath('mcl_farming') then
    poisonouspotato_def.on_place = core.item_eat(-6)
    poisonouspotato_def.on_secondary_use = core.item_eat(-6)

    core.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
        -- 60% chance of poisoning with poisonous potato
        if itemstack:get_name() == 'x_farming:poisonouspotato' then
            if math.random(1, 10) >= 6 then
                mcl_potions.poison_func(user, 1, 5)
            end
        end
    end)
end

core.register_craftitem('x_farming:poisonouspotato', poisonouspotato_def)

---crate
x_farming.register_crate('crate_potato_3', {
    description = S('Potato Crate'),
    short_description = S('Potato Crate'),
    tiles = { 'x_farming_crate_potato_3.png' },
    _custom = {
        crate_item = 'x_farming:potato'
    }
})

core.register_on_mods_loaded(function()
    local deco_place_on = {}
    local deco_biomes = {}

    -- MTG
    if core.get_modpath('default') then
        table.insert(deco_place_on, 'default:silver_sand')
        table.insert(deco_biomes, 'cold_desert')
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
            name = 'x_farming:potato',
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
                'x_farming:potato_5',
                'x_farming:potato_6',
                'x_farming:potato_7',
                'x_farming:potato_8',
            },
            param2 = 3,
        })
    end
end)
