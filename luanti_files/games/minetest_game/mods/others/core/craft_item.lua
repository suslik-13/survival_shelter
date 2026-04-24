--[[

	Mobs Others - Adds the Snow Walkers mobs.
	Copyright © 2018, 2020 Hamlet and contributors.

	Licensed under the EUPL, Version 1.2 or – as soon they will be
	approved by the European Commission – subsequent versions of the
	EUPL (the "Licence");
	You may not use this work except in compliance with the Licence.
	You may obtain a copy of the Licence at:

	https://joinup.ec.europa.eu/software/page/eupl
	https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0863

	Unless required by applicable law or agreed to in writing,
	software distributed under the Licence is distributed on an
	"AS IS" basis,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
	implied.
	See the Licence for the specific language governing permissions
	and limitations under the Licence.

--]]


--
-- Constant
--

-- Used for localization
local S = minetest.get_translator('mobs_others')


--
-- Obsidian Sword definition
--

minetest.register_tool('mobs_others:sword_obsidian', {
	description = S('Obsidian Sword'),
	inventory_image = 'default_tool_steelsword.png^[colorize:black:171',
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level= 1,
		groupcaps= {
			snappy= {
				times= {
					[1]=1.90,[2]=0.90,[3]=0.30
				},
				uses = 40, maxlevel = 3
			},
		},
		damage_groups = {fleshy = 7},
	},
	range = 3,
	sound = {breaks = 'default_tool_breaks'},
})


minetest.register_craft({
	output = 'mobs_others:sword_obsidian',
	recipe = {
		{'default:obsidian_shard'},
		{'default:obsidian_shard'},
		{'group:stick'},
	}
})
