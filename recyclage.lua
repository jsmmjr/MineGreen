minetest.register_node("my_mod:recycling_station", {
    description = "Recycling Station",
    tiles = {
        "recycling_station_top.png",     -- Image pour le dessus
        "recycling_station_bottom.png",  -- Image pour le dessous
        "recycling_station_side.png",    -- Image pour le côté (utilisée sur les quatre côtés)
    },
    groups = {cracky = 1},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local inv = player:get_inventory()
        local plastic_bottle_count = check_bottle_count(player, "my_mod:plastic_bottle")
        local glass_bottle_count = check_bottle_count(player, "my_mod:glass_bottle")

        if plastic_bottle_count > 0 then
            inv:remove_item("main", "my_mod:plastic_bottle " .. plastic_bottle_count)
            inv:add_item("main", "my_mod:resin " .. plastic_bottle_count)
        end

        if glass_bottle_count > 0 then
            inv:remove_item("main", "my_mod:glass_bottle " .. glass_bottle_count)
            inv:add_item("main", "my_mod:glass_fragments " .. glass_bottle_count)
        end

        if plastic_bottle_count > 0 or glass_bottle_count > 0 then
            minetest.chat_send_player(player:get_player_name(), "Vous avez recyclé vos bouteilles.")
            if not congratulations_sent then
                minetest.chat_send_player(player:get_player_name(), "Félicitations ! Vous avez complété la 3ème mission !")
                congratulations_sent = true
            end
        else
            minetest.chat_send_player(player:get_player_name(), "Vous n'avez pas de bouteilles à recycler.")
        end
    end,
})