-- Инициализация мода
local protected_areas = {
    {
        min_x = 80,
        max_x = 106,
        min_y = -12,
        max_y = 26,
        min_z = -72,
        max_z = -109,
        blocked_commands = {"kill", "teleport", "home", "tpr", "tphr", "spawn", "sethome"} -- Заблокированные команды на этой территории
    },
    {
        min_x = 1126,
        max_x = 1177,
        min_y = 7,
        max_y = 35,
        min_z = 2004,
        max_z = 2055,
        blocked_commands = {"teleport", "home"} -- Заблокированные команды на этой территории
    },
    {
        min_x = 5810,
        max_x = 5888,
        min_y = 13,
        max_y = 27,
        min_z = 2772,
        max_z = 2813,
        blocked_commands = {"teleport", "home"} -- Заблокированные команды на этой территории
    }
}

-- Функция для проверки, находится ли игрок на защищенной территории
local function is_player_in_protected_area(pos)
    for _, area in ipairs(protected_areas) do
        if pos.x >= area.min_x and pos.x <= area.max_x and
           pos.y >= area.min_y and pos.y <= area.max_y and
           pos.z >= area.min_z and pos.z <= area.max_z then
            return area.blocked_commands -- Возвращаем список заблокированных команд на этой территории
        end
    end
    return nil -- Не нашли защищенную территорию
end

-- Блокировка команд в чате на защищенных территориях
minetest.register_on_chat_message(function(name, message)
    local player = minetest.get_player_by_name(name)
    local pos = player:getpos()
    local blocked_commands = is_player_in_protected_area(pos)
    if blocked_commands ~= nil then
        for _, cmd in ipairs(blocked_commands) do
            if message:sub(1, #cmd + 1) == "/" .. cmd then
                minetest.chat_send_player(name, "Command \"" .. cmd .. "\" is blocked on this territory.")
                return true -- Блокируем команду
            end
        end
    end
end)

