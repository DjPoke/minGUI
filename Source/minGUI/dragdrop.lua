-- The GUI reports source/target IDs; the application decides what to transfer.
function minGUI_gadget_drag_droppable(g)
	return g and (g.tp == MG_STRING or g.tp == MG_EDITOR or g.tp == MG_IMAGE)
		and minGUI_flag_active(g.flags or 0, MG_FLAG_DRAG_DROPPABLE)
end

function minGUI_begin_gadget_drag(num)
	local g = minGUI.gtree[num]
	if minGUI_gadget_drag_droppable(g) then
        local sources = {num}
        if g.tp == MG_IMAGE and g.selected and love.keyboard.isDown("lshift", "rshift") then
            sources = {}
            for id, image in minGUI_each_gadget() do
                if image.tp == MG_IMAGE and image.selected then
                    if not minGUI_gadget_drag_droppable(image) then return end
                    sources[#sources + 1] = id
                end
            end
        end
		minGUI.gadgetDrag = {source = num, sources = sources, x = minGUI.mouse.x, y = minGUI.mouse.y, active = false}
	end
end

local function dropTarget()
	-- A popup obscures the gadgets beneath it.
	for _, menu in minGUI_each_interactive_gadget() do
		if menu.tp == MG_INTERNAL_MENU and menu.menu.selected > 0 then
			local _, _, inside = minGUI_menu_hit(menu)
			if inside then return end
		end
	end
	-- Use the full drawing order, allowing drops into another window.
	for id, g in minGUI_each_gadget(true) do
		local ox, oy = minGUI_get_parent_gadget_offset(id)
		local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(g.parent,
			g.isInternal and minGUI.gtree[g.parent] and minGUI.gtree[g.parent].tp == MG_SCROLLAREA)
		local x, y = minGUI.mouse.x, minGUI.mouse.y
		if g.tp ~= MG_CONTEXT_MENU and x >= sx and x < sx + sw and y >= sy and y < sy + sh
			and x >= ox + g.x and x < ox + g.x + g.width
			and y >= oy + g.y and y < oy + g.y + g.height then
            local source = minGUI.gadgetDrag and minGUI.gtree[minGUI.gadgetDrag.source]
            if source and source.tp == MG_IMAGE then
                if g.isInternal then return end
                if g.imageDropTarget then return id end
                local parent = id
                while parent do
                    local container = minGUI.gtree[parent]
                    if container.tp == MG_SCROLLAREA or container.tp == MG_PANEL or container.tp == MG_WINDOW then
                        local cx, cy, cw, ch = minGUI_get_gadget_parents_scissor(parent)
                        if x >= cx and x < cx + cw and y >= cy and y < cy + ch then return parent end
                        return
                    end
                    parent = container.parent
                end
                return
            end
			if minGUI_gadget_drag_droppable(g) then
				if g.tp == MG_EDITOR then
					minGUI_editor_layout(g)
					if x < ox + g.x + 2 or x >= ox + g.x + 2 + g.viewWidth
						or y < oy + g.y + 2 or y >= oy + g.y + 2 + g.viewHeight then return end
				end
				return id
			end
			return -- The first hit obscures all lower gadgets.
		end
	end
end

function minGUI_update_gadget_drag()
	local drag = minGUI.gadgetDrag
	if not drag then return false end
	local g = minGUI.gtree[drag.source]
    for _, id in ipairs(drag.sources) do
        if not minGUI_gadget_drag_droppable(minGUI.gtree[id]) then
            minGUI.gadgetDrag = nil
            return drag.active
        end
    end
	if not minGUI_gadget_drag_droppable(g) then
		minGUI.gadgetDrag = nil
		return drag.active
	end
	local dx, dy = minGUI.mouse.x - drag.x, minGUI.mouse.y - drag.y
	if not drag.active and dx * dx + dy * dy >= 25 then
		drag.active = true
		minGUI.lastGadgetClicks = nil
		minGUI.lastStringClick = nil
		if g.tp == MG_STRING then
			g.selectionAnchor, g.cursorx = 0, utf8.len(g.text)
			minGUI_shift_text(g.num, g.text)
		end
		if g.tp == MG_STRING or g.tp == MG_EDITOR then drag.text = g.text end
		minGUI.stringDrag, minGUI.editorDrag = nil, nil
        for _, id in ipairs(drag.sources) do
            local image = minGUI.gtree[id]
            if image and type(image.down) == 'table' then image.down.left = false end
        end
	end
	if drag.active then
		drag.target, drag.position = dropTarget(), nil
		local target = minGUI.gtree[drag.target]
		if target and target.tp == MG_EDITOR and target.editable then
			drag.position = minGUI_editor_mouse_position(target)
		end
	end
	if not minGUI.mouse.mbtn[MG_LEFT_BUTTON] then
		minGUI.gadgetDrag = nil
		if drag.active then
			local target = drag.target
			if target and target ~= drag.source then
				local parent = target
				while parent do
					if minGUI.gtree[parent].tp == MG_WINDOW then
						if minGUI_active_window() ~= parent then minGUI:set_window_on_top(parent) end
						break
					end
					parent = minGUI.gtree[parent].parent
				end
				minGUI.gfocus = target
				table.insert(minGUI.gstack, {eventGadget = target, eventType = MG_EVENT_DRAG_DROPPED, eventSource = drag.source, eventDrop = {text = drag.text, position = drag.position, sources = drag.sources}})
			end
		end
	end
	return drag.active
end

-- Draw above every window so the dragged text follows the pointer.
function minGUI_draw_gadget_drag()
	local drag = minGUI.gadgetDrag
    if not drag or not drag.active then return end
    local source = minGUI.gtree[drag.source]
    if source and source.tp == MG_IMAGE then
        love.graphics.push("all")
        love.graphics.setCanvas()
        love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 0.65)
        local x, y = minGUI.mouse.x + 12, minGUI.mouse.y + 16
        if #drag.sources > 1 then
            love.graphics.setFont(minGUI.font[minGUI.numFont])
            love.graphics.print(tostring(#drag.sources), x + source.width, y)
        end
        love.graphics.draw(source.image, x + 4, y + 4, 0,
            (source.width - 8) / source.image:getWidth(), (source.height - 8) / source.image:getHeight())
        local label = minGUI.gtree[source.dragLabel]
        if label then
            love.graphics.setFont(minGUI.font[minGUI.numFont])
            love.graphics.setColor(label.rpen, label.gpen, label.bpen, 0.8)
            love.graphics.printf(label.text, x + (source.width - label.width) / 2,
                y + source.height + 4, label.width, "center")
        end
        love.graphics.pop()
        return
    end
    if not drag.text then return end
	local font = minGUI.font[minGUI.numFont]
	love.graphics.push("all")
	love.graphics.setCanvas()
	love.graphics.setFont(font)
	local target = minGUI.gtree[drag.target]
	if target and target.tp == MG_EDITOR and drag.position then
		local lines = minGUI_explode(target.text, "\n")
		local position, row = drag.position, 0
		while row < #lines - 1 and position > utf8.len(lines[row + 1]) do
			position = position - utf8.len(lines[row + 1]) - 1
			row = row + 1
		end
		local ox, oy = minGUI_get_parent_gadget_offset(target.num)
		local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(target.parent)
		love.graphics.setScissor(sx, sy, sw, sh)
		love.graphics.intersectScissor(ox + target.x + 2, oy + target.y + 2, target.viewWidth, target.viewHeight)
		love.graphics.setColor(target.rpen, target.gpen, target.bpen, target.apen)
		love.graphics.rectangle("fill", ox + target.x + 2 - target.scrollX
			+ font:getWidth(minGUI_sub_string(lines[row + 1], 1, position)),
			oy + target.y + 2 - target.scrollY + row * font:getHeight(), 1, font:getHeight())
	end
	love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	local width = math.min(font:getWidth(drag.text) + 8, love.graphics.getWidth())
	local height = math.min(#minGUI_explode(drag.text, "\n") * font:getHeight() + 8, love.graphics.getHeight())
	local x = math.max(0, math.min(minGUI.mouse.x + 12, love.graphics.getWidth() - width))
	local y = math.max(0, math.min(minGUI.mouse.y + 16, love.graphics.getHeight() - height))
	love.graphics.setColor(1, 1, 1, 0.9)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.setScissor(x, y, width, height)
	love.graphics.print(drag.text, x + 4, y + 4)
	love.graphics.pop()
end
