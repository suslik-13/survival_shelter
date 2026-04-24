-- Инициализация мода
local jail_pos = {x=102, y=0, z=-79} -- Координаты камеры
minetest.register_privilege("policeman", {description = "Can use /jail command"}) -- Создаем новую привилегию



-- Регистрация команды /jail
minetest.register_chatcommand("jail", {
    description = "Teleport a player to jail",
    privs = {policeman = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(param) -- Получаем игрока по имени
        if player then
            player:setpos(jail_pos) -- Телепортируем игрока в камеру
            beds.on_rightclick(jail_pos, player)
            minetest.chat_send_all(minetest.colorize("blue", "*** Player "..param.." has been jailed. ***"))
        else
            minetest.chat_send_player(name, "Player "..param.." not found.") -- Отправляем сообщение, если игрок не найден
        end
    end,
})

-- Регистрация команды /release
minetest.register_chatcommand("release", {
    description = "Teleport a player out of jail",
    privs = {policeman = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(param) -- Получаем игрока по имени
        if player then
            player:setpos({x=101, y=5, z=-92}) -- Телепортируем игрока за пределы камеры
            minetest.chat_send_all(minetest.colorize("blue", "*** Player "..param.." has been released from prison. ***"))
        else
            minetest.chat_send_player(name, "Player "..param.." not found.") -- Отправляем сообщение, если игрок не найден
        end
    end,
})

