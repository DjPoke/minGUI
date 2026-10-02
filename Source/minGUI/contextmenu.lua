-- Context menus use screen coordinates and draw above their owning container.
function minGUI_add_context_menu(items, parent)
	if minGUI.exitProcess then return end
	if type(items) ~= 'table' or #items == 0 or (parent ~= nil and not minGUI.gtree[parent]) then
		minGUI:runtime_error('[add_context_menu]Invalid items or parent'); return
	end
	local labels = {}
	for i, label in ipairs(items) do
		if type(label) ~= 'string' then minGUI:runtime_error('[add_context_menu]Expected string labels'); return end
		labels[i] = label
	end
	local num = minGUI.lastGadgetID + 1
	minGUI.lastGadgetID = num
	minGUI.gtree[num] = {num=num, tp=MG_CONTEXT_MENU, isInternal=true, parent=parent,
		x=0, y=0, width=0, height=0, items=labels, hover=0, can_have_sons=false, can_have_menu=false}
	return num
end

function minGUI_show_context_menu(num, x, y)
	if minGUI.exitProcess then return end
	local menu = minGUI.gtree[num]
	if not menu or menu.tp ~= MG_CONTEXT_MENU or (x ~= nil and type(x) ~= 'number') or (y ~= nil and type(y) ~= 'number') then
		minGUI:runtime_error('[show_context_menu]Invalid menu or position'); return
	end
	local font = minGUI.font[minGUI.numFont]
	local width = 40
	for _, label in ipairs(menu.items) do width = math.max(width, font:getWidth(label) + 16) end
	menu.rowHeight = font:getHeight() + 8
	menu.width, menu.height = math.min(width, love.graphics.getWidth()), menu.rowHeight * #menu.items + 2
	menu.x = math.max(0, math.min(x or minGUI.mouse.x, love.graphics.getWidth() - menu.width))
	menu.y = math.max(0, math.min(y or minGUI.mouse.y, love.graphics.getHeight() - menu.height))
	menu.hover, minGUI.contextMenu = 0, num
	minGUI.gadgetDrag, minGUI.windowDrag, minGUI.stringDrag, minGUI.editorDrag, minGUI.editorScrollCapture = nil, nil, nil, nil, nil
	for _, g in minGUI_each_gadget() do
		if g.tp == MG_INTERNAL_MENU then g.menu.selected, g.menu.hover = 0, 0 end
	end
end

function minGUI_update_context_menu()
	local menu = minGUI.gtree[minGUI.contextMenu]
	minGUI.contextMenuHandled = menu ~= nil
	if not menu then minGUI.contextMenu = nil; return false end
	local x, y = minGUI.mouse.x, minGUI.mouse.y
	local inside = x >= menu.x and x < menu.x + menu.width and y >= menu.y and y < menu.y + menu.height
	local row = math.floor((y - menu.y - 1) / menu.rowHeight) + 1
	menu.hover = inside and row >= 1 and row <= #menu.items and menu.items[row] ~= '-' and row or 0
	if love.keyboard.isDown('escape') then
		minGUI.contextMenu = nil
	elseif minGUI.mouse.mpressed[MG_LEFT_BUTTON] then
		if menu.hover > 0 then
			table.insert(minGUI.cstack, {menu=menu.num, item=menu.hover})
			minGUI.contextMenu = nil
		elseif not inside then minGUI.contextMenu = nil end
	elseif minGUI.mouse.mpressed[MG_RIGHT_BUTTON] and not inside then minGUI.contextMenu = nil end
	return true -- Consume popup clicks, including clicks that dismiss it.
end

function minGUI_draw_context_menu()
	local menu = minGUI.gtree[minGUI.contextMenu]
	if not menu then return end
	love.graphics.push('all')
	love.graphics.setCanvas()
	love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setFont(minGUI.font[minGUI.numFont])
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('fill', menu.x, menu.y, menu.width, menu.height)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle('line', menu.x + 0.5, menu.y + 0.5, menu.width - 1, menu.height - 1)
	for i, label in ipairs(menu.items) do
		local y = menu.y + 1 + (i - 1) * menu.rowHeight
		if label == '-' then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.line(menu.x + 4, y + menu.rowHeight / 2, menu.x + menu.width - 4, y + menu.rowHeight / 2)
		else
			if menu.hover == i then
				love.graphics.setColor(0.15, 0.35, 0.65, 1)
				love.graphics.rectangle('fill', menu.x + 1, y, menu.width - 2, menu.rowHeight)
				love.graphics.setColor(1, 1, 1, 1)
			else love.graphics.setColor(0, 0, 0, 1) end
			love.graphics.print(label, menu.x + 8, y + 4)
		end
	end
	love.graphics.pop()
end
