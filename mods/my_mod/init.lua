local bottles = {}
local mission_completed = false
local second_mission_completed = false

depends = {"default"}


minetest.register_on_newplayer(function(player)
    player:set_pos({x = 85.9, y =73.5, z = 107.9})  
end)

minetest.register_on_respawnplayer(function(player)
    player:set_pos({x = 100, y = 20, z = -50})  
    return true  
end)


local function check_bottle_count(player, bottle_type)
    local inv = player:get_inventory()
    local count = 0

    for _, stack in ipairs(inv:get_list("main")) do
        if stack:get_name() == bottle_type then
            count = count + stack:get_count()
        end
    end

    return count
end


local function spawn_bottles_around_player(player)
    local pos = player:get_pos()
    for i = 1, 10 do
        local offset = {x = math.random(-10, 10), y = 0, z = math.random(-10, 10)}
        local bottle_pos = vector.add(pos, offset)
        local bottle = minetest.add_item(bottle_pos, "minegreen:plastic_bottle")
        table.insert(bottles, bottle)
    end
end

local function spawn_glass_bottles_around_player(player)
    local pos = player:get_pos()
    -- Check if the glass bottles have already been placed
    if player:get_attribute("glass_bottles_spawned") then
        return  
    end

    for i = 1, 10 do
        local offset = {x = math.random(-10, 10), y = 0, z = math.random(-10, 10)}
        local bottle_pos = vector.add(pos, offset)
        local bottle = minetest.add_item(bottle_pos, "minegreen:glass_bottle")
        table.insert(bottles, bottle)
    end

    
    player:set_attribute("glass_bottles_spawned", "true")
end


local function remove_all_bottles()
    for i = #bottles, 1, -1 do
        local bottle = bottles[i]
        if bottle and bottle:get_luaentity() then
            local item_name = bottle:get_luaentity().itemstring
            if item_name == "minegreen:plastic_bottle" or item_name == "minegreen:glass_bottle" then
                bottle:remove()
                table.remove(bottles, i)
            end
        end
    end
end

local function spawn_recycling_station_around_player(player)
    local pos = player:get_pos()
    -- Check if the recycling station has already been placed
    if player:get_attribute("recycling_station_spawned") then
        return  -- Do nothing if the recycling station has already been placed
    end

    local offset = {x = math.random(-10, 10), y = 0, z = math.random(-10, 10)}
    local station_pos = vector.add(pos, offset)
    minetest.set_node(station_pos, {name = "minegreen:recycling_station"})

  
    player:set_attribute("recycling_station_spawned", "true")
end





local function show_intro(player)
    local player_name = player:get_player_name()
    local formspec = "size[9,3]" ..
                     "label[2.45,0;Welcome to Minetest!]" ..
                     "label[1,1;Save the planet before it's too late!]" ..
                     "button[2.5,2;4,1;next;Next]"
    minetest.show_formspec(player_name, "minegreen_intro", formspec)
end

local function show_mission_hud(player)
    local player_name = player:get_player_name()
    local mission_text = "1st mission: Collect 10 plastic bottles"

    if not mission_completed then
        
        local hud_bg_def = {
            hud_elem_type = "image",
            position = {x = 0.8, y = 0.007},
            scale = {x = 3, y = 1},  
            text = "cropped-gris.png",  -- Transparent background color image
            alignment = {x = 1, y = 0},
            offset = {x = -50, y = 0},  
        }

        local hud_bg_id = player:hud_add(hud_bg_def)
        player:set_attribute("mission_hud_bg_id", hud_bg_id)

     
        local hud_text_def = {
            hud_elem_type = "text",
            position = {x = 0.78, y = 0.05},
            text = mission_text,
            number = 0xFFFFFF,
            alignment = {x = 1, y = 0},
            scale = {x = 100, y = 100},
            offset = {x = 0, y = 0},
        }

        local hud_text_id = player:hud_add(hud_text_def)
        player:set_attribute("mission_hud_id", hud_text_id)
    end

    if not player:get_attribute("bottles_spawned") then
        spawn_bottles_around_player(player)
        player:set_attribute("bottles_spawned", "true")
    end
end


local function show_next_text(player)
    local player_name = player:get_player_name()
    local formspec = "size[9,3]" ..
                     "label[2.8,0;Follow the missions!]" ..
                     "label[0,1;1st mission: Collect the bottles]" ..
                     "button[2.5,2;4,1;close;Start]"
    minetest.show_formspec(player_name, "minegreen_next", formspec)
    show_mission_hud(player)
end

minetest.register_on_joinplayer(function(player)
    show_intro(player)
end)

minetest.register_on_leaveplayer(function(player)
    remove_all_bottles()
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "minegreen_intro" then
        if fields.next then
            show_next_text(player)
        end
    elseif formname == "minegreen_next" then
        if fields.close then
            minetest.close_formspec(player:get_player_name(), "minegreen_next")
        end
    end
end)

local function show_hud(player)
    local player_name = player:get_player_name()
    local hud_def = {
        hud_elem_type = "text",
        position = {x = 0.5, y = 0.05},
        text = "Santé : 100%",
        number = 0xFFFFFF,
        alignment = {x = 0.5, y = 0},
        scale = {x = 100, y = 100},
    }
    local hud_id = player:hud_add(hud_def)
    player:set_attribute("health_percentage", "100")
    player:set_attribute("hud_id", hud_id)
end

local function show_fatigue_hud(player)
    local player_name = player:get_player_name()
    local hud_def = {
        hud_elem_type = "text",
        position = {x = 0.5, y = 0.1},
        text = "Fatigue : 100%",
        number = 0xFFFFFF,
        alignment = {x = 0.5, y = 0},
        scale = {x = 100, y = 100},
    }
    local hud_id = player:hud_add(hud_def)
    player:set_attribute("fatigue_percentage", "100")
    player:set_attribute("fatigue_hud_id", hud_id)
end

minetest.register_on_joinplayer(function(player)
    show_hud(player)
    show_fatigue_hud(player)
end)

local last_positions = {}

local function update_health(player, damage)
    local player_name = player:get_player_name()
    local health_percentage = tonumber(player:get_attribute("health_percentage")) or 100

    health_percentage = math.max(0, health_percentage - (damage * 5))
    player:set_attribute("health_percentage", tostring(health_percentage))
end

local congratulations_sent = false

local function update_hud(player)
    local player_name = player:get_player_name()
    local health_percentage = tonumber(player:get_attribute("health_percentage")) or 100
   
    local bottle_count_plastic = check_bottle_count(player, "minegreen:plastic_bottle")
    local bottle_count_glass = check_bottle_count(player, "minegreen:glass_bottle")
    local resin_count = check_bottle_count(player, "minegreen:resin")

    local hud_id = player:get_attribute("hud_id")
    if not hud_id then
        hud_id = player:hud_add({
            hud_elem_type = "text",
            position = {x = 0.5, y = 0.5},
            offset = {x = 0, y = 0},
            text = string.format("Health : %.1f%%", health_percentage),
            alignment = {x = 1, y = 0},
            scale = {x = 100, y = 100},
            number = 0xFFFFFF,
        })
        player:set_attribute("hud_id", hud_id)
    else
        player:hud_change(hud_id, "text", string.format("Health : %.1f%%", health_percentage))
    end

    if bottle_count_plastic == 10 and not mission_completed then
        mission_completed = true
        local hud_id = player:hud_add({
            hud_elem_type = "text",
            position = {x = 0.5, y = 0.5},
            offset = {x = 0, y = 0},
            text = "1st mission accomplished!\nIt's time for the 2nd mission.",
            alignment = {x = 0, y = 0},
            scale = {x = 100, y = 100},
            number = 0xFFFFFF,
        })

        minetest.after(5, function()
            player:hud_remove(hud_id)
        end)

        spawn_glass_bottles_around_player(player)

        local second_mission_text = "2nd mission: Collect 10 glass bottles"
        local second_hud_bg_def = {
            hud_elem_type = "image",
            position = {x = 0.8, y = 0.007},
            scale = {x = 3, y = 1},
            text = "cropped-gris.png",
            alignment = {x = 1, y = 0},
            offset = {x = -50, y = 0},
        }

        local second_hud_bg_id = player:hud_add(second_hud_bg_def)
        player:set_attribute("second_mission_hud_bg_id", second_hud_bg_id)

        local second_hud_def = {
            hud_elem_type = "text",
            position = {x = 0.78, y = 0.05},
            text = second_mission_text,
            number = 0xFFFFFF,
            alignment = {x = 1, y = 0},
            scale = {x = 100, y = 100},
            offset = {x = 0, y = 0},
        }

        local second_hud_id = player:hud_add(second_hud_def)
        player:set_attribute("second_mission_hud_id", second_hud_id)
    elseif bottle_count_glass == 10 and mission_completed and not second_mission_completed then
        second_mission_completed = true

        local hud_id = player:hud_add({
            hud_elem_type = "text",
            position = {x = 0.5, y = 0.5},
            offset = {x = 0, y = 0},
            text = "2nd mission accomplished!\nIt's time for the 3rd mission.",
            alignment = {x = 0, y = 0},
            scale = {x = 100, y = 100},
            number = 0xFFFFFF,
        })

        minetest.after(5, function()
            player:hud_remove(hud_id)
        end)

        spawn_recycling_station_around_player(player)

        local third_mission_text = "3rd mission: Recycle the bottles"
-- Texte explicatif de la mission
local third_mission_explanation = "Help: find the recycling bin"

local third_hud_bg_def = {
    hud_elem_type = "image",
    position = {x = 0.8, y = 0.007},
    scale = {x = 3, y = 1},
    text = "cropped-gris.png",
    alignment = {x = 1, y = 0},
    offset = {x = -50, y = 0},
}

local third_hud_bg_id = player:hud_add(third_hud_bg_def)
player:set_attribute("third_mission_hud_bg_id", third_hud_bg_id)

local third_hud_def = {
    hud_elem_type = "text",
    position = {x = 0.78, y = 0.05},
    text = third_mission_text,
    number = 0xFFFFFF,
    alignment = {x = 1, y = 0},
    scale = {x = 100, y = 100},
    offset = {x = 0, y = 0},
}

-- HUD element for explanatory text
local explanation_hud_def = {
    hud_elem_type = "text",
    position = {x = 0.79, y = 0.078},  
    text = third_mission_explanation,
    number = 0x000000,  
    alignment = {x = 1, y = 0},
    scale = {x = 100, y = 100},
    offset = {x = 0, y = 0},
}

local third_hud_id = player:hud_add(third_hud_def)
player:set_attribute("third_mission_hud_id", third_hud_id)

local explanation_hud_id = player:hud_add(explanation_hud_def)
player:set_attribute("third_mission_explanation_hud_id", explanation_hud_id)
    elseif resin_count >= 20 and second_mission_completed and not third_mission_completed then
        third_mission_completed = true
        minetest.chat_send_player(player_name, "3ème mission accomplie ! Vous avez terminé toutes les missions.")

    end


    -- HUD update logic for health
    if health_percentage <= 0 then
        player:set_hp(0)
        local respawn_pos = player:get_pos()
        minetest.after(0.1, function()
            player:set_pos(respawn_pos)
        end)
        player:set_attribute("health_percentage", "100")
    end
end


minetest.register_on_player_hpchange(function(player, hp_change)
    if hp_change < 0 then
        local damage = math.abs(hp_change)
        update_health(player, damage)
        update_hud(player)
    end
end, true)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        update_hud(player)
    end
end)

local function update_fatigue(player, dtime)
    local player_name = player:get_player_name()
    local fatigue_percentage = tonumber(player:get_attribute("fatigue_percentage")) or 100
    local current_pos = player:get_pos()
    local last_pos = last_positions[player_name] or current_pos
    local movement_speed = vector.distance(current_pos, last_pos) / dtime

    if movement_speed > 0.1 then
        fatigue_percentage = math.max(0, fatigue_percentage - 0.5)
    end
    if current_pos.y > last_pos.y + 0.5 then
        fatigue_percentage = math.max(0, fatigue_percentage - 1)
    end

    player:set_attribute("fatigue_percentage", tostring(fatigue_percentage))
    last_positions[player_name] = current_pos
end

local last_positions = {}

local function update_fatigue(player, dtime)
    local player_name = player:get_player_name()
    local fatigue_percentage = tonumber(player:get_attribute("fatigue_percentage")) or 100
    local current_pos = player:get_pos()
    local last_pos = last_positions[player_name] or current_pos
    local movement_speed = vector.distance(current_pos, last_pos) / dtime

    if movement_speed > 0.1 then
        fatigue_percentage = math.max(0, fatigue_percentage - 0.5)
    end
    if current_pos.y > last_pos.y + 0.5 then
        fatigue_percentage = math.max(0, fatigue_percentage - 1)
    end

    player:set_attribute("fatigue_percentage", tostring(fatigue_percentage))
    last_positions[player_name] = current_pos
end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        update_hud(player)
        update_fatigue(player, dtime)
    end
end)

minetest.register_on_respawnplayer(function(player)
    player:set_attribute("health_percentage", "100")
    player:set_attribute("fatigue_percentage", "100")
end)






minetest.register_craftitem("minegreen:plastic_bottle", {
    description = "Plastic Bottle",
    inventory_image = "plastic_bottle.png"
})

minetest.register_craftitem("minegreen:glass_bottle", {
    description = "Glass Bottle",
    inventory_image = "glass_bottle.png",
    groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
    sounds = default.node_sound_glass_defaults(),
})

minetest.register_craftitem("minegreen:trash_bag", {
    description = "Trash Bag",
    inventory_image = "trash_bag.png"
})

minetest.register_craftitem("minegreen:resin", {
    description = "Resin",
    inventory_image = "resin.png"
})


-- Saved the crafting recipe for "Plastic Bottle"
minetest.register_craft({
output = "minegreen",
recipe = {
{"default", "default", "default"},
{"default", "", "default"},
{"default", "default", "default"},
}
})

-- Saved the crafting recipe for "Glass Bottle"
minetest.register_craft({
type = "shaped",
output = "minegreen",
recipe = {
{"default", "", ""},
{"", "default", ""},
{"", "", "default"}
}
})

minetest.register_craft({
    type = "shapeless",
    output = "minegreen:resin",
    recipe = {"minegreen:plastic_bottle"}
})


-- Registration of node "recycling_station"
minetest.register_node("minegreen:recycling_station", {
    description = "Recycling Station",
    tiles = {"recycling_station_top.png", "recycling_station_bottom.png", "recycling_station_side.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 2},

    -- Function called when right-clicking the recycling station
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local inv = player:get_inventory()
        
        -- Check if the player has at least one plastic bottle in the main inventory
        local plastic_bottle_stack = ItemStack("minegreen:plastic_bottle 1")
        if inv:contains_item("main", plastic_bottle_stack) then
     -- Remove a single plastic bottle from the player's inventory
            local success = inv:remove_item("main", plastic_bottle_stack)
            
            if success then
                -- Add a resin to the player's inventory
                local resin_stack = ItemStack("minegreen:resin")
                inv:add_item("main", resin_stack)
                
               -- Inform the player of the success of the operation
                minetest.chat_send_player(player:get_player_name(), "You received 1 resin by recycling a plastic bottle.")
            else
               
                minetest.chat_send_player(player:get_player_name(), "Error: Unable to remove plastic bottle.")
            end
        else
            
            minetest.chat_send_player(player:get_player_name(), "You don't have any plastic bottles to recycle.")
        end
    end,
})
