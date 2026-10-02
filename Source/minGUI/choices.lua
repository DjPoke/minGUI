local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

function minGUI_add_choice(tp, x, y, width, height, items, flags, parent)
	if minGUI.exitProcess then return end
	if type(items) ~= 'table' or type(width) ~= 'number' or type(height) ~= 'number' or width < 24 or height < 20 then
		minGUI:runtime_error('[choice gadget]Invalid size or items'); return
	end
	local labels = {}
	for i, label in ipairs(items) do
		if type(label) ~= 'string' then minGUI:runtime_error('[choice gadget]Expected string items'); return end
		labels[i] = label
	end
	local num = minGUI:add_panel(x, y, width, height, flags, parent)
	if not num then return end
	local g = minGUI.gtree[num]
	g.tp, g.items, g.value, g.first, g.can_have_sons = tp, labels, #labels > 0 and 1 or 0, 1, false
	g.choiceKeys = {}
	minGUI_choice_layout(g)
	return num
end

function minGUI_choice_select(g, value, notify)
	if type(value) ~= 'number' or value % 1 ~= 0 or value < 0 or value > #g.items then
		minGUI:runtime_error('[choice gadget]Invalid selection index'); return
	end
	local changed = g.value ~= value
	g.value = value
	local _,_,_,_,_,rows = minGUI_choice_geometry(g, g.tp == MG_COMBO_BOX)
	if value > 0 then g.first = clamp(g.first, math.max(1, value - rows + 1), value) end
	g.scrollY = g.first-1
	minGUI_choice_layout(g)
	if changed and notify then table.insert(minGUI.gstack, {eventGadget=g.num, eventType=MG_EVENT_SELECTION_CHANGED}) end
end

function minGUI_choice_geometry(g, popup)
	local row = minGUI.font[minGUI.numFont]:getHeight() + 8
	local ox, oy = minGUI_get_parent_gadget_offset(g.num)
	local x, y, h = ox + g.x, oy + g.y, g.height
	if popup then
		h = math.min(math.max(1, #g.items), 8) * row + 2
		h = math.min(h, love.graphics.getHeight())
		y = y + g.height
		if y + h > love.graphics.getHeight() then y = oy + g.y - h end
		y = math.max(0, y)
		x = clamp(x, 0, math.max(0, love.graphics.getWidth() - g.width))
	end
	return x, y, g.width, h, row, math.max(1, math.floor((h - 2) / row))
end

local function selectAt(g, popup)
	local x, y, w, h, row, rows = minGUI_choice_geometry(g, popup)
	local mx, my = minGUI.mouse.x, minGUI.mouse.y
	if mx < x or mx >= x+w or my < y or my >= y+h then return false end
	local bar = minGUI.gtree[g.scrollbarID]
	if bar and mx >= x + bar.x then return true end
	local index = g.first + math.floor((my-y-1)/row)
	if index >= g.first and index < g.first+rows and index <= #g.items then
		minGUI_choice_select(g, index, true)
		if popup then minGUI.comboPopup = nil end
	end
	return true
end

function minGUI_choice_pressed(g)
	minGUI.gfocus = g.num
	minGUI.stringDrag, minGUI.editorDrag = nil, nil
	if g.tp == MG_COMBO_BOX then
		minGUI.comboPopup = minGUI.comboPopup ~= g.num and g.num or nil
	else selectAt(g, false) end
end

function minGUI_update_choices()
	local popup = minGUI.gtree[minGUI.comboPopup]
	local scrollHandled = minGUI_update_editor_scrollbars(true)
	local handled = popup ~= nil or scrollHandled
	if popup then
		if love.keyboard.isDown('escape') then minGUI.comboPopup = nil
		elseif not scrollHandled and minGUI.mouse.mpressed[MG_LEFT_BUTTON] then
			if not selectAt(popup, true) then minGUI.comboPopup = nil end
		elseif minGUI.mouse.mpressed[MG_RIGHT_BUTTON] then minGUI.comboPopup = nil end
	else minGUI.comboPopup = nil end
	local g = minGUI.gtree[minGUI.gfocus]
	if g and (g.tp == MG_LIST or g.tp == MG_COMBO_BOX) then
		for _, key in ipairs({'up','down','home','end','return'}) do
			if not love.keyboard.isDown(key) then g.choiceKeys[key] = nil
			elseif not g.choiceKeys[key] or minGUI.timer >= g.choiceKeys[key] then
				if key == 'return' and g.tp == MG_COMBO_BOX then minGUI.comboPopup = nil
				elseif #g.items > 0 and key ~= 'return' then
					local value = key == 'home' and 1 or key == 'end' and #g.items or g.value + (key == 'up' and -1 or 1)
					minGUI_choice_select(g, clamp(value,1,#g.items), true)
				end
				g.choiceKeys[key] = minGUI.timer + (g.choiceKeys[key] and MG_QUICK_DELAY or MG_SLOW_DELAY)
			end
		end
	end
	minGUI.choicePopupHandled = handled
	return handled
end

function minGUI_draw_choice(g, popup)
	local x,y,w,h,row,rows = minGUI_choice_geometry(g,popup)
	love.graphics.push('all')
	love.graphics.setCanvas()
	if popup then love.graphics.setScissor(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	else
		local sx,sy,sw,sh = minGUI_get_gadget_parents_scissor(g.parent)
		love.graphics.setScissor(sx,sy,sw,sh)
	end
	love.graphics.intersectScissor(x,y,w,h)
	love.graphics.setFont(minGUI.font[minGUI.numFont])
	love.graphics.setColor(1,1,1,1);love.graphics.rectangle('fill',x,y,w,h)
	local list = popup or g.tp == MG_LIST
	local scroll = list and minGUI.gtree[g.scrollbarID] ~= nil
	if list then
		for i=g.first,math.min(#g.items,g.first+rows-1) do
			local yy = y+1+(i-g.first)*row
			if i == g.value then
				love.graphics.setColor(0.15,0.35,0.65,1);love.graphics.rectangle('fill',x+1,yy,w-(scroll and minGUI.gtree[g.scrollbarID].size + 2 or 2),row)
				love.graphics.setColor(1,1,1,1)
			else love.graphics.setColor(0,0,0,1) end
			love.graphics.print(g.items[i],x+4,yy+4)
		end
	else love.graphics.setColor(0,0,0,1);love.graphics.print(g.items[g.value] or '',x+4,y+(h-minGUI.font[minGUI.numFont]:getHeight())/2) end
	love.graphics.setColor(0,0,0,1);love.graphics.setLineWidth(minGUI.gfocus==g.num and 2 or 1)
	love.graphics.rectangle('line',x+1,y+1,w-2,h-2)
	if not list then
		love.graphics.setColor(0.85,0.85,0.85,1);love.graphics.rectangle('fill',x+w-20,y+1,19,h-2)
		love.graphics.setColor(0,0,0,1)
		local cx, cy = x + w - 10, y + h / 2
		love.graphics.polygon('fill', cx - 5, cy - 3, cx + 5, cy - 3, cx, cy + 3)
	end
	love.graphics.pop()
	if scroll then
		local bar = minGUI.gtree[g.scrollbarID]
		minGUI_draw_internal_gadget(bar.num, x, y, true)
	end
end

function minGUI_draw_combo_popup()
	local g = minGUI.gtree[minGUI.comboPopup]
	if g then minGUI_draw_choice(g,true) end
end

-- Use the same internal scrollbars and proportional thumbs as other containers.
function minGUI_choice_layout(g)
	local _,_,w,h,_,rows = minGUI_choice_geometry(g, g.tp == MG_COMBO_BOX)
	g.viewHeight, g.maxScrollY = rows, math.max(0, #g.items - rows)
	g.first = clamp(math.floor(g.scrollY and g.scrollY + 1 or g.first),1,g.maxScrollY+1)
	g.scrollY = g.first - 1
	local bar = minGUI.gtree[g.scrollbarID]
	local size = math.max(1, math.min(MG_SCROLLBAR_SIZE, math.floor((h-2)/3)))
	if bar and (g.maxScrollY==0 or bar.height~=h-2 or bar.size~=size) then
		minGUI:delete_gadget(bar.num);g.scrollbarID=nil;bar=nil
	end
	if g.maxScrollY==0 then return end
	if not bar then
		minGUI:add_internal_scrollbar(w-size-1,1,size,h-2,0,0,g.maxScrollY,1,MG_FLAG_SCROLLBAR_VERTICAL,g.num)
		g.scrollbarID = minGUI.lastGadgetID
		bar = minGUI.gtree[g.scrollbarID]
		bar.choiceScroll = true
	end
	bar.x = w-size-1
	bar.maxValue, bar.value, bar.inc = g.maxScrollY, g.scrollY, 1
	local thumb = math.min(bar.internalBarSize, math.max(MG_MIN_SCROLLBAR_BUTTON_SIZE, math.floor(bar.internalBarSize*rows/#g.items)))
	bar.thumbTravel = bar.internalBarSize-thumb
	bar.thumbOffset = bar.value/bar.maxValue*bar.thumbTravel
	bar.size_width,bar.size_height = size,thumb
	if bar.canvas3:getWidth()~=size or bar.canvas3:getHeight()~=thumb then bar.canvas3=love.graphics.newCanvas(size,thumb) end
end

function minGUI_choice_scrollbar_offset(g)
	local x,y = minGUI_choice_geometry(g,g.tp==MG_COMBO_BOX)
	return x,y
end
