-- function to call from love.load()
function minGUI_init()
	-- set default filter
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	-- constants:
	MG_WINDOW_TITLEBAR_HEIGHT = 25
	
	-- gadgets
	MG_WINDOW = 1
	MG_PANEL = 2
	MG_BUTTON = 3
	MG_BUTTON_IMAGE = 4
	MG_LABEL = 5
	MG_STRING = 6
	MG_CANVAS = 7
	MG_CHECKBOX = 8
	MG_OPTION = 9
	MG_SPIN = 10
	MG_EDITOR = 11
	MG_SCROLLBAR = 12
	MG_IMAGE = 13
	MG_INTERNAL_SCROLLBAR = 101
	MG_INTERNAL_BOX = 102
	MG_INTERNAL_MENU = 103
	
	-- gadget images
	MG_WINDOW_IMAGE = 1
	MG_TITLEBAR_IMAGE = 2
	MG_WINDOW_SELECTED_IMAGE = 3
	MG_PANEL_IMAGE = 4
	MG_BUTTON_UP_IMAGE = 5
	MG_BUTTON_DOWN_IMAGE = 6
	MG_CHECKBOX_IMAGE = 7
	MG_OPTION_IMAGE = 8
	MG_SPIN_IMAGE = 9
	MG_SPIN_BUTTON_UP_IMAGE = 10
	MG_SPIN_BUTTON_DOWN_IMAGE = 11
	MG_SCROLLBAR_IMAGE = 12
	MG_MENU_UP_IMAGE = 13
	MG_MENU_DOWN_IMAGE = 14
	MG_SUBMENU_UP_IMAGE = 15
	MG_SUBMENU_DOWN_IMAGE = 16
	MG_CLOSE_WINDOW_IMAGE = 17
	MG_MAXIMIZE_WINDOW_IMAGE = 18
	MG_RESIZE_WINDOW_IMAGE = 19
	
	-- mouse buttons
	MG_LEFT_BUTTON = 1
	MG_RIGHT_BUTTON = 2
	MG_MIDDLE_BUTTON = 3
	
	-- default font
	MG_DEFAULT_FONT = 0
	
	-- delays
	MG_SLOW_DELAY = 0.5
	MG_MEDIUM_DELAY = 0.2
	MG_QUICK_DELAY = 0.05

	-- flags
	MG_FLAG_WINDOW_TITLEBAR = 1
	MG_FLAG_WINDOW_CLOSE = 2
	MG_FLAG_WINDOW_MAXIMIZE = 4
	MG_FLAG_WINDOW_RESIZE = 8
	MG_FLAG_WINDOW_ALL_GADGETS = 1 + 2 + 4 + 8
	MG_FLAG_WINDOW_CENTERED = 16
	
	MG_FLAG_NOT_EDITABLE = 1
	MG_FLAG_NO_SCROLLBARS = 2

	MG_FLAG_SCROLLBAR_HORIZONTAL = 0
	MG_FLAG_SCROLLBAR_VERTICAL = 1

	MG_FLAG_ALIGN_LEFT = 1
	MG_FLAG_ALIGN_RIGHT = 2
	MG_FLAG_ALIGN_CENTER = 3
	
	-- events
	MG_EVENT_LEFT_MOUSE_PRESSED = 1
	MG_EVENT_LEFT_MOUSE_DOWN = 2
	MG_EVENT_LEFT_MOUSE_RELEASED = 3
	MG_EVENT_LEFT_MOUSE_CLICK = 3

	MG_EVENT_RIGHT_MOUSE_PRESSED = 4
	MG_EVENT_RIGHT_MOUSE_DOWN = 5
	MG_EVENT_RIGHT_MOUSE_RELEASED = 6
	MG_EVENT_RIGHT_MOUSE_CLICK = 6
	
	MG_EVENT_TIMER_TICK = 1

	-- scrollbars
	MG_MIN_SCROLLBAR_BUTTON_SIZE = 8
	
	MG_SCROLLBAR_MIN_VALUE = 1
	MG_SCROLLBAR_MAX_VALUE = 2
	MG_SCROLLBAR_INCREMENT_VALUE = 3
	
	MG_SCROLLBAR_SIZE = 20
	
	-- init minGUI table
	minGUI = {
		-- attributes
		theme = "Dark", -- colors theme
		bgcolor = {r = 0.5, g = 0.5, b = 0.5, a = 1}, -- background color
		invtxtcolor = {r = 1, g = 1, b = 1, a = 1}, -- inverted text color
		txtcolor = {r = 0, g = 0, b = 0, a = 1}, -- text color
		greyedcolor = {r = 0.75, g = 0.75, b = 0.75, a = 1}, -- greyed color
		gtree = {}, -- gadgets's tree
		igtree = {}, -- internal's gadgets tree
		mouse = {x = 0, y = 0, oldmbtn = {}, mbtn = {}, mpressed = {}, mreleased = {}}, -- mouse events
		estack = {}, -- events stack
		ptimer = {}, -- programmable timers
		tstack = {}, -- timers events stack
		ext_gadget = 0, -- gadgets numbers
		int_gadget = 0, -- internal gadgets numbers
		timer = 0, -- time from start of the app
		kbdelay = 0,
		gfocus = nil, -- gadget focused
		sprite = {}, -- sprites
		font = {}, -- fonts
		numFont = MG_DEFAULT_FONT, -- selected font
		exitProcess = false,
		--
		-- methods ==============================
		--
		-- show a message
		info_message = function(self, message)
			love.window.showMessageBox("info", message, "info", true)
		end,
		-- show error
		error_message = function(self, message)
			love.window.showMessageBox("error", message, "error", true)
		end,
		-- start a timer, with a delay in milliseconds
		start_timer = function(self, num, delay)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("[start_timer]Wrong num value"); return end
			if not minGUI_check_param(delay, "number") then minGUI_error_message("[start_timer]Wrong delay value"); return end
			
			minGUI.ptimer[num] = {delay = delay, timer = math.floor(minGUI.timer * 1000)}
		end,
		-- stop a timer
		stop_timer = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("[stop_timer]Wrong num value"); return end

			minGUI.ptimer[num] = nil
		end,
		-- load all sprites and 9-slice sprites
		load_sprites = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- load 9-slice sprites
			minGUI_load_9slice(MG_WINDOW_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/window.png")
			minGUI_load_9slice(MG_WINDOW_SELECTED_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/window_selected.png")
			minGUI_load_9slice(MG_PANEL_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/panel.png")
			minGUI_load_9slice(MG_BUTTON_UP_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/button_up.png")
			minGUI_load_9slice(MG_BUTTON_DOWN_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/button_down.png")
			minGUI_load_9slice(MG_SPIN_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/spin.png")
			minGUI_load_9slice(MG_SCROLLBAR_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/scrollbar.png")
			minGUI_load_9slice(MG_MENU_UP_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/menu_up.png")
			minGUI_load_9slice(MG_MENU_DOWN_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/menu_down.png")
			minGUI_load_9slice(MG_SUBMENU_UP_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/submenu_up.png")
			minGUI_load_9slice(MG_SUBMENU_DOWN_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/submenu_down.png")
			minGUI_load_9slice(MG_TITLEBAR_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/titlebar.png")

			-- load sprites
			minGUI_load_sprite(MG_CHECKBOX_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/checkbox.png")
			minGUI_load_sprite(MG_OPTION_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/option.png")
			minGUI_load_sprite(MG_SPIN_BUTTON_UP_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/spin_buttons_up.png")
			minGUI_load_sprite(MG_SPIN_BUTTON_DOWN_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/spin_buttons_down.png")
			minGUI_load_sprite(MG_CLOSE_WINDOW_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/close_button.png")
			minGUI_load_sprite(MG_MAXIMIZE_WINDOW_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/maximize_button.png")
			minGUI_load_sprite(MG_RESIZE_WINDOW_IMAGE, "minGUI/themes/" .. minGUI.theme .. "/resize_button.png")
		end,
		-- set colors theme
		set_theme = function(self, text)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param2(text, "string") then minGUI_error_message("[set_theme]Wrong theme"); return end

			minGUI.theme = text
			
			-- update theme sprites
			self.load_sprites()
		end,
		-- set background color (red, green, blue, alpha)
		set_bgcolor = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.bgcolor.r = r
			minGUI.bgcolor.g = g
			minGUI.bgcolor.b = b
			minGUI.bgcolor.a = a
		end,
		-- set text color (red, green, blue, alpha)
		set_textcolor = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.txtcolor.r = r
			minGUI.txtcolor.g = g
			minGUI.txtcolor.b = b
			minGUI.txtcolor.a = a
		end,
		-- set inverted text color (red, green, blue, alpha)
		set_invtextcolor = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.invtxtcolor.r = r
			minGUI.invtxtcolor.g = g
			minGUI.invtxtcolor.b = b
			minGUI.invtxtcolor.a = a
		end,
		-- set greyed color (red, green, blue, alpha)
		set_greyedcolor = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.greyedcolor.r = r
			minGUI.greyedcolor.g = g
			minGUI.greyedcolor.b = b
			minGUI.greyedcolor.a = a
		end,
		load_font = function(self, num, path, size)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			local t = love.filesystem.getInfo(path, "file")

			if t ~= nil and t.type == "file" and t.size > 0 then
				minGUI.font[num] = love.graphics.newFont(path, size)
			end
		end,
		-- set font number
		set_font = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if minGUI.font[num] ~= nil then minGUI.numFont = num end
		end,
		get_gadget_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.estack ~= 0 then
				local eventGadget = minGUI.estack[#minGUI.estack].eventGadget
				local eventType = minGUI.estack[#minGUI.estack].eventType
				
				table.remove(minGUI.estack, #minGUI.estack)

				return eventGadget, eventType
			end

			return nil, nil
		end,
		get_timer_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.tstack ~= 0 then
				local eventTimer = minGUI.tstack[#minGUI.tstack].eventTimer
				local eventType = minGUI.tstack[#minGUI.tstack].eventType
				
				table.remove(minGUI.tstack, #minGUI.tstack)

				return eventTimer, eventType
			end

			return nil, nil
		end,
		set_focus = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.gfocus = num
		end,
		set_gadget_text = function(self, num, text)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[set_gadget_text]Wrong num value"); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("[set_gadget_text]Wrong text for gadget " .. num); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget has a text attribute...
				if minGUI.gtree[num].text ~= nil then
					-- if the gadget is a string gadget...
					if minGUI.gtree[num].tp == MG_STRING then
						-- replace the text
						minGUI.gtree[num].text = text
					
						minGUI_shift_text(num, text)
					elseif minGUI.gtree[num].tp == MG_LABEL then
						-- replace the text
						minGUI.gtree[num].text = text
					-- if the gadget is a spin gadget...
					elseif minGUI.gtree[num].tp == MG_SPIN then
						-- replace the value
						minGUI.gtree[num].text = frameTextValue(math.floor(tonumber(text) + 0.5), minGUI.gtree[num].minValue, minGUI.gtree[num].maxValue)

						minGUI_shift_text(num, text)		
					end
				end
			end
		end,
		get_gadget_text = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_text]Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget has a text attribute...
				if minGUI.gtree[num].text ~= nil then
					-- if the gadget is a string gadget...
					if minGUI.gtree[num].tp == MG_STRING then
						-- return the text
						return minGUI.gtree[num].text
					elseif minGUI.gtree[num].tp == MG_LABEL then
						-- return the text
						return minGUI.gtree[num].text
					elseif minGUI.gtree[num].tp == MG_SPIN then
						-- return the text value
						return minGUI.gtree[num].text					
					elseif minGUI.gtree[num].tp == MG_EDITOR then
						-- return the text value
						return minGUI.gtree[num].text
					end
				end
			end
			
			return ""
		end,
		set_gadget_state = function(self, num, value)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[set_gadget_state]Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is checkable
				if minGUI.gtree[num].checked ~= nil then
					-- if the gadget is an option gadget...
					if minGUI.gtree[num].tp == MG_OPTION then
						-- uncheck all options of the same parent
						for j, w in ipairs(minGUI.gtree) do
							-- if an other gadget than the option one is checked...
							if j ~= num then
								-- if the new gadget is an option one...
								if w.tp == MG_OPTION then
									-- if it has the same parent...
									if (w.parent == nil and minGUI.gtree[num].parent == nil) or (w.parent ~= nil and minGUI.gtree[num].parent ~= nil and w.parent == minGUI.gtree[num].parent) then
										-- uncheck it !
										w.checked = false
									end
								end
							end
						end
					end
					
					if type(value) ~= "boolean" then minGUI_error_message("[set_gadget_state]Wrong state value"); return end
					if value == nil then value = false end

					-- check the gadget
					minGUI.gtree[num].checked = value
				else
					-- if the gadget is a scrollbar gadget...
					if minGUI.gtree[num].tp == MG_SCROLLBAR then					
						if type(value) ~= "number" then minGUI_error_message("[set_gadget_state]Wrong state value"); return end
						if value == nil then value = 0 end
						
						-- set the value of the gadget
						local lng1 = (minGUI.gtree[num].maxValue - minGUI.gtree[num].minValue)
						local lng2 = lng1 / minGUI.gtree[num].stepsValue
						
						value = value - minGUI.gtree[num].minValue
						value = math.floor(value / lng2)
						value = value * lng1 / (minGUI.gtree[num].stepsValue - 1)
						value = value + minGUI.gtree[num].minValue
						
						minGUI.gtree[num].value = math.min(math.max(value, minGUI.gtree[num].minValue), minGUI.gtree[num].maxValue)
					end
				end
			end
		end,
		get_gadget_state = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_state]Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is checkable
				if minGUI.gtree[num].checked ~= nil then
					-- return the gadget state
					return minGUI.gtree[num].checked
				else
					-- if the gadget is a scrollbar gadget...
					if minGUI.gtree[num].tp == MG_SCROLLBAR then
						return math.floor(minGUI.gtree[num].value + 0.5)
					end
				end
			end
			
			return 0
		end,
		set_gadget_attribute = function(self, num, attr, value)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[set_gadget_attribute]Wrong num value"); return end
			if not minGUI_check_param(attr, "number") then minGUI_error_message("[set_gadget_attribute]Wrong attribute value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is a scrollbar gadget...
				if minGUI.gtree[num].tp == MG_SCROLLBAR then					
					if type(value) ~= "number" then minGUI_error_message("[set_gadget_attribute]Wrong state value"); return end
					if value == nil then value = 0 end
	
					-- set the value of the gadget
					if attr == MG_SCROLLBAR_MIN_VALUE then
						minGUI.gtree[num].minValue = math.floor(value + 0.5)
						minGUI.gtree[num].stepsValue = math.floor((minGUI.gtree[num].maxValue - minGUI.gtree[num].minValue) / minGUI.gtree[num].inc) + 1

						if minGUI.gtree[num].stepsValue < 1 then minGUI.gtree[num].stepsValue = 1 end
						
						minGUI.gtree[num].value = math.min(math.max(math.floor(minGUI.gtree[num].value + 0.5), minGUI.gtree[num].minValue), minGUI.gtree[num].maxValue)

						-- vertical or horizontal scrollbar ?
						if minGUI_flag_active(minGUI.gtree[num].flags, MG_FLAG_SCROLLBAR_VERTICAL) then
							minGUI.gtree[num].internalBarSize = minGUI.gtree[num].real_height
						else
							minGUI.gtree[num].internalBarSize = minGUI.gtree[num].real_width
						end
						
						-- calculate button's other size
						minGUI.gtree[num].min_size = minGUI.gtree[num].internalBarSize / minGUI.gtree[num].stepsValue
						minGUI.gtree[num].size_width = math.max(minGUI.gtree[num].min_size, MG_MIN_SCROLLBAR_BUTTON_SIZE)
						minGUI.gtree[num].size_height = minGUI.gtree[num].size
			
						-- swap size_width & size_height ?
						if minGUI_flag_active(minGUI.gtree[num].flags, MG_FLAG_SCROLLBAR_VERTICAL) then
							local swap = minGUI.gtree[num].size_height
							minGUI.gtree[num].size_height = minGUI.gtree[num].size_width
							minGUI.gtree[num].size_width = swap
						end
						
						-- resize canvas
						minGUI.gtree[num].canvas3 = love.graphics.newCanvas(minGUI.gtree[num].size_width, minGUI.gtree[num].size_height)
					elseif attr == MG_SCROLLBAR_MAX_VALUE then
						minGUI.gtree[num].maxValue = math.floor(value + 0.5)
						minGUI.gtree[num].stepsValue = math.floor((minGUI.gtree[num].maxValue - minGUI.gtree[num].minValue) / minGUI.gtree[num].inc) + 1

						if minGUI.gtree[num].stepsValue < 1 then minGUI.gtree[num].stepsValue = 1 end
						
						minGUI.gtree[num].value = math.min(math.max(math.floor(minGUI.gtree[num].value + 0.5), minGUI.gtree[num].minValue), minGUI.gtree[num].maxValue)

						-- vertical or horizontal scrollbar ?
						if minGUI_flag_active(minGUI.gtree[num].flags, MG_FLAG_SCROLLBAR_VERTICAL) then
							minGUI.gtree[num].internalBarSize = minGUI.gtree[num].real_height
						else
							minGUI.gtree[num].internalBarSize = minGUI.gtree[num].real_width
						end
						
						-- calculate button's other size
						minGUI.gtree[num].min_size = minGUI.gtree[num].internalBarSize / minGUI.gtree[num].stepsValue
						minGUI.gtree[num].size_width = math.max(minGUI.gtree[num].min_size, MG_MIN_SCROLLBAR_BUTTON_SIZE)
						minGUI.gtree[num].size_height = minGUI.gtree[num].size
			
						-- swap size_width & size_height ?
						if minGUI_flag_active(minGUI.gtree[num].flags, MG_FLAG_SCROLLBAR_VERTICAL) then
							local swap = minGUI.gtree[num].size_height
							minGUI.gtree[num].size_height = minGUI.gtree[num].size_width
							minGUI.gtree[num].size_width = swap
						end
						
						-- resize canvas
						minGUI.gtree[num].canvas3 = love.graphics.newCanvas(minGUI.gtree[num].size_width, minGUI.gtree[num].size_height)
					elseif attr == MG_SCROLLBAR_INCREMENT_VALUE then
						minGUI.gtree[num].inc = math.floor(value + 0.5)						
						minGUI.gtree[num].stepsValue = math.floor((minGUI.gtree[num].maxValue - minGUI.gtree[num].minValue) / minGUI.gtree[num].inc) + 1

						if minGUI.gtree[num].stepsValue < 1 then minGUI.gtree[num].stepsValue = 1 end
						
						-- vertical or horizontal scrollbar ?
						if minGUI_flag_active(minGUI.gtree[num].flags, MG_FLAG_SCROLLBAR_VERTICAL) then
							minGUI.gtree[num].internalBarSize = minGUI.gtree[num].real_height
						else
							minGUI.gtree[num].internalBarSize = minGUI.gtree[num].real_width
						end
						
						-- calculate button's other size
						minGUI.gtree[num].min_size = minGUI.gtree[num].internalBarSize / minGUI.gtree[num].stepsValue
						minGUI.gtree[num].size_width = math.max(minGUI.gtree[num].min_size, MG_MIN_SCROLLBAR_BUTTON_SIZE)
						minGUI.gtree[num].size_height = minGUI.gtree[num].size
			
						-- swap size_width & size_height ?
						if minGUI_flag_active(minGUI.gtree[num].flags, MG_FLAG_SCROLLBAR_VERTICAL) then
							local swap = minGUI.gtree[num].size_height
							minGUI.gtree[num].size_height = minGUI.gtree[num].size_width
							minGUI.gtree[num].size_width = swap
						end
						
						-- resize canvas
						minGUI.gtree[num].canvas3 = love.graphics.newCanvas(minGUI.gtree[num].size_width, minGUI.gtree[num].size_height)
					end
				end
			end
		end,
		get_gadget_attribute = function(self, num, attr)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_attribute]Wrong num value"); return end
			if not minGUI_check_param(attr, "number") then minGUI_error_message("[get_gadget_attribute]Wrong attribute value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is a scrollbar gadget...
				if minGUI.gtree[num].tp == MG_SCROLLBAR then
					if attr == MG_SCROLLBAR_MIN_VALUE then
						return math.floor(minGUI.gtree[num].minValue + 0.5)
					elseif attr == MG_SCROLLBAR_MAX_VALUE then
						return math.floor(minGUI.gtree[num].maxValue + 0.5)
					elseif attr == MG_SCROLLBAR_INCREMENT_VALUE then
						return math.floor(minGUI.gtree[num].inc + 0.5)
					end
				end
			end
					
			return 0
		end,
		clear_canvas = function(self, num, red, green, blue, alpha)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[clear_canvas]Wrong num value"); return end
			if red == nil or red < 0.0 or red > 1.0 then minGUI_error_message("[clear_canvas]Wrong red color for gadget " .. num); return end
			if green == nil or green < 0.0 or green > 1.0 then minGUI_error_message("[clear_canvas]Wrong green color for gadget " .. num); return end
			if blue == nil or blue < 0.0 or blue > 1.0 then minGUI_error_message("[clear_canvas]Wrong blue color for gadget " .. num); return end
			if alpha == nil or alpha < 0.0 or alpha > 1.0 then minGUI_error_message("[clear_canvas]Wrong alpha color for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- clear the canvas
			love.graphics.clear(red, green, blue, alpha)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_text_to_canvas = function(self, num, text, x, y, color, scalex, scaley)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_text_to_canvas]Wrong num value"); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("[draw_text_to_canvas]Wrong text value for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_text_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_text_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param2(scalex, "number") then minGUI_error_message("[draw_text_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(scaley, "number") then minGUI_error_message("[draw_text_to_canvas]Wrong y for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_text_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_text_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_text_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_text_to_canvas]Wrong alpha color for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- default x & y
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			if scalex == nil then scalex = 1 end
			if scaley == nil then scaley = 1 end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set white color filter
			love.graphics.setColor(color.r, color.g, color.b, color.a)

			-- draw the image
			love.graphics.print(text, x, y, 0, scalex, scaley)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_image_to_canvas = function(self, num, image, x, y, scalex, scaley)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_image_to_canvas]Wrong num value"); return end
			if image == nil then minGUI_error_message("[draw_image_to_canvas]Wrong image for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_image_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_image_to_canvas]Wrong y for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- default x & y
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set white color filter
			love.graphics.setColor(1, 1, 1, 1)

			-- draw the image
			love.graphics.draw(image, x, y, 0, scalex, scaley)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_quad_to_canvas = function(self, num, image, quad, x, y, scalex, scaley)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_quad_to_canvas]Wrong num value"); return end
			if image == nil then minGUI_error_message("[draw_quad_to_canvas]Wrong image for gadget " .. num); return end
			if quad == nil then minGUI_error_message("[draw_quad_to_canvas]Wrong quad for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_quad_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_quad_to_canvas]Wrong y for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- default x & y
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set white color filter
			love.graphics.setColor(1, 1, 1, 1)

			-- draw the image
			love.graphics.draw(image, quad, x, y, 0, scalex, scaley)
			
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_point_to_canvas = function(self, num, x, y, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_point_to_canvas]Wrong num value"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_point_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_point_to_canvas]Wrong y for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_point_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_point_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_point_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_point_to_canvas]Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a point
			love.graphics.points(x, y)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_line_to_canvas = function(self, num, x1, y1, x2, y2, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_line_to_canvas]Wrong num value"); return end
			if not minGUI_check_param2(x1, "number") then minGUI_error_message("[draw_line_to_canvas]Wrong x1 for gadget " .. num); return end
			if not minGUI_check_param2(y1, "number") then minGUI_error_message("[draw_line_to_canvas]Wrong y1 for gadget " .. num); return end
			if not minGUI_check_param2(x2, "number") then minGUI_error_message("[draw_line_to_canvas]Wrong x2 for gadget " .. num); return end
			if not minGUI_check_param2(y2, "number") then minGUI_error_message("[draw_line_to_canvas]Wrong y2 for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_line_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_line_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_line_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_line_to_canvas]Wrong alpha color for gadget " .. num); return end

			if x1 == nil then x1 = 0 end
			if y1 == nil then y1 = 0 end
			if x2 == nil then x2 = 0 end
			if y2 == nil then y2 = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a line
			love.graphics.line(x1, y1, x2, y2)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_arc_to_canvas = function(self, num, mode, x, y, radius, angle1, angle2, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_arc_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("[draw_arc_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_arc_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_arc_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(radius, "number") then minGUI_error_message("[draw_arc_to_canvas]Wrong radius for gadget " .. num); return end
			if not minGUI_check_param(angle1, "number") then minGUI_error_message("[draw_arc_to_canvas]Wrong 1st angle for gadget " .. num); return end
			if not minGUI_check_param(angle2, "number") then minGUI_error_message("[draw_arc_to_canvas]Wrong 2nd angle for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_arc_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_arc_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_arc_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_arc_to_canvas]Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw an arc
			love.graphics.arc(mode, x, y, radius, angle1, angle2)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_rectangle_to_canvas = function(self, num, mode, x, y, width, height, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_rectangle_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("[draw_rectangle_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_rectangle_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_rectangle_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[draw_rectangle_to_canvas]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[draw_rectangle_to_canvas]Wrong height for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_rectangle_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_rectangle_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_rectangle_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_rectangle_to_canvas]Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a rectangle
			love.graphics.rectangle(mode, x, y, width, height)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_rounded_rectangle_to_canvas = function(self, num, mode, x, y, width, height, rx, ry, segments, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong height for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_rounded_rectangle_to_canvas]Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw a rectangle
			love.graphics.rectangle(mode, x, y, width, height, rx, ry, segments)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_circle_to_canvas = function(self, num, mode, x, y, radius, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_circle_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("[draw_circle_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[draw_circle_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[draw_circle_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(radius, "number") then minGUI_error_message("[draw_circle_to_canvas]Wrong radius for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_circle_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_circle_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_circle_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_circle_to_canvas]Wrong alpha color for gadget " .. num); return end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)

			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw the polygon
			love.graphics.polygon(mode, vertices)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		draw_polygon_to_canvas = function(self, num, mode, vertices, color)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI_error_message("[draw_polygon_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI_error_message("[draw_polygon_to_canvas]Wrong mode for gadget " .. num); return end
			if vertices == nil then minGUI_error_message("[draw_polygon_to_canvas]Wrong vertice value for gadget " .. num); return end
			for i = 1, #vertices do
				if type(vertices[i]) ~= "number" then minGUI_error_message("[draw_polygon_to_canvas]Wrong vertice value for gadget " .. num); return end
			end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI_error_message("[draw_polygon_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI_error_message("[draw_polygon_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI_error_message("[draw_polygon_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI_error_message("[draw_polygon_to_canvas]Wrong alpha color for gadget " .. num); return end
					
			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- can't draw in an other gadget than a canvas
			if minGUI.gtree[num].tp ~= MG_CANVAS then return end

			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
			
			-- set color
			love.graphics.setColor(color.r, color.g, color.b, color.a)
			
			-- draw the polygon
			love.graphics.polygon(mode, vertices)
			
			-- restore white color
			love.graphics.setColor(1, 1, 1, 1)

			-- draw on the screen
			love.graphics.setCanvas()
		end,
		get_gadget_x = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_x]Wrong num value"); return end
			
			return minGUI.gtree[num].x
		end,
		get_gadget_y = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_y]Wrong num value"); return end
			
			return minGUI.gtree[num].y
		end,
		get_gadget_width = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_width]Wrong num value"); return end
			
			return minGUI.gtree[num].width
		end,
		get_gadget_height = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_gadget_height]Wrong num value"); return end
			
			return minGUI.gtree[num].height
		end,
		get_cursor_position = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("[get_cursor_position]Wrong num value"); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- for editor gadget...
			if minGUI.gtree[num].tp == MG_EDITOR then
				-- separate sentences
				local t = {}
			
				t = minGUI_explode(minGUI.gtree[num].text, "\n")
			
				if minGUI.gtree[num].cursory > #t then minGUI.gtree[num].cursory = #t end

				-- start pos is zero
				minGUI.gtree[num].position = 0
			
				for i = 0, minGUI.gtree[num].cursory - 1 do
					minGUI.gtree[num].position = minGUI.gtree[num].position + utf8.len(t[i + 1])
				end
			
				minGUI.gtree[num].position = minGUI.gtree[num].position + minGUI.gtree[num].cursorx
			end
		end,
		set_cursor_xy = function(self, num, x, y)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI_error_message("[set_cursor_xy]Wrong num value"); return end
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[set_cursor_xy]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[set_cursor_xy]Wrong y for gadget " .. num); return end

			-- the gadget must exists
			if minGUI.gtree[num] == nil then return end
			
			-- for editor gadget...
			if minGUI.gtree[num].tp == MG_EDITOR then
				if x == nil then x = 0 end
				if y == nil then y = 0 end
			
				-- set cursor position by coordinates
				minGUI.gtree[num].cursorx = x
				minGUI.gtree[num].cursory = y

				-- separate sentences
				local t = {}
	
				t = minGUI_explode(minGUI.gtree[num].text, "\n")
				
				-- correction of y
				if y == -1 then
					y = #t - 1
					minGUI.gtree[num].cursory = y
				end			

				-- correction of x
				if x == -1 then
					if t[y + 1] == nil then
						minGUI.gtree[num].cursorx = 0
					else
						minGUI.gtree[num].cursorx = utf8.len(t[y + 1])
					end
				end
			
				minGUI:get_cursor_position(num)
			end
		end,
		-- add a window to the gadget's tree
		add_window = function(self, x, y, width, height, title, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget
			
			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_window]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_window]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_window]Wrong width  for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_window]Wrong height  for gadget " .. num); return end
			if not minGUI_check_param2(title, "string") then minGUI_error_message("[add_window]Wrong title for gadget " .. num); return end
			
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_window]Wrong flags  for gadget" .. num)
				return
			end

			-- centered window ?
			if minGUI_flag_active(flags, MG_FLAG_WINDOW_CENTERED) then
				w, h = love.graphics.getDimensions()

				x = math.floor((w - width) / 2)
				y = math.floor((h - height) / 2)
			end

			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_WINDOW, x = x, y = y, width = width, height = height, title = title, flags = flags, parent = parent, down = {left = false, right = false},
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = true,
							can_have_menu = true,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_window]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_window]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_window]Gadget already exists " .. num)
				return
			end
		end,
		-- add a panel to the gadget's tree
		add_panel = function(self, x, y, width, height, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget
			
			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_panel]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_panel]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_panel]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_panel]Wrong height for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_panel]Wrong flags for gadget " .. num)
				return
			end

			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_PANEL, x = x, y = y, width = width, height = height, flags = flags, parent = parent, down = {left = false, right = false},
							can_have_sons = true,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_panel]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_panel]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_panel]Gadget already exists " .. num)
				return
			end
		end,
		-- add a button to the gadgets's tree
		add_button = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_button]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_button]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_button]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_button]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("[add_button]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_button]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_button]Wrong flags  for gadget" .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_BUTTON, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent, down = {left = false, right = false},
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_button]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_button]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_button]Gadget already exists " .. num)
				return
			end
		end,
		-- add a button image to the gadgets's tree
		add_button_image = function(self, x, y, width, height, image, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_button_image]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_button_image]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_button_image]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_button_image]Wrong height for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_button_image]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_button_image]Wrong flags  for gadget" .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_BUTTON_IMAGE, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent, down =  {left = false, right = false},
							image = image,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_button_image]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_button_image]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_button_image]Gadget already exists " .. num)
				return
			end
		end,
		-- add a label to the gadgets's tree
		add_label = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("[add_label]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("[add_label]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_label]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_label]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI_error_message("[add_label]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_label]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_label]Wrong flags  for gadget" .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- default alignement to left
			if flags == nil then
				flags = MG_FLAG_ALIGN_LEFT
			elseif type(flags) == "number" then
				flags = bit.band(flags, MG_FLAG_ALIGN_CENTER)
							
				if flags == 0 then flags = MG_FLAG_ALIGN_LEFT end
			else
				minGUI_error_message("[add_label]Wrong flags for gadget " .. num)
				return
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_LABEL, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rpaper = minGUI.bgcolor.r, gpaper = minGUI.bgcolor.g, bpaper = minGUI.bgcolor.b, apaper = minGUI.bgcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_label]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_label]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_label]Gadget already exists " .. num)
				return
			end
		end,
		-- add an editable string gadget to the gadgets's tree
		add_string = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("[add_string]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("[add_string]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_string]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_string]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI_error_message("[add_string]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_string]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_string]Wrong flags for gadget " .. num)
				return
			end
			
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						-- editable by default
						if flags == nil then flags = 0 end
						
						minGUI.gtree[num] = {
							num = num, tp = MG_STRING, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rborder = minGUI.txtcolor.r, gborder = minGUI.txtcolor.g, bborder = minGUI.txtcolor.b, aborder = minGUI.txtcolor.a,
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpapergreyed = minGUI.greyedcolor.r, gpapergreyed = minGUI.greyedcolor.g, bpapergreyed = minGUI.greyedcolor.b, apapergreyed = minGUI.greyedcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							offset = 0, editable = true, backspace = 0,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width - 4, height - 4),
							cursor_canvas = love.graphics.newCanvas(1, 1)
						}
						
						-- set to not editable ?
						if minGUI_flag_active(flags, MG_FLAG_NOT_EDITABLE) then
							minGUI.gtree[num].editable = false
						end
						
						-- shift text left, if needed
						minGUI_shift_text(num, text)
						
						-- set the focus to the last editable gadget
						minGUI.gfocus = num
						
						return num
					else
						minGUI_error_message("[add_string]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_string]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_string]Gadget already exists " .. num)
				return
			end
		end,
		-- add a canvas gadget to the gadgets's tree
		add_canvas = function(self, x, y, width, height, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("[add_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("[add_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_canvas]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_canvas]Wrong height for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_canvas]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_canvas]Wrong flags for gadget " .. num)
				return
			end
			
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_CANVAS, x = x, y = y, width = width, height = height, flags = flags, parent = parent, down = {left = false, right = false},
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_canvas]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_canvas]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_canvas]Gadget already exists " .. num)
				return
			end
			
			-- draw on the canvas
			love.graphics.setCanvas(minGUI.gtree[num].canvas)
		
			-- fill the canvas in white
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("fill", 0, 0, minGUI.gtree[num].width, minGUI.gtree[num].height)
	
			-- draw on the screen
			love.graphics.setCanvas()
		end,
		-- add a checkbox to the gadgets's tree
		add_checkbox = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_checkbox]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_checkbox]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_checkbox]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_checkbox]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("[add_checkbox]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_checkbox]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_checkbox]Wrong flags for gadget " .. num)
				return
			end			

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_CHECKBOX, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							checked = false,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_checkbox]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_checkbox]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_checkbox]Gadget already exists " .. num)
				return
			end
		end,
		-- add an option gadget to the gadgets's tree
		add_option = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_option]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_option]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_option]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_option]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI_error_message("[add_option]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_option]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_option]Wrong flags for gadget " .. num)
				return
			end			

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_OPTION, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							checked = false,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_option]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_option]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_option]Gadget already exists for gadget " .. num)
				return
			end
		end,
		-- add a spin gadget to the gadgets's tree
		add_spin = function(self, x, y, width, height, value, minValue, maxValue, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_spin]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_spin]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_spin]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_spin]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI_error_message("[add_spin]Wrong value for gadget " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI_error_message("[add_spin]Wrong min value for gadget " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI_error_message("[add_spin]Wrong max value for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_spin]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_spin]Wrong flags for gadget " .. num)
				return
			end			

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if value == nil then value = 0 end
			if minValue == nil then minValue = 0 end
			if maxValue == nil then maxValue = 9 end

			-- correction of value...
			minValue = math.floor(minValue + 0.5)
			maxValue = math.floor(maxValue + 0.5)
			
			local value = math.min(math.max(math.floor(value + 0.5), minValue), maxValue)
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_SPIN, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
							down = {left = false, right = false}, btnUp = false, btnDown = false,
							text = tostring(value), minValue = minValue, maxValue = maxValue, timer = 0,
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							offset = 0, backspace = 0, press = 0,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height),
							cursor_canvas = love.graphics.newCanvas(1, 1)
						}
												
						-- shift text left, if needed
						minGUI_shift_text(num, text)

						-- set the focus to the last editable gadget
						minGUI.gfocus = num
						
						return num
					else
						minGUI_error_message("[add_spin]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_spin]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_spin]Gadget already exists " .. num)
				return
			end
		end,
		-- add an editor gadget to the gadgets's tree
		add_editor = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI_error_message("[add_editor]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI_error_message("[add_editor]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_editor]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_editor]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI_error_message("[add_editor]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_editor]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_editor]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						-- editable by default
						if flags == nil then flags = 0 end
						
						minGUI.gtree[num] = {
							num = num, tp = MG_EDITOR, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rborder = minGUI.txtcolor.r, gborder = minGUI.txtcolor.g, bborder = minGUI.txtcolor.b, aborder = minGUI.txtcolor.a,
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpapergreyed = minGUI.greyedcolor.r, gpapergreyed = minGUI.greyedcolor.g, bpapergreyed = minGUI.greyedcolor.b, apapergreyed = minGUI.greyedcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							editable = true, cursorx = 0, cursory = 0, position = 0,
							backspace = 0, delete = 0, up = 0, down = 0, left = 0, right = 0, ret = 0,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width - 4, height - 4),
							cursor_canvas = love.graphics.newCanvas(1, 1)
						}
						
						-- set to not editable ?
						if minGUI_flag_active(flags, MG_FLAG_NOT_EDITABLE) then
							minGUI.gtree[num].editable = false
						end

						-- add internal scrollbars ?
						if minGUI_flag_active(flags, MG_FLAG_NO_SCROLLBARS) then
							-- no internal scrollbars
						else
							minGUI:add_internal_scrollbar(minGUI.gtree[num].width - MG_SCROLLBAR_SIZE, 0, MG_SCROLLBAR_SIZE, minGUI.gtree[num].height - MG_SCROLLBAR_SIZE, 0, 0, 1, 1, MG_FLAG_SCROLLBAR_VERTICAL, num)
							minGUI:add_internal_scrollbar(0, minGUI.gtree[num].height - MG_SCROLLBAR_SIZE, minGUI.gtree[num].width - MG_SCROLLBAR_SIZE, MG_SCROLLBAR_SIZE, 0, 0, 1, 1, nil, num)
							minGUI:add_internal_box(minGUI.gtree[num].width - MG_SCROLLBAR_SIZE, minGUI.gtree[num].height - MG_SCROLLBAR_SIZE, nil, num)
						end
						
						-- set the focus to the last editable gadget
						minGUI.gfocus = num
						
						-- position cursor at end
						minGUI:set_cursor_xy(num, -1, -1)
						
						return num
					else
						minGUI_error_message("[add_editor]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_editor]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_editor]Gadget already exists " .. num)
				return
			end
		end,
		-- add a scrollbar gadget to the gadgets's tree
		add_scrollbar = function(self, x, y, width, height, value, minValue, maxValue, inc, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_scrollbar]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_scrollbar]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_scrollbar]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_scrollbar]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI_error_message("[add_scrollbar]Wrong value for gadget " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI_error_message("[add_scrollbar]Wrong min value for gadget " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI_error_message("[add_scrollbar]Wrong max value for gadget " .. num); return end
			if not minGUI_check_param2(inc, "number") then minGUI_error_message("[add_scrollbar]Wrong increment value for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_scrollbar]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_scrollbar]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if value == nil then value = 0 end
			if minValue == nil then minValue = 0 end
			if inc == nil then inc = 1 end
			
			stepsValue = math.floor((maxValue - minValue) / inc) + 1
			
			if stepsValue < 1 then stepsValue = 1 end

			local size = height
			local internalBarSize = 0
			
			local real_width = width
			local real_height = height

			-- vertical or horizontal scrollbar ?
			if minGUI_flag_active(flags, MG_FLAG_SCROLLBAR_VERTICAL) then
				if maxValue == nil then maxValue = height end

				-- get buttons size
				size = width
				
				-- fix real height
				real_height = height - (size * 2)
				internalBarSize = real_height
			else
				if maxValue == nil then maxValue = width end				

				-- get buttons size
				size = height
				
				-- fix real width
				real_width = width - (size * 2)
				internalBarSize = real_width
			end
			
			-- correction of value...
			minValue = math.floor(minValue + 0.5)
			maxValue = math.floor(maxValue + 0.5)

			-- set the value of the gadget
			local lng1 = (maxValue - minValue)
			local lng2 = lng1 / stepsValue
						
			value = value - minValue
			value = math.floor(value / lng2)
			value = value * lng1 / (stepsValue - 1)
			value = value + minValue
			value = math.min(math.max(value, minValue), maxValue)

			-- calculate button's other size
			local min_size = internalBarSize / stepsValue
			local size_width = math.max(min_size, MG_MIN_SCROLLBAR_BUTTON_SIZE)
			local size_height = size
			
			-- swap size_width & size_height ?
			if minGUI_flag_active(flags, MG_FLAG_SCROLLBAR_VERTICAL) then
				local swap = size_height
				size_height = size_width
				size_width = swap
			end
							
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_SCROLLBAR, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
							down = false, down1 = false, down2 = false,
							real_width = real_width, real_height = real_height, size = size, internalBarSize = internalBarSize,
							size_width = size_width, size_height = size_height, min_size = min_size,
							value = value, minValue = minValue, maxValue = maxValue, stepsValue = stepsValue, inc = inc,
							timer = 0,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(real_width, real_height),
							canvas1 = love.graphics.newCanvas(size, size),
							canvas2 = love.graphics.newCanvas(size, size),
							canvas3 = love.graphics.newCanvas(size_width, size_height)
						}
						
						return num
					else
						minGUI_error_message("[add_scrollbar]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_scrollbar]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI_error_message("[add_scrollbar]Gadget already exists " .. num)
				return
			end			
		end,
		-- add an image to the gadgets's tree
		add_image = function(self, x, y, width, height, image, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.ext_gadget = minGUI.ext_gadget + 1
			
			local num = minGUI.ext_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_image]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_image]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_image]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_image]Wrong height for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_image]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_image]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.gtree[num] = {
							num = num, tp = MG_IMAGE, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent, down =  {left = false, right = false},
							image = image,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI_error_message("[add_image]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI_error_message("[add_image]Wrong gadget parent for gadget " .. num)
				return
				end
			else
				minGUI_error_message("[add_image]Gadget already exists " .. num)
				return
			end
		end,
		-- add an internal scrollbar gadget to the internal's gadgets tree
		add_internal_scrollbar = function(self, x, y, width, height, value, minValue, maxValue, inc, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.int_gadget = minGUI.int_gadget + 1
			
			local num = minGUI.int_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong value for gadget " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong min value for gadget " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong max value for gadget " .. num); return end
			if not minGUI_check_param2(inc, "number") then minGUI_error_message("[add_internal_scrollbar]Wrong increment value for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_internal_scrollbar]Wrong parent for gadget " .. num); return end
			
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_internal_scrollbar]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if value == nil then value = 0 end
			if minValue == nil then minValue = 0 end
			if inc == nil then inc = 1 end
			
			stepsValue = math.floor((maxValue - minValue) / inc) + 1
			
			if stepsValue < 1 then stepsValue = 1 end

			local size = height
			local internalBarSize = 0
			
			local real_width = width
			local real_height = height

			-- vertical or horizontal scrollbar ?
			if minGUI_flag_active(flags, MG_FLAG_SCROLLBAR_VERTICAL) then
				if maxValue == nil then maxValue = height end

				-- get buttons size
				size = width
				
				-- fix real height
				real_height = height - (size * 2)
				internalBarSize = real_height
			else
				if maxValue == nil then maxValue = width end				

				-- get buttons size
				size = height
				
				-- fix real width
				real_width = width - (size * 2)
				internalBarSize = real_width
			end
			
			-- correction of value...
			minValue = math.floor(minValue + 0.5)
			maxValue = math.floor(maxValue + 0.5)

			-- set the value of the gadget
			local lng1 = (maxValue - minValue)
			local lng2 = lng1 / stepsValue
						
			value = value - minValue
			value = math.floor(value / lng2)
			value = value * lng1 / (stepsValue - 1)
			value = value + minValue
			value = math.min(math.max(value, minValue), maxValue)

			-- calculate button's other size
			local min_size = internalBarSize / stepsValue
			local size_width = math.max(min_size, MG_MIN_SCROLLBAR_BUTTON_SIZE)
			local size_height = size
			
			-- swap size_width & size_height ?
			if minGUI_flag_active(flags, MG_FLAG_SCROLLBAR_VERTICAL) then
				local swap = size_height
				size_height = size_width
				size_width = swap
			end
							
			-- initialize values
			if minGUI.igtree[num] == nil then
				if parent == nil or minGUI.gtree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.igtree[num] = {
							num = num, tp = MG_INTERNAL_SCROLLBAR, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
							down = false, down1 = false, down2 = false,
							real_width = real_width, real_height = real_height, size = size, internalBarSize = internalBarSize,
							size_width = size_width, size_height = size_height, min_size = min_size,
							value = value, minValue = minValue, maxValue = maxValue, stepsValue = stepsValue, inc = inc,
							timer = 0,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(real_width, real_height),
							canvas1 = love.graphics.newCanvas(size, size),
							canvas2 = love.graphics.newCanvas(size, size),
							canvas3 = love.graphics.newCanvas(size_width, size_height)
						}												
					else
						minGUI_error_message("[add_internal_scrollbar]Wrong gadget size for gadget " .. num)
					end
				else
					minGUI_error_message("[add_internal_scrollbar]Wrong gadget parent for gadget " .. num)
				end
			else
				minGUI_error_message("[add_internal_scrollbar]Gadget already exists " .. num)
			end			
		end,
		add_internal_box = function(self, x, y, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.int_gadget = minGUI.int_gadget + 1
			
			local num = minGUI.int_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_internal_box]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_internal_box]Wrong y for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_internal_box]Wrong parent for gadget " .. num); return end
	
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_internal_box]Wrong flags for gadget " .. num)
				return
			end

			width = MG_SCROLLBAR_SIZE
			height = MG_SCROLLBAR_SIZE
			
			-- initialize values
			if minGUI.igtree[num] == nil then
				if parent == nil or minGUI.gtree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.igtree[num] = {
							num = num, tp = MG_INTERNAL_BOX, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
					else
						minGUI_error_message("[add_internal_box]Wrong gadget size for gadget " .. num)
					end
				else
					minGUI_error_message("[add_internal_box]Wrong gadget parent for gadget " .. num)
				end
			else
				minGUI_error_message("[add_internal_box]Gadget already exists " .. num)
			end
		end,
		-- add a menu to the gadgets's tree
		add_menu = function(self, x, y, width, height, array, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			minGUI.int_gadget = minGUI.int_gadget + 1
			
			local num = minGUI.int_gadget

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI_error_message("[add_menu]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI_error_message("[add_menu]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI_error_message("[add_menu]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI_error_message("[add_menu]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(array, "table") then minGUI_error_message("[add_menu]Wrong array for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI_error_message("[add_menu]Wrong parent for gadget " .. num); return end
	
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI_error_message("[add_internal_menu]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end

			if array == nil then
				minGUI_error_message("[add_menu]Wrong menu array for gadget " .. num)
				return
			end
			
			-- initialize values
			if minGUI.igtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.igtree[num] = {
							num = num, tp = MG_INTERNAL_MENU, x = x, y = y, width = width, height = height, array = array, flags = flags, parent = parent, down = {left = false, right = false}, menu = {selected = 0, hover = 0},
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height),
							canvas1 = love.graphics.newCanvas(width, 1)
						}
					else
						minGUI_error_message("[add_menu]Wrong gadget size for gadget " .. num)
					end
				else
					minGUI_error_message("[add_menu]Wrong gadget parent for gadget " .. num)
				end
			else
				minGUI_error_message("[add_menu]Gadget already exists " .. num)
			end
		end

	}
	
	-- set events to default
	minGUI.mouse.x, minGUI.mouse.y = love.mouse.getPosition()
	
	for i = 1, 3 do
		minGUI.mouse.oldmbtn[i] = false
		minGUI.mouse.mbtn[i] = love.mouse.isDown(i)
		minGUI.mouse.mpressed[i] = false
		minGUI.mouse.mreleased[i] = false
	end
	
	-- load all sprites for the theme
	minGUI.load_sprites()

	-- load default fonts
	minGUI.font[MG_DEFAULT_FONT] = love.graphics.newFont(12)
end
