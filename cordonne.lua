local function update_player_coordinates(player)
    local pos = player:get_pos()
    local player_name = player:get_player_name()
    
    -- Formatage du texte pour les coordonnées
    local coords_text = string.format("Pos: (%.5f, %.5f, %.5f)", pos.x, pos.y, pos.z)
    
    -- Vérifier si l'élément HUD existe déjà
    local hud_id = player:get_attribute("coords_hud_id")
    if not hud_id then
        -- Ajouter un nouvel élément HUD
        hud_id = player:hud_add({
            hud_elem_type = "text",
            position = {x = 0.5, y = 0.3},
            offset = {x = 0, y = 0},
            text = coords_text,
            alignment = {x = 0, y = 0},
            scale = {x = 100, y = 100},
            number = 0xFFFFFF,
        })
        player:set_attribute("coords_hud_id", hud_id)
    else
        -- Mettre à jour l'élément HUD existant
        player:hud_change(hud_id, "text", coords_text)
    end
end