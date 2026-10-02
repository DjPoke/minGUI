-- Shift + left drag selects images in one container, within its visible bounds.
function minGUI_clear_image_selection()
    for _, g in pairs(minGUI.gtree) do
        if g.tp == MG_IMAGE then g.selected = false end
    end
end

local function bounds(id, g)
    local ox, oy = minGUI_get_parent_gadget_offset(id)
    local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(g.parent)
    local x, y = math.max(ox + g.x, sx), math.max(oy + g.y, sy)
    return x, y, math.min(ox + g.x + g.width, sx + sw) - x,
        math.min(oy + g.y + g.height, sy + sh) - y
end

function minGUI_update_image_selection()
    local mouse = minGUI.mouse
    local selection = minGUI.imageSelection
    if not selection and mouse.mpressed[MG_LEFT_BUTTON]
        and love.keyboard.isDown("lshift", "rshift") then
        for id, g in minGUI_each_gadget(true) do
            local x, y, w, h = bounds(id, g)
            if w > 0 and h > 0 and mouse.x >= x and mouse.x < x + w
                and mouse.y >= y and mouse.y < y + h then
                -- Shift-drag an already selected icon to transfer the group.
                if g.tp == MG_IMAGE and g.selected then return false end
                local parent
                if g.tp == MG_IMAGE or g.tp == MG_LABEL then parent = g.parent
                elseif g.tp == MG_SCROLLAREA or g.tp == MG_PANEL then parent = id end
                if parent and not g.isInternal then
                    minGUI_clear_image_selection()
                    minGUI_activate_window_at_pointer()
                    selection = {parent = parent, x = mouse.x, y = mouse.y}
                    minGUI.imageSelection = selection
                    minGUI.gadgetDrag, minGUI.lastGadgetClicks = nil, nil
                end
                break -- The first hit obscures everything beneath it.
            end
        end
    end
    if not selection then return false end
    if not minGUI.gtree[selection.parent] then
        minGUI.imageSelection = nil
        return true
    end
    local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(selection.parent)
    local endX = math.max(sx, math.min(mouse.x, sx + sw))
    local endY = math.max(sy, math.min(mouse.y, sy + sh))
    selection.left, selection.top = math.min(selection.x, endX), math.min(selection.y, endY)
    selection.width, selection.height = math.abs(selection.x - endX), math.abs(selection.y - endY)
    for id, g in pairs(minGUI.gtree) do
        if g.tp == MG_IMAGE and g.parent == selection.parent then
            local x, y, w, h = bounds(id, g)
            g.selected = w > 0 and h > 0 and selection.width > 0 and selection.height > 0
                and x < selection.left + selection.width and x + w > selection.left
                and y < selection.top + selection.height and y + h > selection.top
        end
    end
    if not mouse.mbtn[MG_LEFT_BUTTON] then minGUI.imageSelection = nil end
    return true
end

function minGUI_draw_image_selection()
    local selection = minGUI.imageSelection
    if not selection then return end
    love.graphics.push("all")
    love.graphics.setCanvas()
    local x, y, w, h = minGUI_get_gadget_parents_scissor(selection.parent)
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(0.2, 0.5, 1, 0.15)
    love.graphics.rectangle("fill", selection.left, selection.top, selection.width, selection.height)
    love.graphics.setColor(0.2, 0.5, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", selection.left, selection.top, selection.width, selection.height)
    love.graphics.pop()
end
