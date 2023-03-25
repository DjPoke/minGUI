--================
-- minGUI example
--
-- by DjPoke
-- (c) 2023
--================

-- require minGUI
require "minGUI.minGUI"

-- default love.load function
function love.load()
	-- initialize minGUI
	minGUI_init()
	
	-- set background color
	minGUI:set_bgcolor(0.5, 0.5, 0.5, 1)

	-- add panels
	minGUI:add_panel(1, 10, 120, 300, 100)
	minGUI:add_panel(2, 320, 120, 300, 120)
	
	-- add gadgets
	minGUI:add_button(1, 10, 10, 80, 25, "Button 1", 1)
	minGUI:add_label(2, 10, 40, 80, 25, "Label 1", nil, 1)
	minGUI:add_string(3, 10, 70, 80, 25, "String 1", nil, 1)
	minGUI:add_canvas(4, 100, 10, 160, 80, nil, 1)
	
	minGUI:add_button(5, 10, 10, 80, 25, "Button 2")
	minGUI:add_label(6, 10, 40, 80, 25, "Label 2")
	minGUI:add_string(7, 10, 70, 80, 25, "String 2")
	minGUI:add_canvas(8, 100, 10, 160, 80)

	minGUI:add_checkbox(9, 10, 10, 100, 25, "Checkbox 1", 2)
	minGUI:add_checkbox(10, 10, 35, 100, 25, "Checkbox 2", 2)

	minGUI:add_checkbox(11, 280, 10, 100, 25, "Checkbox 3")
	minGUI:add_checkbox(12, 280, 35, 100, 25, "Checkbox 4")

	minGUI:add_option(13, 10, 60, 100, 25, "Option 1", 2)
	minGUI:add_option(14, 10, 85, 100, 25, "Option 2", 2)

	minGUI:add_option(15, 280, 60, 100, 25, "Option 3")
	minGUI:add_option(16, 280, 85, 100, 25, "Option 4")

	minGUI:add_button_image(17, 120, 10, 80, 40, love.graphics.newImage("image.png"), 2)

	minGUI:add_spin(18, 120, 60, 60, 25, 1, 1, 100, 2)
	minGUI:add_spin(19, 390, 10, 60, 25, 1, 1, 100)
	
	minGUI:add_editor(20, 10, 260, 620, 200, "Sentence 1\nSentence 2\nSentence 3\nSentence 4\nSentence 5\nSentence 6\nSentence 7\nSentence 8")

	minGUI:add_canvas(21, 390, 60, 100, 25)
	
	-- clear the canvas in black
	minGUI:clear_canvas(4, 0, 0, 0, 1)
	minGUI:clear_canvas(8, 0, 0, 0, 1)
	
	-- draw the shape in the canvas
	minGUI:draw_rectangle_to_canvas(4, "line", 10, 10, 30, 30, {r = 1, g = 0, b = 0, a = 1})
	minGUI:draw_rectangle_to_canvas(8, "fill", 10, 10, 30, 30, {r = 1, g = 0, b = 0, a = 1})

	-- draw an image in the canvas
	minGUI:draw_image_to_canvas(8, love.graphics.newImage("image.png"), 50, 10)
	
	-- check some gadgets
	minGUI:set_gadget_state(9, true)
	minGUI:set_gadget_state(13, true)
	
	-- show timer value
	timer = 0

	minGUI:clear_canvas(21, 1, 1, 1, 1)			
	minGUI:draw_text_to_canvas(21, tostring(timer), 1, 4, {0, 0, 0, 1})

	-- add a timer shown in the canvas 21
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
		if eventGadget == 1 then
			minGUI:set_gadget_text(3, "")
		elseif eventGadget == 5 then
			minGUI:set_gadget_text(7, "")
		elseif eventGadget == 17 then
			love.event.quit(0)
		end
	end

	-- get new timers events
	local eventTimer, eventType = minGUI:get_timer_events()
	
	-- if a timer has changed
	if eventType == MG_EVENT_TIMER_TICK then
		if eventTimer == 1 then
			timer = timer + 1
			
			minGUI:clear_canvas(21, 1, 1, 1, 1)
			minGUI:draw_text_to_canvas(21, tostring(timer), 1, 4, {0, 0, 0, 1})
		end
	end
end

-- default love.draw function
function love.draw()
	-- draw created gadgets from minGUI
	minGUI_draw_all()
end
