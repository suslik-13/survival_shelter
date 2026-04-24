-- список команд для логирования
local commands = {"/teleport", "/ban", "/kick", "/xban", "/jail"}

-- функция для логирования
local function log_command(player_name, message)
    -- проверяем, была ли команда использована
    for _, command in ipairs(commands) do
        if message:sub(1, #command) == command then
            -- логируем использование команды
            print("command logged:", player_name, message)
            minetest.log("action", player_name.." used command: "..message)
            break
        end
    end
end

-- регистрируем функцию-обработчик
minetest.register_on_chat_message(function(name, message)
    log_command(name, message)
end)

