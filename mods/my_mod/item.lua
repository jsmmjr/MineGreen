
minetest.register_node("my_mod:hola_stone", {
    description = "Hola Stone",
    tiles = {"magic_stone.png"},
    is_ground_content = true,
    groups = {cracky = 3, stone = 1},
    drop = "my_mod:hola_stone",
})


minetest.register_craftitem("my_mod:plastic_bottle", {
    description = "Plastic Bottle",
    inventory_image = "plastic_bottle.png"
})


minetest.register_craftitem("my_mod:glass_bottle", {
    description = "Glass Bottle",
    inventory_image = "glass_bottle.png",
    groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
    sounds = default.node_sound_glass_defaults(),
})


minetest.register_craftitem("my_mod:trash_bag", {
    description = "Trash Bag",
    inventory_image = "trash_bag.png"
})


minetest.register_craftitem("my_mod:resin", {
    description = "Resin",
    inventory_image = "resin.png"
})


minetest.register_craft({
    output = "my_mod:plastic_bottle",
    recipe = {
        {"default:material", "default:material", "default:material"},
        {"default:material", "", "default:material"},
        {"default:material", "default:material", "default:material"},
    }
})


minetest.register_craft({
    type = "shaped",
    output = "my_mod:glass_bottle",
    recipe = {
        {"default:material", "", ""},
        {"", "default:material", ""},
        {"", "", "default:material"}
    }
})


minetest.register_craft({
    type = "shaped",
    output = "my_mod:resin",
    recipe = {
        {"", "my_mod:plastic_bottle", ""},
        {"", "my_mod:plastic_bottle", ""},
        {"", "my_mod:plastic_bottle", ""}
    }
})