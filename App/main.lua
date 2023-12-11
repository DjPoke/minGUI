--================
-- minGUI example
--
-- by DjPoke
-- (MIT) 2023
--================

-- require minGUI
require "minGUI.minGUI"

-- default love.load function
function love.load()
	-- initialize minGUI
	minGUI_init()
	
	-- set background color
	minGUI:set_bgcolor(0.5, 0.5, 0.5, 1)

	-- add windows
	minGUI:add_window(1, 10, 10, 300, 200, MG_FLAG_WINDOW_TITLEBAR)
	minGUI:add_window(2, 100, 100, 640, 500, MG_FLAG_WINDOW_TITLEBAR + MG_FLAG_WINDOW_MINIMIZE_BUTTON + MG_FLAG_WINDOW_MAXIMIZE_BUTTON)
	
	-- add panels
	minGUI:add_panel(3, 10, 120, 300, 100, nil, 2)
	minGUI:add_panel(4, 320, 120, 300, 120, nil, 2)

	-- add menus
	menu_array = {
		{head_menu = "File", menu_list = {"Open", "Save", "Quit"}}
	}
	minGUI:add_menu(0, 0, 640, 24, menu_array, nil, 2)
	
	-- add gadgets
	minGUI:add_button(5, 10, 10, 80, 25, "Button 1", nil, 3)
	minGUI:add_label(6, 10, 40, 80, 25, "Label 1", nil, 3)
	minGUI:add_string(7, 10, 70, 80, 25, "String 1", nil, 3)
	minGUI:add_canvas(8, 100, 10, 160, 80, nil, 3)
	
	minGUI:add_button(9, 10, 10, 80, 25, "Button 2", nil, 2)
	minGUI:add_label(10, 10, 40, 80, 25, "Label 2", nil, 2)
	minGUI:add_string(11, 10, 70, 80, 25, "String 2", nil, 2)
	minGUI:add_canvas(12, 100, 10, 160, 80, nil, 2)

	minGUI:add_checkbox(13, 10, 10, 100, 25, "Checkbox 1", nil, 4)
	minGUI:add_checkbox(14, 10, 35, 100, 25, "Checkbox 2", nil, 4)

	minGUI:add_checkbox(15, 280, 10, 100, 25, "Checkbox 3", nil, 2)
	minGUI:add_checkbox(16, 280, 35, 100, 25, "Checkbox 4", nil, 2)

	minGUI:add_option(17, 10, 60, 100, 25, "Option 1", nil, 4)
	minGUI:add_option(18, 10, 85, 100, 25, "Option 2", nil, 4)

	minGUI:add_option(19, 280, 60, 100, 25, "Option 3", nil, 2)
	minGUI:add_option(20, 280, 85, 100, 25, "Option 4", nil, 2)

	minGUI:add_button_image(21, 120, 10, 80, 40, love.graphics.newImage("image.png"), nil, 4)

	minGUI:add_spin(22, 120, 60, 60, 25, 1, 1, 100, nil, 4)
	minGUI:add_spin(23, 390, 10, 60, 25, 1, 1, 100, nil, 2)
	
	minGUI:add_editor(24, 10, 260, 620, 200, "This is an example of editor gadget. You can use arrows, backspace,\ndelete, home, and end keys.\nW.I.P", nil, 2)

	minGUI:add_canvas(25, 390, 60, 100, 25, nil, 2)
	
	minGUI:add_scrollbar(26, 500, 5, 20, 100, 0, 0, 100, 25, MG_FLAG_SCROLLBAR_VERTICAL, 2)
	minGUI:add_scrollbar(27, 525, 5, 100, 20, 0, 0, 100, 10, MG_FLAG_SCROLLBAR_HORIZONTAL, 2)
	
	-- clear the canvas in black
	minGUI:clear_canvas(8, 0, 0, 0, 1)
	minGUI:clear_canvas(12, 0, 0, 0, 1)
	
	-- draw the shape in the canvas
	minGUI:draw_rectangle_to_canvas(8, "line", 10, 10, 30, 30, {r = 1, g = 0, b = 0, a = 1})
	minGUI:draw_rectangle_to_canvas(12, "fill", 10, 10, 30, 30, {r = 1, g = 0, b = 0, a = 1})

	-- draw an image in the canvas
	minGUI:draw_image_to_canvas(12, love.graphics.newImage("image.png"), 50, 10)
	
	-- check some gadgets
	minGUI:set_gadget_state(13, true)
	minGUI:set_gadget_state(17, true)
	
	-- show timer value
	timer = 0

	minGUI:clear_canvas(25, 1, 1, 1, 1)			
	minGUI:draw_text_to_canvas(25, tostring(timer), 1, 4, {0, 0, 0, 1})
	
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
		if eventGadget == 5 then
			minGUI:set_gadget_text(7, "")
		elseif eventGadget == 9 then
			minGUI:set_gadget_text(11, "")
		elseif eventGadget == 21 then
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
	
	minGUI:clear_canvas(25, 1, 1, 1, 1)
	minGUI:draw_text_to_canvas(25, tostring(timer), 1, 4, {0, 0, 0, 1})
	minGUI:draw_text_to_canvas(25, tostring(minGUI:get_gadget_state(26)), 30, 4, {0, 0, 0, 1})
	minGUI:draw_text_to_canvas(25, tostring(minGUI:get_gadget_state(27)), 70, 4, {0, 0, 0, 1})
end

-- default love.draw function
function love.draw()
	-- draw created gadgets from minGUI
	minGUI_draw_all()
end
