minetest.register_on_joinplayer(function(player)
  achvmt_lib.add_player_to_storage(player:get_player_name())
end)
