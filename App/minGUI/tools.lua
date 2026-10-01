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
function minGUI_each_gadget(reverse)
	local index = reverse and (minGUI.lastGadgetID + 1) or 0
	local step = reverse and -1 or 1
	return function()
		index = index + step
		while index >= 1 and index <= minGUI.lastGadgetID do
			local gadget = minGUI.gtree[index]
			if gadget then return index, gadget end
			index = index + step
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
		oy = oy + minGUI:window_titlebar_height(k)

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
		left = math.max(left, x)
		-- A menu occupies its own parent's menu strip, above the content area.
		local menuHeight = includeMenu and 0 or minGUI:window_menu_height(num)
		top = math.max(top, y + minGUI:window_titlebar_height(num) + menuHeight)
		includeMenu = false -- Ancestor menu strips still clip nested windows.
		right = math.min(right, x + parent.width)
		bottom = math.min(bottom, y + parent.height - minGUI:window_footerbar_height(num))
		num = parent.parent
	end
	return left, top, math.max(0, right - left), math.max(0, bottom - top)
end

-- get gagdet absolute coordinates
function minGUI_get_gadget_absolute_coordinates(num)
	local x = 0
	local y = 0

	while minGUI.gtree[num].parent ~= nil do
		num = minGUI.gtree[num].parent

		x = x + minGUI.gtree[num].x
		y = y + minGUI.gtree[num].y + minGUI:window_menu_height(num) + minGUI:window_titlebar_height(num)
	end

	return x, y
end
