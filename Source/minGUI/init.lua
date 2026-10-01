-- function to call from love.load()
function minGUI_init()
	-- disable blur
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	-- constants:
	MG_WINDOW_TITLEBAR_HEIGHT = 25
	MG_WINDOW_BORDER_WIDTH = 4
	MG_WINDOW_FOOTERBAR_HEIGHT = 25
	MG_WINDOW_MINIMAL_WIDTH = 256
	MG_WINDOW_MINIMAL_HEIGHT = 128
	
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
	MG_SCROLLAREA = 14
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
	MG_FLAG_WINDOW_BUTTONS = 2 + 4 + 8
	MG_FLAG_WINDOW_MOVABLE = 16
	MG_FLAG_WINDOW_TOP_PRIORITY = 32
	MG_FLAG_WINDOW_CENTERED = 64

	MG_FLAG_NOT_EDITABLE = 1
	MG_FLAG_NO_SCROLLBARS = 2

	MG_FLAG_SCROLLBAR_HORIZONTAL = 0
	MG_FLAG_SCROLLBAR_VERTICAL = 1

	MG_FLAG_ALIGN_LEFT = 1
	MG_FLAG_ALIGN_RIGHT = 2
	MG_FLAG_ALIGN_CENTER = 3

	MG_FLAG_DRAG_DROPPABLE = 4
	
	-- events
	MG_EVENT_LEFT_MOUSE_PRESSED = 1
	MG_EVENT_LEFT_MOUSE_DOWN = 2
	MG_EVENT_LEFT_MOUSE_RELEASED = 3
	MG_EVENT_LEFT_MOUSE_CLICK = 3

	MG_EVENT_RIGHT_MOUSE_PRESSED = 4
	MG_EVENT_RIGHT_MOUSE_DOWN = 5
	MG_EVENT_RIGHT_MOUSE_RELEASED = 6
	MG_EVENT_RIGHT_MOUSE_CLICK = 6
	MG_EVENT_DRAG_DROPPED = 7
	
	MG_EVENT_TIMER_TICK = 1

	-- scrollbars
	MG_MIN_SCROLLBAR_BUTTON_SIZE = 3
	
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
		greyedbgcolor = {r = 0.75, g = 0.75, b = 0.75, a = 1}, -- greyed background color
		greyedtxtcolor = {r = 0.25, g = 0.25, b = 0.25, a = 1}, -- greyed text color
		gtree = {}, -- gadgets indexed by stable ID
		lastGadgetID = 0,
		mouse = {x = 0, y = 0, oldmbtn = {}, mbtn = {}, mpressed = {}, mreleased = {}}, -- mouse events
		gstack = {}, -- gadget events stack
		mstack = {}, -- menu events stack
		ptimer = {}, -- programmable timers
		tstack = {}, -- timers events stack
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
		-- runtime error, show error and quit app
		runtime_error = function(self, message)
			love.window.showMessageBox("error", message, "error", true)
			minGUI.exitProcess = true
	
			love.event.quit()
		end,
		-- start a timer, with a delay in milliseconds
		start_timer = function(self, num, delay)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[start_timer]Wrong num value"); return end
			if not minGUI_check_param(delay, "number") or delay <= 0 or delay ~= delay or delay == math.huge then minGUI:runtime_error("[start_timer]Wrong delay value"); return end
			
			minGUI.ptimer[num] = {delay = delay, timer = math.floor(minGUI.timer * 1000)}
		end,
		-- stop a timer
		stop_timer = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[stop_timer]Wrong num value"); return end

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

			if not minGUI_check_param(text, "string") then minGUI:runtime_error("[set_theme]Wrong theme"); return end

			minGUI.theme = text
			
			-- update theme sprites
			self:load_sprites()
		end,
		-- set background color (red, green, blue, alpha)
		set_background_color = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.bgcolor.r = r
			minGUI.bgcolor.g = g
			minGUI.bgcolor.b = b
			minGUI.bgcolor.a = a
		end,
		-- set text color (red, green, blue, alpha)
		set_text_color = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.txtcolor.r = r
			minGUI.txtcolor.g = g
			minGUI.txtcolor.b = b
			minGUI.txtcolor.a = a
		end,
		-- set inverted text color (red, green, blue, alpha)
		set_inverted_text_color = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.invtxtcolor.r = r
			minGUI.invtxtcolor.g = g
			minGUI.invtxtcolor.b = b
			minGUI.invtxtcolor.a = a
		end,
		-- set greyed background color (red, green, blue, alpha)
		set_greyed_background_color = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.greyedbgcolor.r = r
			minGUI.greyedbgcolor.g = g
			minGUI.greyedbgcolor.b = b
			minGUI.greyedbgcolor.a = a
		end,
		-- set greyed text color (red, green, blue, alpha)
		set_greyed_text_color = function(self, r, g, b, a)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.greyedtxtcolor.r = r
			minGUI.greyedtxtcolor.g = g
			minGUI.greyedtxtcolor.b = b
			minGUI.greyedtxtcolor.a = a
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
		-- get gadget events
		get_gadget_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.gstack ~= 0 then
				local eventGadget = minGUI.gstack[1].eventGadget
				local eventType = minGUI.gstack[1].eventType
				local eventSource = minGUI.gstack[1].eventSource
				local eventDrop = minGUI.gstack[1].eventDrop
				
				table.remove(minGUI.gstack, 1)

				return eventGadget, eventType, eventSource, eventDrop
			end

			return nil, nil
		end,
		-- get menu events
		get_menu_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.mstack ~= 0 then
				local eventMenu = minGUI.mstack[1].eventMenu
				local eventSubMenu = minGUI.mstack[1].eventSubMenu
				
				table.remove(minGUI.mstack, 1)

				return eventMenu, eventSubMenu
			end

			return nil, nil
		end,
		get_timer_events = function(self)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if #minGUI.tstack ~= 0 then
				local eventTimer = minGUI.tstack[1].eventTimer
				local eventType = minGUI.tstack[1].eventType
				
				table.remove(minGUI.tstack, 1)

				return eventTimer, eventType
			end

			return nil, nil
		end,
		set_focus = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			minGUI.gfocus = num
		end,
		-- Activate and raise a window within its stacking priority.
		set_window_on_top = function(self, num)
			if self.exitProcess then return end
			if type(num) ~= "number" or not self.gtree[num] or self.gtree[num].tp ~= MG_WINDOW then
				self:runtime_error("[set_window_on_top]Wrong window number " .. tostring(num))
				return
			end
			local highest = self.lastGadgetID
			for _, gadget in minGUI_each_gadget() do
				highest = math.max(highest, gadget.zOrder or 0)
			end
			-- Raise the window among its siblings, then its ancestor branch.
			local current = num
			while current do
				highest = highest + 1
				self.gtree[current].zOrder = highest
				current = self.gtree[current].parent
			end
			self.activeWindow, self.gfocus = num, nil
			self.windowDrag, self.stringDrag, self.editorDrag, self.editorScrollCapture = nil, nil, nil, nil
			for _, gadget in minGUI_each_gadget() do
				if gadget.tp == MG_INTERNAL_MENU then gadget.menu.selected, gadget.menu.hover = 0, 0 end
			end
			return num
		end,
		set_gadget_text = function(self, num, text)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[set_gadget_text]Wrong num value"); return end
			if not minGUI_check_param(text, "string") then minGUI:runtime_error("[set_gadget_text]Wrong text for gadget " .. num); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget has a text attribute...
				if minGUI.gtree[num].text ~= nil then
					-- if the gadget is a string gadget...
					if minGUI.gtree[num].tp == MG_STRING then
						-- replace the text
						minGUI.gtree[num].text = text
						minGUI.gtree[num].cursorx = utf8.len(text)
						minGUI.gtree[num].selectionAnchor = nil
						minGUI.gtree[num].keyrepeat = {}
					
						minGUI_shift_text(num, text)
					elseif minGUI.gtree[num].tp == MG_EDITOR then
						local gadget = minGUI.gtree[num]
						gadget.text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
						gadget.selectionAnchor, gadget.preferredColumn = nil, nil
						gadget.keyrepeat = {}
						minGUI_editor_set_position(gadget, utf8.len(gadget.text))
						minGUI_editor_layout(gadget, true)
					elseif minGUI.gtree[num].tp == MG_LABEL then
						-- replace the text
						minGUI.gtree[num].text = text
					-- if the gadget is a spin gadget...
					elseif minGUI.gtree[num].tp == MG_SPIN then
						-- replace the value
						minGUI.gtree[num].text = frameTextValue(math.floor((tonumber(text) or 0) + 0.5), minGUI.gtree[num].minValue, minGUI.gtree[num].maxValue)

						minGUI_shift_text(num, text)		
					end
				end
			end
		end,
		get_gadget_text = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_text]Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget has a text attribute...
				if minGUI.gtree[num].text ~= nil then
					-- if the gadget is a string gadget...
					if minGUI.gtree[num].tp == MG_STRING or minGUI.gtree[num].tp == MG_EDITOR then
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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[set_gadget_state]Wrong num value"); return end

			local gadget = self.gtree[num]
			if gadget and gadget.tp == MG_INTERNAL_SCROLLBAR then
				local editor = self.gtree[gadget.parent]
				if editor and (editor.tp == MG_EDITOR or editor.tp == MG_SCROLLAREA) then
					if type(value) ~= "number" then self:runtime_error("[set_gadget_state]Wrong state value"); return end
					minGUI_scrollable_layout(editor)
					value = math.max(0, math.min(gadget.maxValue, value))
					if minGUI_flag_active(gadget.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
						editor.scrollY = value
					else
						editor.scrollX = value
					end
					minGUI_scrollable_layout(editor)
					return
				end
			end
			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is checkable
				if minGUI.gtree[num].checked ~= nil then
					-- if the gadget is an option gadget...
					if minGUI.gtree[num].tp == MG_OPTION then
						-- uncheck all options of the same parent
						for j, w in minGUI_each_gadget() do
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
					
					if type(value) ~= "boolean" then minGUI:runtime_error("[set_gadget_state]Wrong state value"); return end
					if value == nil then value = false end

					-- check the gadget
					minGUI.gtree[num].checked = value
				else
					-- if the gadget is a scrollbar gadget...
					if minGUI.gtree[num].tp == MG_SCROLLBAR then					
						if type(value) ~= "number" then minGUI:runtime_error("[set_gadget_state]Wrong state value"); return end
						if value == nil then value = 0 end
						
						-- set the value of the gadget
						local lng1 = (minGUI.gtree[num].maxValue - minGUI.gtree[num].minValue + 1)
						local lng2 = lng1 / minGUI.gtree[num].stepsValue
						
						value = value - minGUI.gtree[num].minValue
						value = math.floor(value / lng2)
						value = value * lng2
						value = value + minGUI.gtree[num].minValue
						
						minGUI.gtree[num].value = math.min(math.max(value, minGUI.gtree[num].minValue), minGUI.gtree[num].maxValue)
					end
				end
			end
		end,
		get_gadget_state = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_state]Wrong num value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is checkable
				if minGUI.gtree[num].checked ~= nil then
					-- return the gadget state
					return minGUI.gtree[num].checked
				else
					-- if the gadget is a scrollbar gadget...
					if minGUI.gtree[num].tp == MG_SCROLLBAR or minGUI.gtree[num].tp == MG_INTERNAL_SCROLLBAR then
						return math.floor(minGUI.gtree[num].value + 0.5)
					end
				end
			end
			
			return 0
		end,
		set_gadget_attribute = function(self, num, attr, value)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[set_gadget_attribute]Wrong num value"); return end
			if not minGUI_check_param(attr, "number") then minGUI:runtime_error("[set_gadget_attribute]Wrong attribute value"); return end

			-- if the gadget exists...
			if minGUI.gtree[num] ~= nil then
				-- if the gadget is a scrollbar gadget...
				if minGUI.gtree[num].tp == MG_SCROLLBAR then					
					if type(value) ~= "number" then minGUI:runtime_error("[set_gadget_attribute]Wrong state value"); return end
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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_attribute]Wrong num value"); return end
			if not minGUI_check_param(attr, "number") then minGUI:runtime_error("[get_gadget_attribute]Wrong attribute value"); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[clear_canvas]Wrong num value"); return end
			if red == nil or red < 0.0 or red > 1.0 then minGUI:runtime_error("[clear_canvas]Wrong red color for gadget " .. num); return end
			if green == nil or green < 0.0 or green > 1.0 then minGUI:runtime_error("[clear_canvas]Wrong green color for gadget " .. num); return end
			if blue == nil or blue < 0.0 or blue > 1.0 then minGUI:runtime_error("[clear_canvas]Wrong blue color for gadget " .. num); return end
			if alpha == nil or alpha < 0.0 or alpha > 1.0 then minGUI:runtime_error("[clear_canvas]Wrong alpha color for gadget " .. num); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_text_to_canvas]Wrong num value"); return end
			if not minGUI_check_param2(text, "string") then minGUI:runtime_error("[draw_text_to_canvas]Wrong text value for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_text_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_text_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param2(scalex, "number") then minGUI:runtime_error("[draw_text_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(scaley, "number") then minGUI:runtime_error("[draw_text_to_canvas]Wrong y for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_text_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_text_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_text_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_text_to_canvas]Wrong alpha color for gadget " .. num); return end

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

			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_image_to_canvas]Wrong num value"); return end
			if image == nil then minGUI:runtime_error("[draw_image_to_canvas]Wrong image for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_image_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_image_to_canvas]Wrong y for gadget " .. num); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_quad_to_canvas]Wrong num value"); return end
			if image == nil then minGUI:runtime_error("[draw_quad_to_canvas]Wrong image for gadget " .. num); return end
			if quad == nil then minGUI:runtime_error("[draw_quad_to_canvas]Wrong quad for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_quad_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_quad_to_canvas]Wrong y for gadget " .. num); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_point_to_canvas]Wrong num value"); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_point_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_point_to_canvas]Wrong y for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_point_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_point_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_point_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_point_to_canvas]Wrong alpha color for gadget " .. num); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_line_to_canvas]Wrong num value"); return end
			if not minGUI_check_param2(x1, "number") then minGUI:runtime_error("[draw_line_to_canvas]Wrong x1 for gadget " .. num); return end
			if not minGUI_check_param2(y1, "number") then minGUI:runtime_error("[draw_line_to_canvas]Wrong y1 for gadget " .. num); return end
			if not minGUI_check_param2(x2, "number") then minGUI:runtime_error("[draw_line_to_canvas]Wrong x2 for gadget " .. num); return end
			if not minGUI_check_param2(y2, "number") then minGUI:runtime_error("[draw_line_to_canvas]Wrong y2 for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_line_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_line_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_line_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_line_to_canvas]Wrong alpha color for gadget " .. num); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(radius, "number") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong radius for gadget " .. num); return end
			if not minGUI_check_param(angle1, "number") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong 1st angle for gadget " .. num); return end
			if not minGUI_check_param(angle2, "number") then minGUI:runtime_error("[draw_arc_to_canvas]Wrong 2nd angle for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_arc_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_arc_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_arc_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_arc_to_canvas]Wrong alpha color for gadget " .. num); return end

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
			
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong height for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_rectangle_to_canvas]Wrong alpha color for gadget " .. num); return end

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

			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong height for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_rounded_rectangle_to_canvas]Wrong alpha color for gadget " .. num); return end

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

			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_circle_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI:runtime_error("[draw_circle_to_canvas]Wrong mode for gadget " .. num); return end
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[draw_circle_to_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[draw_circle_to_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(radius, "number") then minGUI:runtime_error("[draw_circle_to_canvas]Wrong radius for gadget " .. num); return end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_circle_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_circle_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_circle_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_circle_to_canvas]Wrong alpha color for gadget " .. num); return end

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

			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong num value"); return end
			if not minGUI_check_param(mode, "string") then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong mode for gadget " .. num); return end
			if vertices == nil then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong vertice value for gadget " .. num); return end
			for i = 1, #vertices do
				if type(vertices[i]) ~= "number" then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong vertice value for gadget " .. num); return end
			end
			if color.r == nil then color.r = minGUI.txtcolor.r end
			if color.g == nil then color.g = minGUI.txtcolor.g end
			if color.b == nil then color.b = minGUI.txtcolor.b end
			if color.a == nil then color.a = minGUI.txtcolor.a end
			if color.r < 0.0 or color.r > 1.0 then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong red color for gadget " .. num); return end
			if color.g < 0.0 or color.g > 1.0 then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong green color for gadget " .. num); return end
			if color.b < 0.0 or color.b > 1.0 then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong blue color for gadget " .. num); return end
			if color.a < 0.0 or color.a > 1.0 then minGUI:runtime_error("[draw_polygon_to_canvas]Wrong alpha color for gadget " .. num); return end
					
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
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_x]Wrong num value"); return end
			
			return minGUI.gtree[num].x
		end,
		get_gadget_y = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_y]Wrong num value"); return end
			
			return minGUI.gtree[num].y
		end,
		get_gadget_width = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_width]Wrong num value"); return end
			
			return minGUI.gtree[num].width
		end,
		get_gadget_height = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			-- check for values and types of values
			if not minGUI_check_param(num, "number") then minGUI:runtime_error("[get_gadget_height]Wrong num value"); return end
			
			return minGUI.gtree[num].height
		end,
		maximize_window = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			-- is it really a window ?
			if minGUI.gtree[num].tp == MG_WINDOW then
				-- restore window size
				if minGUI.gtree[num].maximized then
					minGUI.gtree[num].maximized = false
					minGUI.gtree[num].width = minGUI.gtree[num].default_width
					minGUI.gtree[num].height = minGUI.gtree[num].default_height
					minGUI.gtree[num].x = minGUI.gtree[num].default_x
					minGUI.gtree[num].y = minGUI.gtree[num].default_y
					minGUI.gtree[num].canvas = love.graphics.newCanvas(minGUI.gtree[num].width, minGUI.gtree[num].height)
				-- maximize window
				else
					minGUI.gtree[num].maximized = true
					minGUI.gtree[num].default_width = minGUI.gtree[num].width
					minGUI.gtree[num].default_height = minGUI.gtree[num].height
					minGUI.gtree[num].default_x = minGUI.gtree[num].x
					minGUI.gtree[num].default_y = minGUI.gtree[num].y
					
					local p = minGUI.gtree[num].parent
					
					if minGUI.gtree[num].parent ~= nil then
						minGUI.gtree[num].width = minGUI.gtree[p].width
						minGUI.gtree[num].height = minGUI.gtree[p].height
					else
						minGUI.gtree[num].width = love.graphics.getWidth()
						minGUI.gtree[num].height = love.graphics.getHeight()
					end

					minGUI.gtree[num].x = 0
					minGUI.gtree[num].y = 0
					minGUI.gtree[num].canvas = love.graphics.newCanvas(minGUI.gtree[num].width, minGUI.gtree[num].height)
				end
				minGUI_resize_window_menus(num)
			end
		end,
		-- return the height of the menu in the window
		window_menu_height = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local v = minGUI.gtree[num]

			if v.tp == MG_WINDOW then
				for j, w in minGUI_each_gadget() do
					if w.parent == num then
						if w.tp == MG_INTERNAL_MENU then
							return w.height
						end
					end
				end
			end
	
			return 0
		end,
		-- return the height of the titlebar for the window
		window_titlebar_height = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			local v = minGUI.gtree[num]

			if v.tp == MG_WINDOW then		
				if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_TITLEBAR) then
					return MG_WINDOW_TITLEBAR_HEIGHT
				end
			end
	
			return 0
		end,
		-- return the height of the footerbar for the window
		window_footerbar_height = function(self, num)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			local v = minGUI.gtree[num]

			if v.tp == MG_WINDOW then		
				if minGUI_flag_active(v.flags, MG_FLAG_WINDOW_RESIZE) then
					return MG_WINDOW_FOOTERBAR_HEIGHT
				end
			end
	
			return 0
		end,
		-- check if a window has the focus
		get_window_has_focus = function(self, num)
            return num == minGUI_active_window()
        end,
        get_focused_window_number = function(self)
            return minGUI_active_window()
        end,
        resize_window = function(self, num, width, height)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			-- if it's a window, resize it
			if minGUI.gtree[num].tp == MG_WINDOW then
				-- minimal window size
				if width < MG_WINDOW_MINIMAL_WIDTH then width = MG_WINDOW_MINIMAL_WIDTH end
				if height < MG_WINDOW_MINIMAL_HEIGHT then height = MG_WINDOW_MINIMAL_HEIGHT end
								
				-- maximal window size
				local p = minGUI.gtree[num].parent
				
				if p ~= nil then
					if width > minGUI.gtree[p].width - minGUI.gtree[num].x - 1 then
						width = minGUI.gtree[p].width - minGUI.gtree[num].x - 1
					end

					if height > minGUI.gtree[p].height - minGUI.gtree[num].y - 1 then
						height = minGUI.gtree[p].height - minGUI.gtree[num].y - 1
					end
				else
					if width > love.graphics.getWidth() - minGUI.gtree[num].x - 1 then
						width = love.graphics.getWidth() - minGUI.gtree[num].x - 1
					end

					if height > love.graphics.getHeight() - minGUI.gtree[num].y - 1 then
						height = love.graphics.getHeight() - minGUI.gtree[num].y - 1
					end
				end

				-- resize
				minGUI.gtree[num].width = width
				minGUI.gtree[num].height = height
				
				minGUI.gtree[num].canvas = love.graphics.newCanvas(width, height)
				minGUI_resize_window_menus(num)
			end
		end,
		-- get the offset for the internal gadget
		get_parent_internal_gadget_offset = function(self, num, tp)
            local ox, oy = minGUI_get_parent_gadget_offset(num)
            local parent = minGUI.gtree[num].parent
            if tp == MG_INTERNAL_MENU and parent then
                oy = oy - minGUI:window_menu_height(parent)
            end
            return ox, oy
        end,
		get_cursor_position = function(self, num)
			local gadget = self.gtree[num]
			if gadget and gadget.tp == MG_EDITOR then return minGUI_editor_position(gadget) end
		end,
		set_cursor_xy = function(self, num, x, y)
			local gadget = self.gtree[num]
			if not gadget or gadget.tp ~= MG_EDITOR then return end
			local lines = minGUI_explode(gadget.text, "\n")
			y = y == -1 and (#lines - 1) or (y or 0)
			y = math.max(0, math.min(#lines - 1, y))
			x = x == -1 and utf8.len(lines[y + 1]) or (x or 0)
			gadget.cursory, gadget.cursorx = y, math.max(0, math.min(utf8.len(lines[y + 1]), x))
			gadget.selectionAnchor, gadget.preferredColumn = nil, nil
			minGUI_editor_position(gadget)
			minGUI_editor_layout(gadget, true)
		end,
		-- Remove a subtree without changing IDs held by the application.
		private_delete_gadget = function(self, num)
			return self:delete_gadget(num)
		end,
		delete_gadget = function(self, num)
			if self.exitProcess then return end
			if num == nil or self.gtree[num] == nil then
				self:runtime_error("[delete_gadget]Wrong gadget number " .. tostring(num))
				return
			end
			local removed = {[num] = true}
			-- Find all descendants before changing the tree.
			for id, gadget in minGUI_each_gadget() do
				local parent = gadget.parent
				while parent ~= nil do
					if parent == num then removed[id] = true; break end
					parent = self.gtree[parent].parent
				end
			end
			for id in pairs(removed) do self.gtree[id] = nil end
			if removed[self.gfocus] then self.gfocus = nil end
			if self.gadgetDrag and removed[self.gadgetDrag.source] then self.gadgetDrag = nil end
			for index = #self.gstack, 1, -1 do
				if removed[self.gstack[index].eventGadget] or removed[self.gstack[index].eventSource] then
					table.remove(self.gstack, index)
				end
			end
		end,
		-- add a window to the gadget's tree
		add_window = function(self, x, y, width, height, title, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end
			
			local num = minGUI.lastGadgetID + 1
			
			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_window]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_window]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_window]Wrong width  for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_window]Wrong height  for gadget " .. num); return end
			if not minGUI_check_param2(title, "string") then minGUI:runtime_error("[add_window]Wrong title for gadget " .. num); return end
			
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_window]Wrong flags for gadget" .. num)
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
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_WINDOW, isInternal = false, x = x, y = y, width = width, height = height, title = title, flags = flags, parent = parent, down = {left = false, right = false},
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							rpapergreyed = minGUI.greyedbgcolor.r, gpapergreyed = minGUI.greyedbgcolor.g, bpapergreyed = minGUI.greyedbgcolor.b, apapergreyed = minGUI.greyedbgcolor.a,
							rpengreyed = minGUI.greyedtxtcolor.r, gpengreyed = minGUI.greyedtxtcolor.g, bpengreyed = minGUI.greyedtxtcolor.b, apengreyed = minGUI.greyedtxtcolor.a,
							can_have_sons = true,
							can_have_menu = true,
							maximized = false, default_x = x, default_y = y, default_width = width, default_height = height,
							resizing = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						minGUI:set_window_on_top(num)
						return num
					else
						minGUI:runtime_error("[add_window]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_window]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_window]Gadget already exists " .. num)
				return
			end
		end,
		-- add a panel to the gadget's tree
		add_panel = function(self, x, y, width, height, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1
			
			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_panel]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_panel]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_panel]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_panel]Wrong height for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_panel]Wrong flags for gadget " .. num)
				return
			end

			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_PANEL, isInternal = false, x = x, y = y, width = width, height = height, flags = flags, parent = parent, down = {left = false, right = false},
							can_have_sons = true,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_panel]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_panel]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_panel]Gadget already exists " .. num)
				return
			end
		end,
		-- Visible width/height include the internal scrollbar strips.
		add_scrollarea = function(self, x, y, width, height, realWidth, realHeight, flags, parent)
			if self.exitProcess then return end
			if type(width) ~= "number" or type(height) ~= "number" or width < 4 or height < 4
				or type(realWidth) ~= "number" or type(realHeight) ~= "number"
				or realWidth < width or realHeight < height then
				self:runtime_error("[add_scrollarea]Invalid visible or content size")
				return
			end
			local num = self:add_panel(x, y, width, height, flags, parent)
			if not num then return end
			local g = self.gtree[num]
			g.tp, g.realWidth, g.realHeight = MG_SCROLLAREA, realWidth, realHeight
			local size = math.max(1, math.min(MG_SCROLLBAR_SIZE, math.floor(math.min(width, height) / 4)))
			local horizontal, vertical = realWidth > width, realHeight > height
			-- One scrollbar can make the other axis overflow too.
			for _ = 1, 2 do
				horizontal = realWidth > width - (vertical and size or 0)
				vertical = realHeight > height - (horizontal and size or 0)
			end
			g.viewWidth = width - (vertical and size or 0)
			g.viewHeight = height - (horizontal and size or 0)
			g.maxScrollX, g.maxScrollY = realWidth - g.viewWidth, realHeight - g.viewHeight
			g.scrollX, g.scrollY = 0, 0
			if vertical then
				self:add_internal_scrollbar(g.viewWidth, 0, size, g.viewHeight, 0, 0, g.maxScrollY, 1, MG_FLAG_SCROLLBAR_VERTICAL, num)
			end
			if horizontal then
				self:add_internal_scrollbar(0, g.viewHeight, g.viewWidth, size, 0, 0, g.maxScrollX, 1, nil, num)
			end
			minGUI_scrollarea_layout(g)
			return num
		end,
		-- add a button to the gadgets's tree
		add_button = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1
			
			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_button]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_button]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_button]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_button]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI:runtime_error("[add_button]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_button]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_button]Wrong flags  for gadget" .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_BUTTON, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent, down = {left = false, right = false},
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_button]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_button]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_button]Gadget already exists " .. num)
				return
			end
		end,
		-- add a button image to the gadgets's tree
		add_button_image = function(self, x, y, width, height, image, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1
			
			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_button_image]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_button_image]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_button_image]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_button_image]Wrong height for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_button_image]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_button_image]Wrong flags  for gadget" .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_BUTTON_IMAGE, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent, down =  {left = false, right = false},
							image = image,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_button_image]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_button_image]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_button_image]Gadget already exists " .. num)
				return
			end
		end,
		-- add a label to the gadgets's tree
		add_label = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI:runtime_error("[add_label]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI:runtime_error("[add_label]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_label]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_label]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI:runtime_error("[add_label]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_label]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_label]Wrong flags  for gadget" .. num)
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
				minGUI:runtime_error("[add_label]Wrong flags for gadget " .. num)
				return
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_LABEL, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rpaper = minGUI.bgcolor.r, gpaper = minGUI.bgcolor.g, bpaper = minGUI.bgcolor.b, apaper = minGUI.bgcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_label]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_label]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_label]Gadget already exists " .. num)
				return
			end
		end,
		-- add an editable string gadget to the gadgets's tree
		add_string = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI:runtime_error("[add_string]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI:runtime_error("[add_string]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_string]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_string]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI:runtime_error("[add_string]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_string]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_string]Wrong flags for gadget " .. num)
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
						
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_STRING, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rborder = minGUI.txtcolor.r, gborder = minGUI.txtcolor.g, bborder = minGUI.txtcolor.b, aborder = minGUI.txtcolor.a,
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpapergreyed = minGUI.greyedbgcolor.r, gpapergreyed = minGUI.greyedbgcolor.g, bpapergreyed = minGUI.greyedbgcolor.b, apapergreyed = minGUI.greyedbgcolor.a,
							rpengreyed = minGUI.greyedtxtcolor.r, gpengreyed = minGUI.greyedtxtcolor.g, bpengreyed = minGUI.greyedtxtcolor.b, apengreyed = minGUI.greyedtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							offset = 0, editable = true, cursorx = utf8.len(text), overwrite = false, keyrepeat = {},
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
						minGUI:runtime_error("[add_string]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_string]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_string]Gadget already exists " .. num)
				return
			end
		end,
		-- add a canvas gadget to the gadgets's tree
		add_canvas = function(self, x, y, width, height, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI:runtime_error("[add_canvas]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI:runtime_error("[add_canvas]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_canvas]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_canvas]Wrong height for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_canvas]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_canvas]Wrong flags for gadget " .. num)
				return
			end
			
			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end

			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_CANVAS, isInternal = false, x = x, y = y, width = width, height = height, flags = flags, parent = parent, down = {left = false, right = false},
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_canvas]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_canvas]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_canvas]Gadget already exists " .. num)
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

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_checkbox]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_checkbox]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_checkbox]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_checkbox]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI:runtime_error("[add_checkbox]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_checkbox]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_checkbox]Wrong flags for gadget " .. num)
				return
			end			

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_CHECKBOX, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							checked = false,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_checkbox]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_checkbox]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_checkbox]Gadget already exists " .. num)
				return
			end
		end,
		-- add an option gadget to the gadgets's tree
		add_option = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_option]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_option]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_option]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_option]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string") then minGUI:runtime_error("[add_option]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_option]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_option]Wrong flags for gadget " .. num)
				return
			end			

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if text == nil then text = "" end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_OPTION, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							checked = false,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_option]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_option]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_option]Gadget already exists for gadget " .. num)
				return
			end
		end,
		-- add a spin gadget to the gadgets's tree
		add_spin = function(self, x, y, width, height, value, minValue, maxValue, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_spin]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_spin]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_spin]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_spin]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI:runtime_error("[add_spin]Wrong value for gadget " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI:runtime_error("[add_spin]Wrong min value for gadget " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI:runtime_error("[add_spin]Wrong max value for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_spin]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_spin]Wrong flags for gadget " .. num)
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
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_SPIN, isInternal = false, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
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
						minGUI_shift_text(num, minGUI.gtree[num].text)

						-- set the focus to the last editable gadget
						minGUI.gfocus = num
						
						return num
					else
						minGUI:runtime_error("[add_spin]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_spin]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_spin]Gadget already exists " .. num)
				return
			end
		end,
		-- add an editor gadget to the gadgets's tree
		add_editor = function(self, x, y, width, height, text, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number", 0) then minGUI:runtime_error("[add_editor]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number", 0) then minGUI:runtime_error("[add_editor]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_editor]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_editor]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(text, "string", "") then minGUI:runtime_error("[add_editor]Wrong text for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_editor]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_editor]Wrong flags for gadget " .. num)
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
						
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_EDITOR, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent,
							rborder = minGUI.txtcolor.r, gborder = minGUI.txtcolor.g, bborder = minGUI.txtcolor.b, aborder = minGUI.txtcolor.a,
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpapergreyed = minGUI.greyedbgcolor.r, gpapergreyed = minGUI.greyedbgcolor.g, bpapergreyed = minGUI.greyedbgcolor.b, apapergreyed = minGUI.greyedbgcolor.a,
							rpengreyed = minGUI.greyedtxtcolor.r, gpengreyed = minGUI.greyedtxtcolor.g, bpengreyed = minGUI.greyedtxtcolor.b, apengreyed = minGUI.greyedtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							editable = true, cursorx = 0, cursory = 0, position = 0,
							overwrite = false, keyrepeat = {}, scrollX = 0, scrollY = 0,
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
						minGUI:runtime_error("[add_editor]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_editor]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_editor]Gadget already exists " .. num)
				return
			end
		end,
		-- add a scrollbar gadget to the gadgets's tree
		add_scrollbar = function(self, x, y, width, height, value, minValue, maxValue, inc, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_scrollbar]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_scrollbar]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_scrollbar]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_scrollbar]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI:runtime_error("[add_scrollbar]Wrong value for gadget " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI:runtime_error("[add_scrollbar]Wrong min value for gadget " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI:runtime_error("[add_scrollbar]Wrong max value for gadget " .. num); return end
			if not minGUI_check_param2(inc, "number") then minGUI:runtime_error("[add_scrollbar]Wrong increment value for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_scrollbar]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_scrollbar]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if value == nil then value = 0 end
			if minValue == nil then minValue = 0 end
			if inc == nil then inc = 1 end
			
			if maxValue == nil then
				maxValue = minGUI_flag_active(flags, MG_FLAG_SCROLLBAR_VERTICAL) and height or width
			end
			if inc <= 0 or maxValue < minValue then
				self:runtime_error("[scrollbar]Invalid range or increment")
				return
			end
			local stepsValue = math.floor((maxValue - minValue) / inc) + 1
			
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
			
			if real_width <= 0 or real_height <= 0 then
				self:runtime_error("[scrollbar]Track size must be positive")
				return
			end
			-- correction of value...
			minValue = math.floor(minValue + 0.5)
			maxValue = math.floor(maxValue + 0.5)

			-- set the value of the gadget
			local lng1 = (maxValue - minValue + 1)
			local lng2 = lng1 / stepsValue
						
			value = value - minValue
			value = math.floor(value / lng2)
			value = value * lng2
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
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_SCROLLBAR, isInternal = false, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
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
						minGUI:runtime_error("[add_scrollbar]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_scrollbar]Wrong gadget parent for gadget " .. num)
					return
				end
			else
				minGUI:runtime_error("[add_scrollbar]Gadget already exists " .. num)
				return
			end			
		end,
		-- add an image to the gadgets's tree
		add_image = function(self, x, y, width, height, image, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_image]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_image]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_image]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_image]Wrong height for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_image]Wrong parent for gadget " .. num); return end

			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_image]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_IMAGE, isInternal = false, x = x, y = y, width = width, height = height, text = text, flags = flags, parent = parent, down =  {left = false, right = false},
							image = image,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
						
						return num
					else
						minGUI:runtime_error("[add_image]Wrong gadget size for gadget " .. num)
						return
					end
				else
					minGUI:runtime_error("[add_image]Wrong gadget parent for gadget " .. num)
				return
				end
			else
				minGUI:runtime_error("[add_image]Gadget already exists " .. num)
				return
			end
		end,
		-- add an internal scrollbar gadget to the internal's gadgets tree
		add_internal_scrollbar = function(self, x, y, width, height, value, minValue, maxValue, inc, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(value, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong value for gadget " .. num); return end
			if not minGUI_check_param2(minValue, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong min value for gadget " .. num); return end
			if not minGUI_check_param2(maxValue, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong max value for gadget " .. num); return end
			if not minGUI_check_param2(inc, "number") then minGUI:runtime_error("[add_internal_scrollbar]Wrong increment value for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_internal_scrollbar]Wrong parent for gadget " .. num); return end
			
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_internal_scrollbar]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end
			if value == nil then value = 0 end
			if minValue == nil then minValue = 0 end
			if inc == nil then inc = 1 end
			
			if maxValue == nil then
				maxValue = minGUI_flag_active(flags, MG_FLAG_SCROLLBAR_VERTICAL) and height or width
			end
			if inc <= 0 or maxValue < minValue then
				self:runtime_error("[scrollbar]Invalid range or increment")
				return
			end
			local stepsValue = math.floor((maxValue - minValue) / inc) + 1
			
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
			
			if real_width <= 0 or real_height <= 0 then
				self:runtime_error("[scrollbar]Track size must be positive")
				return
			end
			-- correction of value...
			minValue = math.floor(minValue + 0.5)
			maxValue = math.floor(maxValue + 0.5)

			-- set the value of the gadget
			local lng1 = (maxValue - minValue + 1)
			local lng2 = lng1 / stepsValue
						
			value = value - minValue
			value = math.floor(value / lng2)
			value = value * lng2
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
				if parent == nil or minGUI.gtree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_INTERNAL_SCROLLBAR, isInternal = true, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
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
						minGUI:runtime_error("[add_internal_scrollbar]Wrong gadget size for gadget " .. num)
					end
				else
					minGUI:runtime_error("[add_internal_scrollbar]Wrong gadget parent for gadget " .. num)
				end
			else
				minGUI:runtime_error("[add_internal_scrollbar]Gadget already exists " .. num)
			end			
		end,
		add_internal_box = function(self, x, y, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_internal_box]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_internal_box]Wrong y for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_internal_box]Wrong parent for gadget " .. num); return end
	
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_internal_box]Wrong flags for gadget " .. num)
				return
			end

			width = MG_SCROLLBAR_SIZE
			height = MG_SCROLLBAR_SIZE
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or minGUI.gtree[parent] ~= nil then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_INTERNAL_BOX, isInternal = true, x = x, y = y, width = width, height = height, flags = flags, parent = parent,
							can_have_sons = false,
							can_have_menu = false,
							canvas = love.graphics.newCanvas(width, height)
						}
					else
						minGUI:runtime_error("[add_internal_box]Wrong gadget size for gadget " .. num)
					end
				else
					minGUI:runtime_error("[add_internal_box]Wrong gadget parent for gadget " .. num)
				end
			else
				minGUI:runtime_error("[add_internal_box]Gadget already exists " .. num)
			end
		end,
		-- add a menu to the gadgets's tree
		add_menu = function(self, x, y, width, height, array, flags, parent)
			-- don't execute next instructions in case of exit process is true
			if minGUI.exitProcess == true then return end

			local num = minGUI.lastGadgetID + 1

			-- check for values and types of values
			if not minGUI_check_param2(x, "number") then minGUI:runtime_error("[add_menu]Wrong x for gadget " .. num); return end
			if not minGUI_check_param2(y, "number") then minGUI:runtime_error("[add_menu]Wrong y for gadget " .. num); return end
			if not minGUI_check_param(width, "number") then minGUI:runtime_error("[add_menu]Wrong width for gadget " .. num); return end
			if not minGUI_check_param(height, "number") then minGUI:runtime_error("[add_menu]Wrong height for gadget " .. num); return end
			if not minGUI_check_param2(array, "table") then minGUI:runtime_error("[add_menu]Wrong array for gadget " .. num); return end
			if parent ~= nil and type(parent) ~= "number" then minGUI:runtime_error("[add_menu]Wrong parent for gadget " .. num); return end
	
			-- reset flags
			if flags == nil then
				flags = 0
			elseif type(flags) ~= "number" then
				minGUI:runtime_error("[add_internal_menu]Wrong flags for gadget " .. num)
				return
			end

			if x == nil then x = 0 end
			if y == nil then y = 0 end

			if array == nil then
				minGUI:runtime_error("[add_menu]Wrong menu array for gadget " .. num)
				return
			end
			
			-- initialize values
			if minGUI.gtree[num] == nil then
				if parent == nil or (minGUI.gtree[parent] ~= nil and minGUI.gtree[parent].can_have_sons) then
					if width > 0 and height > 0 then
						minGUI.lastGadgetID = num
						minGUI.gtree[num] = {
							num = num, tp = MG_INTERNAL_MENU, isInternal = true, x = x, y = y, width = width, height = height, array = array, flags = flags, parent = parent, down = {left = false, right = false}, menu = {selected = 0, hover = 0},
							rpaper = minGUI.invtxtcolor.r, gpaper = minGUI.invtxtcolor.g, bpaper = minGUI.invtxtcolor.b, apaper = minGUI.invtxtcolor.a,
							rpen = minGUI.txtcolor.r, gpen = minGUI.txtcolor.g, bpen = minGUI.txtcolor.b, apen = minGUI.txtcolor.a,
							can_have_sons = false,
							can_have_menu = false,
							rightMargin = parent and (minGUI.gtree[parent].width - x - width) or nil,
							canvas = love.graphics.newCanvas(width, height),
							canvas1 = love.graphics.newCanvas(width, 1)
						}
						if parent then minGUI_resize_window_menus(parent) end
					else
						minGUI:runtime_error("[add_menu]Wrong gadget size for gadget " .. num)
					end
				else
					minGUI:runtime_error("[add_menu]Wrong gadget parent for gadget " .. num)
				end
			else
				minGUI:runtime_error("[add_menu]Gadget already exists " .. num)
			end
		end

	}
	
	-- set events to default values
	minGUI.mouse.x, minGUI.mouse.y = love.mouse.getPosition()
	
	for i = 1, 3 do
		minGUI.mouse.oldmbtn[i] = false
		minGUI.mouse.mbtn[i] = love.mouse.isDown(i)
		minGUI.mouse.mpressed[i] = false
		minGUI.mouse.mreleased[i] = false
	end
	
	-- load all sprites for the theme
	minGUI:load_sprites()

	-- load default fonts
	minGUI.font[MG_DEFAULT_FONT] = love.graphics.newFont(12)
end
