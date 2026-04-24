local S = minetest.get_translator("tntrun")

minetest.register_node("tntrun:killer", {
    description = S("Killer"),
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,

    walkable     = false,
    pointable    = true,
    diggable     = true,
    buildable_to = false,
    drop = "",
    damage_per_second = 40,
    groups = {oddly_breakable_by_hand = 1},
})
