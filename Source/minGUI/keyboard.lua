-- Shortcut strings use LÖVE key names, for example "ctrl+s" or "shift+f5".
local modifiers = {
    ctrl = {"lctrl", "rctrl"}, shift = {"lshift", "rshift"},
    alt = {"lalt", "ralt"}, gui = {"lgui", "rgui"}
}
local aliases = {control = "ctrl", cmd = "gui", super = "gui"}

function minGUI_add_keyboard_shortcut(self, window, shortcut, event)
    assert(self.gtree[window] and self.gtree[window].tp == MG_WINDOW,
        "add_keyboard_shortcut: invalid window")
    assert(type(shortcut) == "string" and shortcut ~= "",
        "add_keyboard_shortcut: expected a shortcut string")
    assert(event ~= nil, "add_keyboard_shortcut: missing event")
    local binding = {modifiers = {}, event = event}
    for part in (shortcut:lower() .. "+"):gmatch("(.-)%+") do
        part = part:match("^%s*(.-)%s*$")
        part = aliases[part] or part
        assert(part ~= "", "add_keyboard_shortcut: empty key")
        if modifiers[part] then
            binding.modifiers[part] = true
        else
            assert(not binding.key, "add_keyboard_shortcut: expected one main key")
            binding.key = part
        end
    end
    assert(binding.key, "add_keyboard_shortcut: missing main key")
    local parts = {}
    for _, name in ipairs({"ctrl", "shift", "alt", "gui"}) do
        if binding.modifiers[name] then parts[#parts + 1] = name end
    end
    parts[#parts + 1] = binding.key
    binding.shortcut = table.concat(parts, "+")
    self.gtree[window].keyboardShortcuts = self.gtree[window].keyboardShortcuts or {}
    self.gtree[window].keyboardShortcuts[binding.shortcut] = binding
    return binding.shortcut
end

function minGUI_update_keyboard_shortcuts()
    local active = minGUI_active_window()
    for id, window in pairs(minGUI.gtree) do
        for _, binding in pairs(window.keyboardShortcuts or {}) do
            local down = love.keyboard.isDown(binding.key)
            for name, keys in pairs(modifiers) do
                local held = love.keyboard.isDown(keys[1], keys[2])
                down = down and held == (binding.modifiers[name] == true)
            end
            if down and not binding.down and id == active then
                table.insert(minGUI.gstack, {eventGadget = id, eventType = binding.event})
            end
            -- Track inactive windows too: changing focus while held must not fire.
            binding.down = down
        end
    end
end
