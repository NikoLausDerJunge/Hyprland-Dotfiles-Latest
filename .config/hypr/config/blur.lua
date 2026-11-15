-- Rofi Blur
hl.layer_rule({
    name = "rofi-blur",
    match = {
        namespace = "^rofi$",
    },

    blur = true,
    ignore_alpha = 0.0,
})

-- Dunst Notification Blur
hl.layer_rule({
    name = "dunst-blur",
    match = {
        namespace = "^notifications$",
    },

    blur = true,
    ignore_alpha = 0.0,
})