--================
-- minGUI example
--
-- by DjPoke
-- (MIT) 2023-2025
--================

-- requires
require "minGUI/minGUI"

-- default love.load function
function love.load()
	-- initialize minGUI
	minGUI_init()
	
	-- set colors
	minGUI:set_background_color(0.5, 0.5, 0.5, 1)
	minGUI:set_text_color(0, 0, 0, 1)
	minGUI:set_inverted_text_color(1, 1, 1, 1)
	minGUI:set_greyed_background_color(0.5, 0.5, 0.5, 1)
	minGUI:set_greyed_text_color(0.25, 0.25, 0.25, 1)

	-- prepare tables of windows & gadgets
	w = {}
	g = {}
	
	-- add windows
	local flags = bit.bor(MG_FLAG_WINDOW_TITLEBAR, MG_FLAG_WINDOW_BUTTONS, MG_FLAG_WINDOW_MOVABLE)
	w[1] = minGUI:add_window(10, 10, 300, 200, "Window 1", flags)
	w[2] = minGUI:add_window(100, 100, 640, 540, "Window 2", flags)
	
	-- add panels
	g[1] = minGUI:add_panel(10, 120, 300, 100, nil, w[2])
	g[2] = minGUI:add_panel(320, 120, 300, 120, nil, w[2])

	-- add menus
	menu_array = {
		{head_menu = "File", menu_list = {"Open", "Save", "Quit"}},
		{head_menu = "Help", menu_list = {"About..."}}
	}
	minGUI:add_menu(4, 0, 632, 24, menu_array, nil, w[2])
	
	-- add gadgets
	g[3] = minGUI:add_button(10, 10, 80, 25, "Button 1", nil, g[1])
	g[4] = minGUI:add_label(10, 40, 80, 25, "Label 1", nil, g[1])
	g[5] = minGUI:add_string(10, 70, 80, 25, "String 1", nil, g[1])
	g[6] = minGUI:add_canvas(100, 10, 160, 80, nil, g[1])
	
	g[7] = minGUI:add_button(10, 10, 80, 25, "Button 2", nil, w[2])
	g[8] = minGUI:add_label(10, 40, 80, 25, "Label 2", nil, w[2])
	g[9] = minGUI:add_string(10, 70, 80, 25, "String 2", nil, w[2])
	g[10] = minGUI:add_canvas(100, 10, 160, 80, nil, w[2])

	g[11] = minGUI:add_checkbox(10, 10, 100, 25, "Checkbox 1", nil, g[2])
	g[12] = minGUI:add_checkbox(10, 35, 100, 25, "Checkbox 2", nil, g[2])

	g[13] = minGUI:add_checkbox(280, 10, 100, 25, "Checkbox 3", nil, w[2])
	g[14] = minGUI:add_checkbox(280, 35, 100, 25, "Checkbox 4", nil, w[2])

	g[15] = minGUI:add_option(10, 60, 100, 25, "Option 1", nil, g[2])
	g[16] = minGUI:add_option(10, 85, 100, 25, "Option 2", nil, g[2])

	g[17] = minGUI:add_option(280, 60, 100, 25, "Option 3", nil, w[2])
	g[18] = minGUI:add_option(280, 85, 100, 25, "Option 4", nil, w[2])

	g[19] = minGUI:add_button_image(120, 10, 80, 40, love.graphics.newImage("image.png"), nil, g[2])

	g[20] = minGUI:add_spin(120, 60, 60, 25, 1, 1, 100, nil, g[2])
	g[21] = minGUI:add_spin(390, 10, 60, 25, 1, 1, 100, nil, w[2])
	
	g[22] = minGUI:add_editor(10, 260, 620, 200, "This is an example of editor gadget. You can use arrows, backspace,\ndelete, home, and end keys.\nW.I.P", nil, 2)

	g[23] = minGUI:add_canvas(390, 60, 100, 25, nil, w[2])
	
	g[24] = minGUI:add_scrollbar(500, 5, 20, 100, 0, 0, 100, 25, MG_FLAG_SCROLLBAR_VERTICAL, w[2])
	g[25] = minGUI:add_scrollbar(525, 5, 100, 20, 0, 0, 100, 10, MG_FLAG_SCROLLBAR_HORIZONTAL, w[2])
	
	-- clear the canvas in black
	minGUI:clear_canvas(g[6], 0, 0, 0, 1)
	minGUI:clear_canvas(g[10], 0, 0, 0, 1)
	
	-- draw the shape in the canvas
	minGUI:draw_rectangle_to_canvas(g[6], "line", 10, 10, 30, 30, {r = 1, g = 0, b = 0, a = 1})
	minGUI:draw_rectangle_to_canvas(g[10], "fill", 10, 10, 30, 30, {r = 1, g = 0, b = 0, a = 1})

	-- draw an image in the canvas
	minGUI:draw_image_to_canvas(g[10], love.graphics.newImage("image.png"), 50, 10)
	
	-- check some gadgets
	minGUI:set_gadget_state(g[11], true)
	minGUI:set_gadget_state(g[15], true)
	
	-- show timer value
	timer = 0

	minGUI:clear_canvas(g[23], 1, 1, 1, 1)			
	minGUI:draw_text_to_canvas(g[23], tostring(timer), 1, 4, {0, 0, 0, 1})
	
	-- add a timer shown in the canvas 25
	minGUI:start_timer(1, 1000)
end

-- default love.textinput function
function love.textinput(t)
	-- send text input to minGUI
    minGUI_textinput(t)
end

-- default love.update function
function love.update(dt)
	-- update events list for minGUI
	minGUI_update_events(dt)
	
	-- exit on escape key
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	-- get new gadgets events
	local eventGadget, eventType = minGUI:get_gadget_events()
	
	-- if button 1 has been clicked
	if eventType == MG_EVENT_LEFT_MOUSE_CLICK then
		if eventGadget == g[3] then
			minGUI:set_gadget_text(g[5], "")
		elseif eventGadget == g[7] then
			minGUI:set_gadget_text(g[9], "")
		elseif eventGadget == g[19] then
			love.event.quit(0)
		end
	end

	-- get new timers events
	local eventTimer, eventType = minGUI:get_timer_events()
	
	-- if a timer has changed
	if eventType == MG_EVENT_TIMER_TICK then
		if eventTimer == 1 then
			timer = timer + 1
		end
	end
	
	minGUI:clear_canvas(g[23], 1, 1, 1, 1)
	minGUI:draw_text_to_canvas(g[23], tostring(timer), 1, 4, {0, 0, 0, 1})
	minGUI:draw_text_to_canvas(g[23], tostring(minGUI:get_gadget_state(g[24])), 30, 4, {0, 0, 0, 1})
	minGUI:draw_text_to_canvas(g[23], tostring(minGUI:get_gadget_state(g[25])), 70, 4, {0, 0, 0, 1})
end

-- default love.draw function
function love.draw()
	-- draw created gadgets from minGUI
	minGUI_draw_all()
end
