-- check for a parameter
function minGUI_check_param(v, t)
	if v == nil or type(v) ~= t then return false else return true end
end

-- check a parameter (accepts nill)
function minGUI_check_param2(v, t)
	if v == nil then
		return true
	elseif type(v) ~= t then
		return false
	end
	
	return true
end

-- Iterate live gadgets in creation order, preserving IDs after deletion.
function minGUI_root_gadget(num)
    local gadget = minGUI.gtree[num]
    while gadget and gadget.parent do
        num = gadget.parent
        gadget = minGUI.gtree[num]
    end
    return num
end

-- Drawing and pointer traversal share the same stacking order. IDs never move.
function minGUI_each_gadget(reverse)
    local ids = {}
    local paths = {}
    for id in pairs(minGUI.gtree) do
        ids[#ids + 1] = id
        local path, current = {}, id
        while current and minGUI.gtree[current] do
            table.insert(path, 1, current)
            current = minGUI.gtree[current].parent
        end
        paths[id] = path
    end
    table.sort(ids, function(a, b)
        local pa, pb = paths[a], paths[b]
        for i = 1, math.min(#pa, #pb) do
            if pa[i] ~= pb[i] then
                local ga, gb = minGUI.gtree[pa[i]], minGUI.gtree[pb[i]]
                -- Priority windows stay above ordinary siblings, with all their children.
                local priorityA = ga.tp == MG_WINDOW and minGUI_flag_active(ga.flags or 0, MG_FLAG_WINDOW_TOP_PRIORITY)
                local priorityB = gb.tp == MG_WINDOW and minGUI_flag_active(gb.flags or 0, MG_FLAG_WINDOW_TOP_PRIORITY)
                if priorityA ~= priorityB then return not priorityA end
                local za = ga.zOrder or pa[i]
                local zb = gb.zOrder or pb[i]
                if za ~= zb then return za < zb end
                return pa[i] < pb[i]
            end
        end
        return #pa < #pb
    end)
    local index = reverse and (#ids + 1) or 0
    local step = reverse and -1 or 1
    return function()
        index = index + step
        while ids[index] do
            local id = ids[index]
            if minGUI.gtree[id] then return id, minGUI.gtree[id] end
            index = index + step
        end
    end
end

function minGUI_active_window()
    if minGUI.gtree[minGUI.activeWindow] then return minGUI.activeWindow end
    for id, gadget in minGUI_each_gadget(true) do
        if gadget.tp == MG_WINDOW then return id end
    end
end

function minGUI_each_interactive_gadget(reverse)
    local iterator = minGUI_each_gadget(reverse)
    local active = minGUI_active_window()
    return function()
        while true do
            local id, gadget = iterator()
            if not id then return end
            local root = minGUI_root_gadget(id)
            if minGUI.gtree[root].tp ~= MG_WINDOW or root == minGUI_root_gadget(active) then
                return id, gadget
            end
        end
    end
end

function minGUI_activate_window_at_pointer()
    local active = minGUI_active_window()
    -- An open menu popup can extend beyond its owning window.
    for _, menu in minGUI_each_interactive_gadget() do
        if menu.tp == MG_INTERNAL_MENU and menu.menu.selected > 0 then
            local x, y, width, height = minGUI_menu_popup_geometry(menu)
            if minGUI.mouse.x >= x and minGUI.mouse.x < x + width
                and minGUI.mouse.y >= y and minGUI.mouse.y < y + height then return end
        end
    end
    for id, window in minGUI_each_gadget(true) do
        if window.tp == MG_WINDOW then
            local ox, oy = minGUI_get_parent_gadget_offset(id)
            local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(window.parent)
            local x, y = minGUI.mouse.x, minGUI.mouse.y
            if x >= ox + window.x and x < ox + window.x + window.width
                and y >= oy + window.y and y < oy + window.y + window.height
                and x >= sx and x < sx + sw and y >= sy and y < sy + sh then
                -- Launcher images act on another window without activating the desktop.
                for childID, child in minGUI_each_gadget(true) do
                    if child.parent == id and child.preserveWindowFocus then
                        local cx, cy = minGUI_get_parent_gadget_offset(childID)
                        local clipX, clipY, clipW, clipH = minGUI_get_gadget_parents_scissor(id)
                        if x >= cx + child.x and x < cx + child.x + child.width
                            and y >= cy + child.y and y < cy + child.y + child.height
                            and x >= clipX and x < clipX + clipW and y >= clipY and y < clipY + clipH then
                            return id
                        end
                    end
                end
                if active ~= id then
                    minGUI:set_window_on_top(id)
                end
                return id
            end
        end
    end
end

-- Shift a single-line value until its visible suffix fits the gadget.
function minGUI_shift_text(num, text)
	local gadget = minGUI.gtree[num]
	if gadget.tp == MG_STRING then
		local length = utf8.len(text)
		gadget.cursorx = math.max(0, math.min(gadget.cursorx or length, length))
		gadget.offset = math.max(0, math.min(gadget.offset or 0, gadget.cursorx))
		local font = minGUI.font[minGUI.numFont]
		local available = math.max(0, gadget.width - 6 - font:getWidth("|"))
		while gadget.offset < gadget.cursorx
			and font:getWidth(minGUI_sub_string(text, gadget.offset + 1, gadget.cursorx)) > available do
			gadget.offset = gadget.offset + 1
		end
		-- Reveal preceding characters again when deleting or moving left.
		while gadget.offset > 0
			and font:getWidth(minGUI_sub_string(text, gadget.offset, gadget.cursorx)) <= available do
			gadget.offset = gadget.offset - 1
		end
		return
	end
	gadget.offset = 0
	while text ~= "" and minGUI.font[minGUI.numFont]:getWidth(text) >= gadget.width - 6 do
		text = minGUI_sub_string(text, 2)
		gadget.offset = gadget.offset + 1
	end
end

-- string.sub semantics, with character indices instead of byte indices.
function minGUI_sub_string(text, first, last)
	if text == nil or text == "" then return "" end
	local length = assert(utf8.len(text), "invalid UTF-8 text")
	first = first or 1
	last = last or length
	if first < 0 then first = length + first + 1 end
	if last < 0 then last = length + last + 1 end
	first = math.max(first, 1)
	last = math.min(last, length)
	if first > last then return "" end
	return text:sub(utf8.offset(text, first), utf8.offset(text, last + 1) - 1)
end

-- check if a file exists
function minGUI_get_file_exists(path)
	local info = love.filesystem.getInfo(path)
	
	if info ~= nil and info.type == "file" and info.size > 0 then
		return true
	end
	
	return false
end

-- check if a folder exists
function minGUI_get_folder_exists(path)
	local info = love.filesystem.getInfo(path)
	
	if info ~= nil and info.type == "directory" then
		return true
	end
	
	return false
end

-- frame a text value between min and max values
function frameTextValue(t, mn, mx)
	if t == "" then t = "0" end
	
	local v = tonumber(t) or 0
	
	if v < mn then v = mn end
	if v > mx then v = mx end
	
	t = tostring(v)
	
	return t
end

-- increment text value
function IncTextValue(t)
	if t == "" then t = "0" end
	
	local v = (tonumber(t) or 0) + 1

	t = tostring(v)	

	return t
end

-- decrement text value
function DecTextValue(t)
	if t == "" then t = "0" end
	
	local v = (tonumber(t) or 0) - 1

	t = tostring(v)	

	return t
end

-- explode string
function minGUI_explode(str, div)
	assert(type(str) == "string" and type(div) == "string", "invalid arguments")
	
	assert(div ~= "", "separator must not be empty")
	local o = {}
	
	while true do
		local pos1, pos2 = str:find(div, 1, true)
		
		if not pos1 then
			o[#o + 1] = str
			
			break
		end
		
		o[#o + 1], str = str:sub(1, pos1 - 1), str:sub(pos2 + 1)
	end
	
	return o
end

-- assemble exploded string
function minGUI_assemble(t, div)
	if t == nil then return "" end
	if div == nil then return "" end
	
	return table.concat(t, div)
end

-- check if a flag is set in some flags
function minGUI_flag_active(flags, flag)
	return bit.band(flags, flag) == flag
end

-- Reserve the top frame even when a window has no title bar.
function minGUI_window_top_inset(num)
    local parent = minGUI.gtree[num]
    local border = parent and parent.tp == MG_WINDOW and MG_WINDOW_BORDER_WIDTH or 0
    return math.max(border, minGUI:window_titlebar_height(num))
end

-- get the offset for the gadget
function minGUI_get_parent_gadget_offset(num)
	-- calculate parents offset
	local ox = 0
	local oy = 0

	--
	local j = num
	
	-- while gadget 'j' has a parent
	while minGUI.gtree[j] and minGUI.gtree[j].parent ~= nil do
		-- 'k' = parent number
		local k = minGUI.gtree[j].parent

		-- add gadget offsets
		ox = ox + minGUI.gtree[k].x
		oy = oy + minGUI.gtree[k].y
		oy = oy + minGUI:window_menu_height(k)
		oy = oy + minGUI_window_top_inset(k)
		if minGUI.gtree[k].tp == MG_SCROLLAREA then
			local child = minGUI.gtree[j]
			if not child.isInternal then
				ox = ox - minGUI.gtree[k].scrollX
				oy = oy - minGUI.gtree[k].scrollY
			end
		end

		--
		j = k
	end

	return ox, oy
end

-- get gadget parents scissor
function minGUI_get_gadget_parents_scissor(num, includeMenu)
	local left, top = 0, 0
	local right, bottom = love.graphics.getWidth(), love.graphics.getHeight()
	while num ~= nil do
		local parent = minGUI.gtree[num]
		if not parent then break end
		local ox, oy = minGUI_get_parent_gadget_offset(num)
		local x, y = ox + parent.x, oy + parent.y
		-- Menu strips and content both stay inside the window's side borders.
		local fullScrollarea = includeMenu and parent.tp == MG_SCROLLAREA
		local border = parent.tp == MG_WINDOW and MG_WINDOW_BORDER_WIDTH or 0
		left = math.max(left, x + border)
		-- A menu occupies its own parent's menu strip, above the content area.
		local menuHeight = includeMenu and 0 or minGUI:window_menu_height(num)
		top = math.max(top, y + math.max(border, minGUI_window_top_inset(num) + menuHeight))
		includeMenu = false -- Ancestor menu strips still clip nested windows.
		right = math.min(right, x + ((parent.tp == MG_SCROLLAREA and not fullScrollarea) and parent.viewWidth or parent.width) - border)
		bottom = math.min(bottom, y + ((parent.tp == MG_SCROLLAREA and not fullScrollarea) and parent.viewHeight or parent.height) - math.max(border, minGUI:window_footerbar_height(num)))
		num = parent.parent
	end
	return left, top, math.max(0, right - left), math.max(0, bottom - top)
end

-- get gagdet absolute coordinates
function minGUI_get_gadget_absolute_coordinates(num)
	return minGUI_get_parent_gadget_offset(num)
end

-- Keep window menus stretched between their original left and right margins.
function minGUI_resize_window_menus(num)
    local window = minGUI.gtree[num]
    for _, menu in minGUI_each_gadget() do
        if menu.tp == MG_INTERNAL_MENU and menu.parent == num then
            local border = window.tp == MG_WINDOW and MG_WINDOW_BORDER_WIDTH or 0
            menu.x = math.max(border, menu.x)
            menu.rightMargin = math.max(border, menu.rightMargin or menu.x)
            local width = math.max(1, window.width - menu.x - menu.rightMargin)
            if menu.width ~= width then
                menu.width = width
                menu.canvas = love.graphics.newCanvas(width, menu.height)
            end
        end
    end
end

-- Geometry shared by popup rendering and pointer selection.
function minGUI_menu_popup_geometry(w)
    local font = minGUI.font[minGUI.numFont]
    local ox, oy = minGUI:get_parent_internal_gadget_offset(w.num, w.tp)
    local x, width = ox + w.x, 1
    for i = 1, w.menu.selected - 1 do
        x = x + font:getWidth(" " .. w.array[i].head_menu .. " ")
    end
    local items = w.array[w.menu.selected].menu_list
    for _, label in ipairs(items) do
        width = math.max(width, font:getWidth(" " .. label .. " "))
    end
    local rowHeight = math.max(w.height, font:getHeight()) + 2
    local height = rowHeight * #items + 2
    x = math.max(0, math.min(x, love.graphics.getWidth() - width))
    local y = math.max(0, math.min(oy + w.y + w.height, love.graphics.getHeight() - height))
    return x, y, width, height, rowHeight
end

function minGUI_menu_hit(w)
    local mx, my = minGUI.mouse.x, minGUI.mouse.y
    local ox, oy = minGUI:get_parent_internal_gadget_offset(w.num, w.tp)
    local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(w.parent, true)
    if mx >= sx and mx < sx + sw and my >= sy and my < sy + sh
        and mx >= ox + w.x and mx < ox + w.x + w.width
        and my >= oy + w.y and my < oy + w.y + w.height then
        local x = ox + w.x
        for i, entry in ipairs(w.array) do
            local width = minGUI.font[minGUI.numFont]:getWidth(" " .. entry.head_menu .. " ")
            if mx >= x and mx < x + width then return i, nil, true end
            x = x + width
        end
        return nil, nil, true
    end
    if w.menu.selected > 0 then
        local x, y, width, height, rowHeight = minGUI_menu_popup_geometry(w)
        if mx >= math.max(0, x) and mx < math.min(love.graphics.getWidth(), x + width)
            and my >= y and my < math.min(love.graphics.getHeight(), y + height) then
            local row = math.floor((my - y - 1) / rowHeight) + 1
            local items = w.array[w.menu.selected].menu_list
            if row >= 1 and row <= #items and items[row] ~= "-" then return nil, row, true end
            return nil, nil, true
        end
    end
    return nil, nil, false
end
