minetest.register_privilege("lottery_master", {
    description = "Allows the player to start the lottery.",
    give_to_singleplayer = false, -- Устанавливает, можно ли дать привилегию одиночному игроку (true/false)
})

minetest.register_chatcommand("lottery_start", {
    description = "Start a lottery with four random numbers.",
    privs = {lottery_master = true}, -- Только игроки с привилегией "lottery_master" могут использовать команду
    func = function(name, param)
    	local player_name = name
        -- Генерация четырех случайных чисел
        local numbers = {}
        for i = 1, 4 do
            table.insert(numbers, math.random(1, 9))
        end
	
	minetest.chat_send_all(minetest.colorize("yellow", "  Attention: a winning lottery combination of numbers! (lottery started by " .. player_name .. ")"))
        -- Вывод чисел в общий чат
        for _, number in ipairs(numbers) do
            minetest.chat_send_all(minetest.colorize("orange", "Lottery number : " .. number))
        end
    end,
})

