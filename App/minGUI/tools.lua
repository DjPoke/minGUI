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

-- shift text left, if needed
function minGUI_shift_text(num, text)
	-- reset offset
	minGUI.gtree[num].offset = 0

	while minGUI.font[minGUI.numFont]:getWidth(text) >= minGUI.gtree[num].width - 6 do
		-- remove 1st utf8 character
		text = minGUI_sub_string(text, 2)
						
		-- shift the text left of one character
		minGUI.gtree[num].offset = minGUI.gtree[num].offset + 1
	end
end

-- utf8 string.sub
function minGUI_sub_string(text, v1, v2)
	if text == nil or text == "" then return "" end
	if v1 == nil then v1 = 1 end
	if v2 == nil then v2 = utf8.len(text) end
	
	-- left utf8 char byte offset
	local byteoffset1 = utf8.offset(text, v1)

	-- right utf8 char byte offset
	local byteoffset2 = -1

	if v2 + 1 <= utf8.len(text) then
		byteoffset2 = utf8.offset(text, v2 + 1) - 1
	end
	
	return string.sub(text, byteoffset1, byteoffset2)
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
	
	local v = tonumber(t)
	
	if v < mn then v = mn end
	if v > mx then v = mx end
	
	t = tostring(v)
	
	return t
end

-- increment text value
function IncTextValue(t)
	if t == "" then t = "0" end
	
	local v = tonumber(t) + 1

	t = tostring(v)	

	return t
end

-- decrement text value
function DecTextValue(t)
	if t == "" then t = "0" end
	
	local v = tonumber(t) - 1

	t = tostring(v)	

	return t
end

-- explode string
function minGUI_explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
	
    local o = {}
	
    while true do
        local pos1, pos2 = str:find(div)
		
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
	
	local s = ""
	
	for i = 1, #t - 1 do
		s = s .. t[i] .. div
	end

	s = s .. t[#t]
	
	return s
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
	while minGUI.gtree[j].parent ~= nil do
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
function minGUI_get_gadget_parents_scissor(num)
	-- parent gadget is nil ?
	if num == nil then
		-- exit with no scissor
		return 0, 0, love.graphics.getWidth(), love.graphics.getHeight()
	else
		-- parent is a window with a menu ?
		local ox = 0
		local oy = 0
		
		local j = num
		while minGUI.gtree[j].parent ~= nil do
			j = minGUI.gtree[j].parent

			-- parent is a window with a menu ?
			ox = ox + minGUI.gtree[j].x
			oy = oy + minGUI.gtree[j].y + minGUI:window_menu_height(j) + minGUI:window_titlebar_height(j)
		end

		-- ajustments
		local tb = minGUI:window_footerbar_height(num)

		if tb > 0 then tb = tb + 1 end

		-- return scissor values
		return ox + minGUI.gtree[num].x, oy + minGUI.gtree[num].y, minGUI.gtree[num].width, minGUI.gtree[num].height - tb
	end
end


-- get internal gadget parents scissor
function minGUI_get_internal_gadget_parents_scissor(num)
	-- parent gadget is nil ?
	if num == nil then
		-- exit with no scissor
		return 0, 0, love.graphics.getWidth(), love.graphics.getHeight()
	else
		local ox = 0
		local oy = 0
		
		j = num
		while minGUI.gtree[j].parent ~= nil do
			j = minGUI.gtree[j].parent

			-- parent is a window with a menu ?
			menu_y = minGUI:window_menu_height(j)
			menu_y = menu_y + minGUI:window_titlebar_height(j)
			
			ox = ox + minGUI.gtree[j].x
			oy = oy + minGUI.gtree[j].y + menu_y
		end
		
		return ox + minGUI.gtree[num].x, oy + minGUI.gtree[num].y, minGUI.gtree[num].width, minGUI.gtree[num].height
	end
end
