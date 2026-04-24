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

---Crates
x_farming.register_crate('crate_empty', {
    description = S('Empty Crate'),
    tiles = { 'x_farming_crate_empty.png' },
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 2,
        -- MCL
        handy = 1,
        material_wood = 1,
        deco_block = 1,
        fire_encouragement = 3,
        fire_flammability = 4,
        -- ALL
        flammable = 2
    },
    stack_max = tonumber(core.settings:get('default_stack_max')) or 99
})

if core.get_modpath('farming') then
    ---crate wheat
    x_farming.register_crate('crate_wheat_3', {
        description = S('Wheat Crate'),
        short_description = S('Wheat Crate'),
        tiles = { 'x_farming_crate_wheat_3.png' },
        _custom = {
            crate_item = 'farming:wheat'
        }
    })

    ---crate cotton
    x_farming.register_crate('crate_cotton_3', {
        description = S('Cotton Crate'),
        short_description = S('Cotton Crate'),
        tiles = { 'x_farming_crate_cotton_3.png' },
        _custom = {
            crate_item = 'farming:cotton'
        }
    })
end
