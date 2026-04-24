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
-- Functions
--

-- Used to calculate the damage per second
mobs_others.fn_DamagePerSecond = function(self)

	-- Variables
	local i_hitPoints, i_timeSpeed, i_inGameDayLength, i_fiveInGameMinutes,
		i_damagePerSecond

	i_hitPoints = self.health
	i_timeSpeed = tonumber(minetest.settings:get('i_timeSpeed')) or 72

	if (i_timeSpeed == 0) then
		i_timeSpeed = 1
	end

	i_inGameDayLength = 86400 / i_timeSpeed
	i_fiveInGameMinutes = (i_inGameDayLength * 300) / 86400
	i_damagePerSecond = i_hitPoints / i_fiveInGameMinutes

	return i_damagePerSecond
end


-- Used to apply random textures on the mobs
mobs_others.fn_RandomAppearence = function()

	-- Variables
	local t_appearence = {}
	local s_chosenSkin, s_chosenArmour, s_chosenWeapon

	-- Constants
	local t_SKINS = {
		'mobs_others_snow_walker.png',
		'mobs_others_snow_walker_1.png',
		'mobs_others_snow_walker_2.png'
	}

	local t_WEAPONS = {
		'mobs_others_crystal_sword.png',
		'mobs_others_crystal_axe.png'
	}

	local s_ARMOUR = 'mobs_others_chestplate_crystal.png' ..
		'^' .. 'mobs_others_leggings_crystal.png' ..
		'^' .. 'mobs_others_boots_crystal.png'

	local s_ARMOUR_HELMET = 'mobs_others_helmet_crystal.png' ..
		'^' .. 'mobs_others_chestplate_crystal.png' ..
		'^' .. 'mobs_others_leggings_crystal.png' ..
		'^' .. 'mobs_others_boots_crystal.png'

	local s_ARMOUR_SHIELD = 'mobs_others_chestplate_crystal.png' ..
		'^' .. 'mobs_others_leggings_crystal.png' ..
		'^' .. 'mobs_others_boots_crystal.png' ..
		'^' .. 'mobs_others_shield_crystal.png'

	local s_ARMOUR_HELMET_SHIELD = 'mobs_others_helmet_crystal.png' ..
		'^' .. 'mobs_others_chestplate_crystal.png' ..
		'^' .. 'mobs_others_leggings_crystal.png' ..
		'^' .. 'mobs_others_boots_crystal.png' ..
		'^' .. 'mobs_others_shield_crystal.png'

	local t_ARMOURS = {
		s_ARMOUR,
		s_ARMOUR_HELMET,
		s_ARMOUR_SHIELD,
		s_ARMOUR_HELMET_SHIELD
	}

	math.randomseed(os.time())

	s_chosenSkin = t_SKINS[math.random(1, 3)]
	s_chosenArmour = t_ARMOURS[math.random(1, 4)]
	s_chosenWeapon = t_WEAPONS[math.random(1, 2)]

	table.insert(t_appearence, 1, s_chosenSkin)
	table.insert(t_appearence, 2, s_chosenArmour)
	table.insert(t_appearence, 3, s_chosenWeapon)
	table.insert(t_appearence, 4, 'mobs_others_transparent.png')

	return t_appearence
end
