local stringKeys = {"left", "right", "backspace", "delete", "home", "end", "insert", "a", "c", "x", "v"}
local function shiftDown()
	return love.keyboard.isDown("lshift", "rshift")
end
local function shortcutDown()
	return love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui")
end

-- Selection bounds are UTF-8 character positions between characters.
function minGUI_string_selection(gadget)
	local anchor = gadget.selectionAnchor or gadget.cursorx
	return math.min(anchor, gadget.cursorx), math.max(anchor, gadget.cursorx)
end

function minGUI_string_replace(gadget, text)
	text = text:gsub("[\r\n]", "")
	if text == "" then return end
	minGUI_shift_text(gadget.num, gadget.text)
	local first, last = minGUI_string_selection(gadget)
	if first == last and gadget.overwrite then last = last + utf8.len(text) end
	gadget.text = minGUI_sub_string(gadget.text, 1, first)
		.. text .. minGUI_sub_string(gadget.text, last + 1)
	gadget.cursorx = first + utf8.len(text)
	gadget.selectionAnchor = nil
	minGUI_shift_text(gadget.num, gadget.text)
end

local function deleteSelection(gadget)
	local first, last = minGUI_string_selection(gadget)
	if first == last then return false end
	gadget.text = minGUI_sub_string(gadget.text, 1, first)
		.. minGUI_sub_string(gadget.text, last + 1)
	gadget.cursorx = first
	gadget.selectionAnchor = nil
	return true
end

-- Map a mouse X to the nearest character boundary in the visible text.
local function mouseCursor(gadget)
	local ox = minGUI_get_parent_gadget_offset(gadget.num)
	local x = minGUI.mouse.x - ox - gadget.x - 2
	local font = minGUI.font[minGUI.numFont]
	local previous = 0
	for cursor = gadget.offset + 1, utf8.len(gadget.text) do
		local width = font:getWidth(minGUI_sub_string(gadget.text, gadget.offset + 1, cursor))
		if x < (previous + width) / 2 then return cursor - 1 end
		previous = width
	end
	return utf8.len(gadget.text)
end

function minGUI_string_mouse_pressed(gadget)
	if shiftDown() then
		gadget.selectionAnchor = gadget.selectionAnchor or gadget.cursorx
	else
		gadget.selectionAnchor = mouseCursor(gadget)
	end
	gadget.cursorx = mouseCursor(gadget)
	minGUI.stringDrag = gadget.num
	minGUI_shift_text(gadget.num, gadget.text)
end

function minGUI_update_string_keyboard()
	local gadget = minGUI.gtree[minGUI.gfocus]
	if not gadget or gadget.tp ~= MG_STRING then
		minGUI.stringKeyboardFocus = nil
		minGUI.stringDrag = nil
		return
	end
	if minGUI.stringKeyboardFocus ~= gadget.num then
		gadget.keyrepeat = {}
		minGUI.stringKeyboardFocus = gadget.num
	end
	if minGUI.stringDrag == gadget.num then
		if minGUI.mouse.mbtn[MG_LEFT_BUTTON] then
			local ox = minGUI_get_parent_gadget_offset(gadget.num)
			local x = minGUI.mouse.x - ox - gadget.x - 2
			if x < 0 then
				gadget.cursorx = math.max(0, gadget.offset - 1)
			elseif x > gadget.width - 4 then
				gadget.cursorx = math.min(utf8.len(gadget.text), gadget.cursorx + 1)
			else
				gadget.cursorx = mouseCursor(gadget)
			end
			minGUI_shift_text(gadget.num, gadget.text)
		else
			minGUI.stringDrag = nil
		end
	end
	minGUI_shift_text(gadget.num, gadget.text)
	local shortcut = shortcutDown()
	for _, key in ipairs(stringKeys) do
		local state = gadget.keyrepeat[key]
		local command = key == "a" or key == "c" or key == "x" or key == "v"
		local active = love.keyboard.isDown(key) and (not command or shortcut)
		if not active then
			gadget.keyrepeat[key] = nil
		elseif state == nil or (key ~= "insert" and not command and minGUI.timer >= state.nextTime) then
			local first, last = minGUI_string_selection(gadget)
			local cursor = gadget.cursorx
			local length = utf8.len(gadget.text)
			if command then
				if key == "a" then
					gadget.selectionAnchor, gadget.cursorx = 0, length
				elseif key == "c" or key == "x" then
					if first ~= last then
						love.system.setClipboardText(minGUI_sub_string(gadget.text, first + 1, last))
						if key == "x" and gadget.editable then deleteSelection(gadget) end
					end
				elseif key == "v" and gadget.editable then
					minGUI_string_replace(gadget, love.system.getClipboardText())
				end
			elseif key == "left" or key == "right" or key == "home" or key == "end" then
				local selecting = shiftDown()
				if selecting then gadget.selectionAnchor = gadget.selectionAnchor or cursor end
				if key == "home" then gadget.cursorx = 0
				elseif key == "end" then gadget.cursorx = length
				elseif first ~= last and not selecting then
					gadget.cursorx = key == "left" and first or last
				else
					gadget.cursorx = math.max(0, math.min(length, cursor + (key == "left" and -1 or 1)))
				end
				if not selecting then gadget.selectionAnchor = nil end
			elseif gadget.editable then
				if key == "insert" then
					gadget.overwrite = not gadget.overwrite
				elseif key == "backspace" or key == "delete" then
					if not deleteSelection(gadget) then
						if key == "backspace" and cursor > 0 then
							gadget.selectionAnchor = cursor - 1
						elseif key == "delete" and cursor < length then
							gadget.selectionAnchor = cursor + 1
						end
						deleteSelection(gadget)
					end
				end
			end
			gadget.keyrepeat[key] = {nextTime = minGUI.timer + (state and MG_QUICK_DELAY or MG_SLOW_DELAY)}
			minGUI_shift_text(gadget.num, gadget.text)
		end
	end
end

-- minGUI events loop, must be call by love.update
function minGUI_update_events(dt)
	--=====================================================================
	-- timer events
	--=====================================================================
	
	-- increment base timer
	minGUI.timer = minGUI.timer + dt

	-- scan for ptimers
	for i, v in pairs(minGUI.ptimer) do
		-- a timer should send an event...
		if math.floor(minGUI.timer * 1000) - v.timer >= v.delay then
			-- send the good event
			table.insert(minGUI.tstack, {eventTimer = i, eventType = MG_EVENT_TIMER_TICK})
			
			-- Keep the original cadence; coalesce missed ticks into one event.
			local elapsed = math.floor(minGUI.timer * 1000) - v.timer
			local periods = math.floor(elapsed / v.delay)
			v.timer = v.timer + periods * v.delay
		end
	end

	--=====================================================================
	-- mouse events
	--=====================================================================
	
	-- get mouse position
	minGUI.mouse.x, minGUI.mouse.y = love.mouse.getPosition()
	
	-- check for mouse down
	for i = 1, 3 do
		minGUI.mouse.oldmbtn[i] = minGUI.mouse.mbtn[i]
		minGUI.mouse.mbtn[i] = love.mouse.isDown(i)
		
		-- the user has pressed or released a mouse button ?
		minGUI.mouse.mpressed[i] = false
		minGUI.mouse.mreleased[i] = false
		
		if minGUI.mouse.oldmbtn[i] == false and minGUI.mouse.mbtn[i] == true then
			-- button pressed
			minGUI.mouse.mpressed[i] = true
		elseif minGUI.mouse.oldmbtn[i] == true and minGUI.mouse.mbtn[i] == false then
			-- button released
			minGUI.mouse.mreleased[i] = true
		end
	end

	-- flag used to check if a gadget is still focused
	getfocusFlag = false
	
	local editorScrollHandled = minGUI_update_editor_scrollbars()

	-- click loops
	for b = 1, 3 do
		-- click on a gadget ?
		selected_gadget = nil
		
		if next(minGUI.gtree) ~= nil and not (b == MG_LEFT_BUTTON and editorScrollHandled) then
			-- button pressed
			if minGUI.mouse.mpressed[b] == true then
				selected_gadget = minGUI_check_gadget_clicked(b, false, nil)
			end
		
			-- button continue to be down on a gadget ?
			if minGUI.mouse.mbtn[b] == true and not (b == MG_LEFT_BUTTON and (minGUI.stringDrag or minGUI.editorDrag)) then
				selected_gadget = minGUI_check_gadget_mousedown(b, false, nil)
			end

			-- release button on a gadget ?
			if minGUI.mouse.mreleased[b] == true then
				selected_gadget = minGUI_check_gadget_released(b, false, nil)
			end

			-- button continue to be up ?
			if minGUI.mouse.mbtn[b] == false then
				minGUI_check_internal_gadget_mouseup(b)
			end
		end
	end

	--=====================================================================
	-- keyboard events
	--=====================================================================
		
	minGUI_update_string_keyboard()
	minGUI_update_editor_keyboard()

	-- if a gadget has the focus...
	if minGUI.gfocus ~= nil then
		-- if the gadget exists
		if minGUI.gtree[minGUI.gfocus] ~= nil then
			-- Strings are handled by minGUI_update_string_keyboard above.
			if minGUI.gtree[minGUI.gfocus].tp == MG_SPIN then
				-- if backspace has not yet been pressed...
				if minGUI.gtree[minGUI.gfocus].backspace == 0 then
					-- if backspace is pressed now...
					if love.keyboard.isDown("backspace") == true then
						-- remove the last UTF-8 character.
						local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

						if byteoffset then
							minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							
							if minGUI.gtree[minGUI.gfocus].text == "" then minGUI.gtree[minGUI.gfocus].text = "" end
							if minGUI.gtree[minGUI.gfocus].text ~= "" then minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue) end
						end

						-- calculate the new offset value for the text
						minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)

						-- count the first backspace, and get the timer
						minGUI.gtree[minGUI.gfocus].backspace = 1
						minGUI.kbdelay = minGUI.timer
					end
					
				-- if backspace has been pressed...
				elseif minGUI.gtree[minGUI.gfocus].backspace > 0 then
					-- if backspace is released now...
					if love.keyboard.isDown("backspace") == false then
						minGUI.gtree[minGUI.gfocus].backspace = 0
					else
						-- if backspace is still pressed, and has been pressed only one time
						if minGUI.gtree[minGUI.gfocus].backspace == 1 then
							-- wait for keyboard slow delay
							if minGUI.timer - minGUI.kbdelay >= MG_SLOW_DELAY then
								-- remove the last UTF-8 character.
								local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

								if byteoffset then
									minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							
									if minGUI.gtree[minGUI.gfocus].text == "" then minGUI.gtree[minGUI.gfocus].text = "" end
									if minGUI.gtree[minGUI.gfocus].text ~= "" then minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue) end
								end

								-- calculate the new offset value for the text
								minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
									
								-- reset kbdelay and increment backspace
								minGUI.kbdelay = minGUI.timer
								minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
							end
						-- if backspace is still pressed, and has been pressed for multiple times
						elseif minGUI.gtree[minGUI.gfocus].backspace > 1 then
							-- wait for keyboard quick delay
							if minGUI.timer - minGUI.kbdelay >= MG_QUICK_DELAY then
								-- remove the last UTF-8 character.
								local byteoffset = utf8.offset(minGUI.gtree[minGUI.gfocus].text, -1)

								if byteoffset then
									minGUI.gtree[minGUI.gfocus].text = string.sub(minGUI.gtree[minGUI.gfocus].text, 1, byteoffset - 1)
							
									if minGUI.gtree[minGUI.gfocus].text == "" then minGUI.gtree[minGUI.gfocus].text = "" end
									if minGUI.gtree[minGUI.gfocus].text ~= "" then minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue) end
								end

								-- calculate the new offset value for the text
								minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
									
								-- reset kbdelay and increment backspace
								minGUI.kbdelay = minGUI.timer
								minGUI.gtree[minGUI.gfocus].backspace = minGUI.gtree[minGUI.gfocus].backspace + 1
							end
						end
					end
				end
			end
		end
	end
end

-- function to input text, and
-- write it  in a gadget
function minGUI_textinput(c)
	-- if a gadget has the focus...
	if minGUI.gfocus ~= nil then
		-- if the gadget exists
		if minGUI.gtree[minGUI.gfocus] ~= nil then
			-- if it is a string gadget...
			if minGUI.gtree[minGUI.gfocus].tp == MG_STRING then
				-- if the gadget is editable...
				if minGUI.gtree[minGUI.gfocus].editable == true then
					if not shortcutDown() then
						minGUI_string_replace(minGUI.gtree[minGUI.gfocus], c)
					end
				end
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_SPIN then
				if c:match("^%d+$") then
					-- add last character to the text
					minGUI.gtree[minGUI.gfocus].text = frameTextValue(minGUI.gtree[minGUI.gfocus].text .. c, minGUI.gtree[minGUI.gfocus].minValue, minGUI.gtree[minGUI.gfocus].maxValue)
						
					-- calculate the new offset value for the text
					minGUI_shift_text(minGUI.gfocus, minGUI.gtree[minGUI.gfocus].text)
				end
			elseif minGUI.gtree[minGUI.gfocus].tp == MG_EDITOR then
				local gadget = minGUI.gtree[minGUI.gfocus]
				if gadget.editable and not shortcutDown() then minGUI_editor_replace(gadget, c) end
			end
		end
	end
end

-- check if an internal gadget is clicked
function minGUI_check_internal_gadget_clicked(b)
	-- check for internal gadgets first
	for i, v in minGUI_each_gadget() do
		-- calculate parents offset
		local ox, oy = minGUI:get_parent_internal_gadget_offset(i, v.tp)
		
		if v.tp == MG_INTERNAL_MENU then
			if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
				if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
					if b == MG_LEFT_BUTTON then
						if v.menu.selected == 0 then
							v.down.left = true
							
							-- clicking on a menu to open it
							x = 0
							
							for i = 1, #v.array do
								menu_width = minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[i].head_menu .. " ")
								
								if minGUI.mouse.x >= ox + v.x + x and minGUI.mouse.x < ox + v.x + x + menu_width then
									v.menu.selected = i
									
									return v.num
								end
								
								x = x + menu_width
							end
						else
							v.down.left = true
						
							-- clicking on a menu to close it
							x = 0
							
							for i = 1, #v.array do
								menu_width = minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[i].head_menu .. " ")
								
								if minGUI.mouse.x >= ox + v.x + x and minGUI.mouse.x < ox + v.x + x + menu_width then
									if v.menu.selected == i then
										v.menu.selected = 0
										v.menu.hover = 0
										
										return v.num
									end
								end
								
								x = x + menu_width
							end
						end
					end
				end
			end
							
			-- mouseclick on a submenu ?
			if b == MG_LEFT_BUTTON then
				if v.menu.selected > 0 then
					-- find menu x
					x = 0

					for i = 1, v.menu.selected - 1 do
						x = x + minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[i].head_menu .. " ")
					end
				
					w = minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[v.menu.selected].head_menu .. " ")
					h = minGUI.font[minGUI.numFont]:getHeight() + 2
				
					-- find mouseclick submenu y
					y = v.height + 2
				
					for i = 1, #v.array[v.menu.selected].menu_list do
						if minGUI.mouse.x >= ox + v.x + x and minGUI.mouse.x < ox + v.x + x + w then
							if minGUI.mouse.y >= oy + v.y + y and minGUI.mouse.y < oy + v.y + y + h then
								if v.menu.hover == i then
									table.insert(minGUI.mstack, {eventMenu = v.menu.selected, eventSubMenu = v.menu.hover})
									v.menu.selected = 0
									v.menu.hover = 0

									return v.num
								end
							end
						end

						y = y + minGUI.font[minGUI.numFont]:getHeight() + 2
					end

					-- click outside the menu to close it
					v.menu.selected = 0
					v.menu.hover = 0
				end
			end
		end
	end
	
	return nil
end

-- check if an internal gadget is mousedown
function minGUI_check_internal_gadget_mousedown(b)
	-- check for internal gadgets first
	for i, v in minGUI_each_gadget() do
		-- calculate parents offset
		local ox, oy = minGUI:get_parent_internal_gadget_offset(i, v.tp)
	end
	
	return nil
end

-- check if an internal gadget is mouse released
function minGUI_check_internal_gadget_released(b)
	-- check for internal gadgets first
	for i, v in minGUI_each_gadget() do
		-- calculate parents offset
		local ox, oy = minGUI:get_parent_internal_gadget_offset(i, v.tp)
	end
end

-- check if an internal gadget is mouseup/hovered
function minGUI_check_internal_gadget_mouseup(b)
	-- check for internal gadgets first
	for i, v in minGUI_each_gadget() do
		-- calculate parents offset
		local ox, oy = minGUI:get_parent_internal_gadget_offset(i, v.tp)
		
		if v.tp == MG_INTERNAL_MENU then
			-- mousedown on another menu
			if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
				if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
					if v.menu.selected > 0 then
						-- mousedown on a menu to open it
						x = 0
							
						for i = 1, #v.array do
							menu_width = minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[i].head_menu .. " ")
								
							if minGUI.mouse.x >= ox + v.x + x and minGUI.mouse.x < ox + v.x + x + menu_width then
								v.menu.selected = i
								break
							end
								
							x = x + menu_width
						end
						
						v.menu.hover = 0
						
						return v.num
					end
				end
			end
			
			-- mousedown on a submenu ?
			if v.menu.selected > 0 then
				-- find menu x
				x = 0

				for i = 1, v.menu.selected - 1 do
					x = x + minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[i].head_menu .. " ")
				end
				
				w = minGUI.font[minGUI.numFont]:getWidth(" " .. v.array[v.menu.selected].head_menu .. " ")
				h = minGUI.font[minGUI.numFont]:getHeight() + 2
				
				-- find mousedown submenu y
				y = v.height + 2
				
				for i = 1, #v.array[v.menu.selected].menu_list do
					if minGUI.mouse.x >= ox + v.x + x and minGUI.mouse.x < ox + v.x + x + w then
						if minGUI.mouse.y >= oy + v.y + y and minGUI.mouse.y < oy + v.y + y + h then
							v.menu.hover = i
						
							return v.num
						end
					end

					y = y + minGUI.font[minGUI.numFont]:getHeight() + 2
				end
			end
		end
	end
	
	return nil
end

-- check if parented gadget has been clicked
function minGUI_check_gadget_clicked(b, find_sons, forced_parent)
	-- if a focused window's button is clicked
	local i = minGUI:get_focused_window_number()
	local v = minGUI.gtree[i]

	-- calculate parents offset
	local ox, oy = minGUI_get_parent_gadget_offset(i)
	
	if not find_sons then
		-- check the focused window
		if v and v.tp == MG_WINDOW then
			-- check for close button pressed
			local sw, sh = minGUI_get_sprite_size(MG_CLOSE_WINDOW_IMAGE)
			
			if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_CLOSE) then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + sw then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + sh then
						if b == MG_LEFT_BUTTON then
							minGUI:delete_gadget(i)
						
							return nil
						end
					end
				end
			end
			
			-- check for maximize button pressed
			if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_MAXIMIZE) then
				if minGUI.mouse.x >= ox + v.x + v.width - sw and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + sh then
						if b == MG_LEFT_BUTTON then
							minGUI:maximize_window(i)

							return nil
						end
					end
				end
			end

			-- check for resize button pressed
			if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_RESIZE) then
				if minGUI.mouse.x >= ox + v.x + v.width - sw and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + v.height - sh and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							minGUI.gtree[i].resizing = true
							minGUI:resize_window(i, minGUI.mouse.x - (ox + v.x), minGUI.mouse.y - (oy + v.y))
						
							return nil
						end
					end
				end
			end
		end
	end
	
	-- if a menu is clicked
	if minGUI_check_internal_gadget_clicked(b) ~= nil then
		return nil
	end
	
	-- check for gadget clicked
	for i, v in minGUI_each_gadget(true) do

		-- calculate parents offset
		local ox, oy = minGUI_get_parent_gadget_offset(i)
		
		-- find parent
		local prt = nil
		
		if v.parent ~= nil then
			prt = minGUI.gtree[v.parent]
		end

		if not find_sons or (find_sons and prt ~= nil and forced_parent == prt.num) then
			-- check first windows & panels, to find clicked sons
			if v.tp == MG_WINDOW or v.tp == MG_PANEL then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							-- find a clicked son, if possible
							local son = minGUI.gtree[minGUI_check_gadget_clicked(b, true, v.num)]
						
							-- store the parent of the last son
							local num = v.num

							-- find next son of son
							while son ~= nil do
								num = son.num
								son = minGUI.gtree[minGUI_check_gadget_clicked(b, true, num)]
							end
						
							if num == v.num then
								v.down.left = true
							end

							-- return the clicked gadget number
							return num
						end
					end
				end
			end

			if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE or v.tp == MG_IMAGE then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							v.down.left = true
							getfocusFlag = true
							
							return v.num
						end
					end
				end
			elseif v.tp == MG_STRING then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							minGUI.gfocus = i
							minGUI_string_mouse_pressed(v)
						end
						getfocusFlag = true
							
						return v.num
					end
				end
			elseif v.tp == MG_CHECKBOX then
				local width = minGUI.sprite[MG_CHECKBOX_IMAGE]:getWidth()
				local height = minGUI.sprite[MG_CHECKBOX_IMAGE]:getHeight()
				
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + width then
					if minGUI.mouse.y >= oy + v.y + ((v.height - height) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - height) * 3 / 2) then
						if b == MG_LEFT_BUTTON then
							-- reverse state
							if v.checked == false then v.checked = true else v.checked = false end

							getfocusFlag = true
							
							return v.num
						end
					end
				end
			elseif v.tp == MG_OPTION then
				local width = minGUI.sprite[MG_OPTION_IMAGE]:getWidth()
				local height = minGUI.sprite[MG_OPTION_IMAGE]:getHeight()
				
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + width then
					if minGUI.mouse.y >= oy + v.y + ((v.height - height) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - height) * 3 / 2) then
						if b == MG_LEFT_BUTTON then
							-- uncheck all options of the same parent
							for j, w in minGUI_each_gadget() do
								-- if an other gadget than the option one is checked...
								if j ~= v.num then
									-- if the new gadget is an option one...
									if w.tp == MG_OPTION then
										-- if it has the same parent...
										if w.parent == v.parent then
											-- uncheck it !
											w.checked = false
										end
									end
								end
							end
									
							-- check the currently clicked option
							v.checked = true
							getfocusFlag = true
							
							return v.num
						end
					end
				end
			elseif v.tp == MG_SPIN then
				-- get up and down buttons width & height
				local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
				local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
				local height = fullHeight / 2
	
				if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + height then
						if b == MG_LEFT_BUTTON then
							v.timer = minGUI.timer
							v.btnUp = true
							v.press = 0
							getfocusFlag = true
										
							v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
							
							return v.num
						end
					end
				end
	
				if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
						if b == MG_LEFT_BUTTON then
							v.timer = minGUI.timer
							v.btnDown = true
							v.press = 0
							getfocusFlag = true
										
							v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
								
							return v.num
						end
					end
				end
	
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + (v.width - width) then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							minGUI.gfocus = i
							v.down.left = true
							getfocusFlag = true
								
							return v.num
						end
					end
				end
			elseif v.tp == MG_CANVAS then					
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
										
							v.down.left = true
							getfocusFlag = true
							
							return v.num
						end
								
						if b == MG_RIGHT_BUTTON then
							table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_PRESSED})
										
							v.down.right = true
							getfocusFlag = true
							
							return v.num
						end
					end
				end
			elseif v.tp == MG_EDITOR then
				minGUI_editor_layout(v)
				if b == MG_LEFT_BUTTON and minGUI.mouse.x >= ox + v.x + 2
					and minGUI.mouse.x < ox + v.x + 2 + v.viewWidth
					and minGUI.mouse.y >= oy + v.y + 2
					and minGUI.mouse.y < oy + v.y + 2 + v.viewHeight then
					minGUI.gfocus = i
					minGUI_editor_mouse_pressed(v)
					getfocusFlag = true
					return v.num
				end
			elseif v.tp == MG_SCROLLBAR then
				local value = 0
				
				if minGUI_flag_active(v.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
						if minGUI.mouse.y >= oy + v.y + v.size and minGUI.mouse.y < oy + v.y + v.height - v.size then
							v.down = true
							value = ((minGUI.mouse.y - (oy + v.y + v.size)) / v.real_height) * (v.maxValue - v.minValue)
						end
					end
				else
					if minGUI.mouse.x >= ox + v.x + v.size and minGUI.mouse.x < ox + v.x + v.width - v.size then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
							v.down = true
							value = ((minGUI.mouse.x - (ox + v.x + v.size)) / v.real_width) * (v.maxValue - v.minValue)
						end
					end
				end

				if v.down == true then
					if b == MG_LEFT_BUTTON then
						getfocusFlag = true

						local lng1 = (v.maxValue - v.minValue)
						local lng2 = lng1 / v.stepsValue
						
						value = value - v.minValue
						value = math.floor(value / lng2)
						value = value * lng1 / (v.stepsValue - 1)
						value = value + v.minValue
						value = math.min(math.max(value, v.minValue), v.maxValue)
						v.value = value

						if v.value < v.minValue then v.value = v.minValue end
						if v.value > v.maxValue then v.value = v.maxValue end
						
						table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
							
						return v.num
					end
				end

				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
						if b == MG_LEFT_BUTTON then
							v.timer = minGUI.timer
							v.down1 = true
							getfocusFlag = true
							v.value = v.value - v.inc
								
							if v.value < v.minValue then v.value = v.minValue end
								
							table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
								
							return v.num
						end
					end
				end

				if minGUI.mouse.x >= ox + v.x + v.width - v.size and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + v.height - v.size and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							v.timer = minGUI.timer
							v.down2 = true
							getfocusFlag = true
							v.value = v.value + v.inc

							if v.value > v.maxValue then v.value = v.maxValue end
								
							table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_PRESSED})
								
							return v.num
						end
					end
				end
			end
		end
	end
	
	-- focus lost ?
	if b == MG_LEFT_BUTTON then
		if getfocusFlag == false then
			minGUI.gfocus = nil
		end
	end
	
	return nil
end

-- check if parented gadget is mousedown
function minGUI_check_gadget_mousedown(b, find_sons, forced_parent)
	-- if a focused window's button is clicked
	local i = minGUI:get_focused_window_number()
	local v = minGUI.gtree[i]

	-- calculate parents offset
	local ox, oy = minGUI_get_parent_gadget_offset(i)
	
	if not find_sons then
		-- check the focused window
		if v and v.tp == MG_WINDOW then
			-- check for window's button down
			local sw, sh = minGUI_get_sprite_size(MG_CLOSE_WINDOW_IMAGE)
			
			-- check for resize button down
			if b == MG_LEFT_BUTTON then
				if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_RESIZE) then
					if minGUI.gtree[i].resizing then
						minGUI:resize_window(i, minGUI.mouse.x - (ox + v.x), minGUI.mouse.y - (oy + v.y))
							
						return nil
					end
				end
			end
		end
	end

	-- if a menu is mousedown
	if minGUI_check_internal_gadget_mousedown(b) ~= nil then
		return nil
	end

	-- check for gadget clicked
	for i, v in minGUI_each_gadget(true) do

		-- calculate parents offset
		local ox, oy = minGUI_get_parent_gadget_offset(i)
		
		-- find parent
		local prt = nil
		
		if v.parent ~= nil then
			prt = minGUI.gtree[v.parent]
		end
		
		if not find_sons or (find_sons and prt ~= nil and forced_parent == prt.num) then
			if v.tp == MG_WINDOW or v.tp == MG_PANEL then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							-- find a clicked son, if possible
							local son = minGUI.gtree[minGUI_check_gadget_mousedown(b, true, v.num)]
						
							-- store the parent of the last son
							local num = v.num

							-- find next son of son
							while son ~= nil do
								num = son.num
								son = minGUI.gtree[minGUI_check_gadget_mousedown(b, true, num)]
							end
						
							if num ~= v.num then
								v.down.left = false
							end

							-- return the clicked gadget number
							return num
						end
					end
				end
			elseif v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE or v.tp == MG_IMAGE then
				if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.width then
					if b == MG_LEFT_BUTTON then
						v.down.left = false
					elseif b == MG_RIGHT_BUTTON then
						v.down.right = false
					end
				elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.height then
					if b == MG_LEFT_BUTTON then
						v.down.left = false
					elseif b == MG_RIGHT_BUTTON then
						v.down.right = false
					end
				end
			elseif v.tp == MG_SPIN then					
				-- get up and down buttons width & height
				local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
				local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
				local height = fullHeight / 2

				if minGUI.mouse.x < ox + v.x + v.width - width or minGUI.mouse.x >= ox + v.x + v.width then
					if b == MG_LEFT_BUTTON then
						v.btnUp = false
					end
				elseif minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) or minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + height then
					if b == MG_LEFT_BUTTON then
						v.btnUp = false
					end
				end

				if v.btnUp == true then
					local t = minGUI.timer - v.timer
							
					if v.press == 0 then
						if t >= MG_SLOW_DELAY then
							v.timer = minGUI.timer
							v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
							v.press = v.press + 1
						end
					elseif v.press > 0 then
						if t >= MG_QUICK_DELAY then
							v.timer = minGUI.timer
							v.text = frameTextValue(IncTextValue(v.text), v.minValue, v.maxValue)
							v.press = v.press + 1
						end
					end
				end

				if minGUI.mouse.x < ox + v.x + v.width - width or minGUI.mouse.x >= ox + v.x + v.width then
					if b == MG_LEFT_BUTTON then
						v.btnDown = false
					end
				elseif minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + height or minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
					if b == MG_LEFT_BUTTON then
						v.btnDown = false
					end
				end
						
				if v.btnDown == true then
					local t = minGUI.timer - v.timer
							
					if v.press == 0 then
						if t >= MG_SLOW_DELAY then
							v.timer = minGUI.timer
							v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
							v.press = v.press + 1
						end
					elseif v.press > 0 then
						if t >= MG_QUICK_DELAY then
							v.timer = minGUI.timer
							v.text = frameTextValue(DecTextValue(v.text), v.minValue, v.maxValue)
							v.press = v.press + 1
						end
					end
				end
			elseif v.tp == MG_CANVAS then
				if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.width then
					if b == MG_LEFT_BUTTON then
						v.down.left = false
					elseif b == MG_RIGHT_BUTTON then
						v.down.right = false
					end
				elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.height then
					if b == MG_LEFT_BUTTON then
						v.down.left = false
					elseif b == MG_RIGHT_BUTTON then
						v.down.right = false
					end
				end

				if b == MG_LEFT_BUTTON then
					if v.down.left == true then
						table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
						return v.num
					end
				end
				
				if b == MG_RIGHT_BUTTON then
					if v.down.right == true then
						table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_DOWN})
						return v.num
					end
				end
			elseif v.tp == MG_SCROLLBAR then
				local value = 0
				
				if minGUI_flag_active(v.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
					if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.size then
						if b == MG_LEFT_BUTTON then
							v.down = false
						end
					elseif minGUI.mouse.y < oy + v.y + v.size or minGUI.mouse.y >= oy + v.y + v.height - v.size then
						if b == MG_LEFT_BUTTON then
							v.down = false
						end
					else
						value = ((minGUI.mouse.y - (oy + v.y + v.size)) / v.real_height) * (v.maxValue - v.minValue)
					end
				else
					if minGUI.mouse.x < ox + v.x + v.size or minGUI.mouse.x >= ox + v.x + v.width - v.size then
						if b == MG_LEFT_BUTTON then
							v.down = false
						end
					elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.size then
						if b == MG_LEFT_BUTTON then
							v.down = false
						end
					else
						value = ((minGUI.mouse.x - (ox + v.x + v.size)) / v.real_width) * (v.maxValue - v.minValue)
					end
				end
				
				if v.down == true then
					local lng1 = (v.maxValue - v.minValue)
					local lng2 = lng1 / v.stepsValue
					
					value = value - v.minValue
					value = math.floor(value / lng2)
					value = value * lng1 / (v.stepsValue - 1)
					value = value + v.minValue
					value = math.min(math.max(value, v.minValue), v.maxValue)
					v.value = value
							
					if v.value < v.minValue then v.value = v.minValue end
					if v.value > v.maxValue then v.value = v.maxValue end
						
					if b == MG_LEFT_BUTTON then
						table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
					end
				end
				
				if minGUI.mouse.x < ox + v.x or minGUI.mouse.x >= ox + v.x + v.size then
					if b == MG_LEFT_BUTTON then
						v.down1 = false
					end
				elseif minGUI.mouse.y < oy + v.y or minGUI.mouse.y >= oy + v.y + v.size then
					if b == MG_LEFT_BUTTON then
						v.down1 = false
					end
				end
			
				if v.down1 == true then
					local t = minGUI.timer - v.timer
							
					if t >= MG_MEDIUM_DELAY then
						v.timer = minGUI.timer
						v.value = v.value - v.inc
							
						if v.value < v.minValue then v.value = v.minValue end
						
						if b == MG_LEFT_BUTTON then
							table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
						end
					end
				end

				if minGUI.mouse.x < ox + v.x + v.width - v.size or minGUI.mouse.x >= ox + v.x + v.width then
					if b == MG_LEFT_BUTTON then
						v.down2 = false
					end
				elseif minGUI.mouse.y < oy + v.y + v.height - v.size or minGUI.mouse.y >= oy + v.y + v.height then
					if b == MG_LEFT_BUTTON then
						v.down2 = false
					end
				end

				if v.down2 == true then
					local t = minGUI.timer - v.timer
							
					if t >= MG_MEDIUM_DELAY then
						v.timer = minGUI.timer
						v.value = v.value + v.inc
						
						if v.value > v.maxValue then v.value = v.maxValue end
						
						if b == MG_LEFT_BUTTON then
							table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_DOWN})
						end
					end
				end
			end
		end
	end
	
	return nil
end

-- check if parented gadget is mouse released
function minGUI_check_gadget_released(b, find_sons, forced_parent)
	-- if a focused window's button is clicked
	local i = minGUI:get_focused_window_number()
	local v = minGUI.gtree[i]

	-- calculate parents offset
	local ox, oy = minGUI_get_parent_gadget_offset(i)
	
	if not find_sons then
		-- check the focused window
		if v and v.tp == MG_WINDOW then
			-- check for window's button released
			local sw, sh = minGUI_get_sprite_size(MG_CLOSE_WINDOW_IMAGE)
			
			-- check for resize button released
			if b == MG_LEFT_BUTTON then
				if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_RESIZE) then
					if minGUI.gtree[i].resizing then
						minGUI.gtree[i].resizing = false
						
						return nil
					end
				end
			end
		end
	end

	-- check for gadget released
	for i, v in minGUI_each_gadget(true) do

		-- calculate parents offset
		local ox, oy = minGUI_get_parent_gadget_offset(i)
		
		-- find parent
		local prt = nil
		
		if v.parent ~= nil then
			prt = minGUI.gtree[v.parent]
		end

		if not find_sons or (find_sons and prt ~= nil and forced_parent == prt.num) then
			if v.tp == MG_WINDOW or v.tp == MG_CANVAS then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							if v.down.left == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
									
							v.down.left = false
						end
							
						if b == MG_RIGHT_BUTTON then
							if v.down.right == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_RELEASED}) end
									
							v.down.right = false										
						end
					end
				end
			end

			if v.tp == MG_BUTTON or v.tp == MG_BUTTON_IMAGE or v.tp == MG_IMAGE then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							if v.down.left == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
									
							v.down.left = false										
						end
							
						if b == MG_RIGHT_BUTTON then
							if v.down.right == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_RELEASED}) end
									
							v.down.right = false										
						end
					end
				end
			elseif v.tp == MG_SPIN then
				-- release the key pressed
				v.press = 0

				-- get up and down buttons width & height
				local width = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()
				local fullHeight = minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()
				local height = fullHeight / 2

				if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + height then
						if b == MG_LEFT_BUTTON then
							v.btnUp = false
						end
					end
				end
						
				if minGUI.mouse.x >= ox + v.x + v.width - width and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + ((v.height - fullHeight) / 2) + height and minGUI.mouse.y < oy + v.y + ((v.height - fullHeight) / 2) + (2 * height) then
						if b == MG_LEFT_BUTTON then
							v.btnDown = false
						end
					end
				end
			elseif v.tp == MG_CANVAS then
				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							if v.down.left == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
									
							v.down.left = false
						end
							
						if b == MG_RIGHT_BUTTON then
							if v.down.right == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_RIGHT_MOUSE_RELEASED}) end
									
							v.down.right = false
						end
					end
				end
			elseif v.tp == MG_SCROLLBAR then
				if minGUI_flag_active(v.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
					if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
						if minGUI.mouse.y >= oy + v.y + v.size and minGUI.mouse.y < oy + v.y + v.height - v.size then
							if b == MG_LEFT_BUTTON then
								if v.down == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end

								v.down = false
							end
						end
					end
				else
					if minGUI.mouse.x >= ox + v.x + v.size and minGUI.mouse.x < ox + v.x + v.width - v.size then
						if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
							if b == MG_LEFT_BUTTON then
								if v.down == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end

								v.down = false
							end
						end
					end
				end

				if minGUI.mouse.x >= ox + v.x and minGUI.mouse.x < ox + v.x + v.size then
					if minGUI.mouse.y >= oy + v.y and minGUI.mouse.y < oy + v.y + v.size then
						if b == MG_LEFT_BUTTON then
							if v.down1 == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
									
							v.down1 = false										
						end
					end
				end

				if minGUI.mouse.x >= ox + v.x + v.width - v.size and minGUI.mouse.x < ox + v.x + v.width then
					if minGUI.mouse.y >= oy + v.y + v.height - v.size and minGUI.mouse.y < oy + v.y + v.height then
						if b == MG_LEFT_BUTTON then
							if v.down2 == true then table.insert(minGUI.gstack, {eventGadget = i, eventType = MG_EVENT_LEFT_MOUSE_RELEASED}) end
									
							v.down2 = false										
						end
					end
				end
			end
		end
	end
	
	return nil
end
