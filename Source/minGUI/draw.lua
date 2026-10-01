-- draw a gadget
function minGUI_draw_gadget(num, ox, oy)
	local w = minGUI.gtree[num]
	
	-- get scissors from parent gadgets
	local scx, scy, scw, sch = minGUI_get_gadget_parents_scissor(minGUI.gtree[num].parent)
	
	-- draw panels
	if w.tp == MG_WINDOW then
		minGUI_draw_9slice(MG_WINDOW_IMAGE, 0, 0, w.width, w.height, w.canvas)
		
		-- draw title bar ?
		if minGUI_flag_active(w.flags, MG_FLAG_WINDOW_TITLEBAR) then
			-- only draw the titlebar if the window has the focus
			if minGUI:get_window_has_focus(num) then
				minGUI_draw_9slice(MG_TITLEBAR_IMAGE, 1, 1, w.width - 2, MG_WINDOW_TITLEBAR_HEIGHT - 1, w.canvas)
			end
			
			-- draw title
			if w.title ~= nil and w.title ~= "" then
				-- draw the text on the gadget's canvas
				love.graphics.setCanvas(w.canvas)
				
				-- if the window has the focus, set color to paper color for the gadget
				if minGUI:get_window_has_focus(num) then
					love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
				else
					love.graphics.setColor(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
				end

				-- draw filled rectangle background for the text
				love.graphics.rectangle("fill", ((w.width - minGUI.font[minGUI.numFont]:getWidth(w.title)) / 2) - 1, (MG_WINDOW_TITLEBAR_HEIGHT - minGUI.font[minGUI.numFont]:getHeight()) / 2, minGUI.font[minGUI.numFont]:getWidth(w.title) + 2, minGUI.font[minGUI.numFont]:getHeight())
				
				-- if the window has the focus, set color to pen color for the gadget
				if minGUI:get_window_has_focus(num) then
					love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
				else
					love.graphics.setColor(w.rpengreyed, w.gpengreyed, w.bpengreyed, w.apengreyed)
				end

				-- print the text centered
				love.graphics.print(w.title, (w.width - minGUI.font[minGUI.numFont]:getWidth(w.title)) / 2, (MG_WINDOW_TITLEBAR_HEIGHT - minGUI.font[minGUI.numFont]:getHeight()) / 2)
			end
			
			-- restore color
			love.graphics.setColor(1, 1, 1, 1)
			
			-- draw footerbar
			minGUI_draw_9slice(MG_TITLEBAR_IMAGE, 1, w.height - MG_WINDOW_FOOTERBAR_HEIGHT - 1, w.width - 2, MG_WINDOW_FOOTERBAR_HEIGHT - 1, w.canvas)
			
			-- draw the text on the gadget's canvas
			love.graphics.setCanvas(w.canvas)
			
			-- draw close button in the titlebar
			if minGUI_flag_active(w.flags, MG_FLAG_WINDOW_CLOSE) then
				-- only draw the button if the window has the focus
				if minGUI:get_window_has_focus(num) then
					minGUI_draw_sprite(MG_CLOSE_WINDOW_IMAGE, 0, 1)
				end
			end

			-- draw maximize button in the titlebar
			if minGUI_flag_active(w.flags, MG_FLAG_WINDOW_MAXIMIZE) then
				-- only draw the button if the window has the focus
				if minGUI:get_window_has_focus(num) then
					minGUI_draw_sprite(MG_MAXIMIZE_WINDOW_IMAGE, w.width - MG_WINDOW_TITLEBAR_HEIGHT, 1)
				end
			end

			-- draw resize button in the footerbar
			if minGUI_flag_active(w.flags, MG_FLAG_WINDOW_RESIZE) then
				-- only draw the button if the window has the focus
				if minGUI:get_window_has_focus(num) then
					minGUI_draw_sprite(MG_RESIZE_WINDOW_IMAGE, w.width - MG_WINDOW_TITLEBAR_HEIGHT, w.height - MG_WINDOW_TITLEBAR_HEIGHT - 1)
				end
			end
		end

		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- draw panels
	elseif w.tp == MG_SCROLLAREA then
		love.graphics.setScissor(scx, scy, scw, sch)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("fill", ox + w.x, oy + w.y, w.width, w.height)
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_PANEL then
		minGUI_draw_9slice(MG_PANEL_IMAGE, 0, 0, w.width, w.height, w.canvas)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- draw buttons
	elseif w.tp == MG_BUTTON then
		if not w.down.left then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, 0, 0, w.width, w.height, w.canvas)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width, w.height, w.canvas)
		end
		
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)

		-- print the text centered
		love.graphics.print(w.text, ((w.width - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2) - 1, ((w.height - minGUI.font[minGUI.numFont]:getHeight()) / 2) - 1)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- draw button images
	elseif w.tp == MG_BUTTON_IMAGE then
		if not w.down.left then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, 0, 0, w.width, w.height, w.canvas)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width, w.height, w.canvas)
		end

		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- draw the image
		if not w.down.left then
			love.graphics.draw(w.image, 4, 4, 0, (w.width - 8) / w.image:getWidth(), (w.height - 8) / w.image:getHeight())
		else
			love.graphics.draw(w.image, 3, 3, 0, (w.width - 6) / w.image:getWidth(), (w.height - 6) / w.image:getHeight())
		end
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- draw labels
	elseif w.tp == MG_LABEL then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		love.graphics.clear(w.rpaper, w.gpaper, w.bpaper, w.apaper)
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)

		-- print the text with differents alignments
		if w.wrapText then
			local align = w.flags == MG_FLAG_ALIGN_CENTER and "center" or w.flags == MG_FLAG_ALIGN_RIGHT and "right" or "left"
			love.graphics.printf(w.text, 0, 0, w.width, align)
		elseif w.flags == MG_FLAG_ALIGN_LEFT then
			love.graphics.print(w.text, 0, ((w.height - minGUI.font[minGUI.numFont]:getHeight()) / 2) - 1)
		elseif w.flags == MG_FLAG_ALIGN_RIGHT then
			love.graphics.print(w.text, w.width - minGUI.font[minGUI.numFont]:getWidth(w.text), ((w.height - minGUI.font[minGUI.numFont]:getHeight()) / 2) - 1)
		elseif w.flags == MG_FLAG_ALIGN_CENTER then
			love.graphics.print(w.text, ((w.width - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2) - 1, ((w.height - minGUI.font[minGUI.numFont]:getHeight()) / 2) - 1)
		end
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_STRING then
		minGUI_shift_text(num, w.text)
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		if w.editable == true then
			love.graphics.clear(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.clear(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		if w.editable == true then
			love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		else
			love.graphics.setColor(w.rpengreyed, w.gpengreyed, w.bpengreyed, w.apengreyed)
		end

		-- Paint the selected range and redraw its text in the inverted color.
		local font = minGUI.font[minGUI.numFont]
		local y = ((w.height - 4 - font:getHeight()) / 2) - 1
		love.graphics.print(minGUI_sub_string(w.text, w.offset + 1), 0, y)
		if minGUI.gfocus == num then
			local first, last = minGUI_string_selection(w)
			first = math.max(first, w.offset)
			if first < last then
				local x = font:getWidth(minGUI_sub_string(w.text, w.offset + 1, first))
				local selected = minGUI_sub_string(w.text, first + 1, last)
				love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
				love.graphics.rectangle("fill", x, y, font:getWidth(selected), font:getHeight())
				love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
				love.graphics.print(selected, x, y)
			end
		end

		-- restore drawing on the window's canvas
		love.graphics.setCanvas()

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)
		
		-- draw the border
		love.graphics.setColor(w.rborder, w.gborder, w.bborder, w.aborder)
		love.graphics.rectangle("line", ox + w.x, oy + w.y, w.width, w.height)
		
		-- draw 'inside' border
		if w.editable == true then
			love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.setColor(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
		
		love.graphics.rectangle("fill", ox + w.x + 1, oy + w.y + 1, w.width - 2, w.height - 2)

		-- draw the canvas
		love.graphics.setColor(1, 1, 1, 1)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x + 2, oy + w.y + 2)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_CANVAS then
		-- draw the canvas on screen
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_CHECKBOX then		
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		love.graphics.clear(minGUI.bgcolor.r, minGUI.bgcolor.g, minGUI.bgcolor.b, minGUI.bgcolor.a)
		
		-- draw checkbox button
		minGUI_draw_sprite(MG_CHECKBOX_IMAGE, 0, (w.height - 14) / 2)
		
		-- draw a black box inside if checked
		if w.checked == true then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", 4, (w.height - 5) / 2, 6, 6)
		end
	
		-- draw the text at the right of the button
		love.graphics.setFont(minGUI.font[minGUI.numFont])
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.print(w.text, 16, (w.height - minGUI.font[minGUI.numFont]:getHeight()) / 2)

		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_OPTION then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		love.graphics.clear(minGUI.bgcolor.r, minGUI.bgcolor.g, minGUI.bgcolor.b, minGUI.bgcolor.a)
	
		-- draw option button
		minGUI_draw_sprite(MG_OPTION_IMAGE, 0, (w.height - 14) / 2)

		-- draw a black box inside if checked
		if w.checked == true then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", 4, (w.height - 5) / 2, 6, 6)
		end

		-- draw the text at the right of the button
		love.graphics.setFont(minGUI.font[minGUI.numFont])
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.print(w.text, 16, (w.height - minGUI.font[minGUI.numFont]:getHeight()) / 2)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_SPIN then
		-- draw spin value
		minGUI_draw_9slice(MG_SPIN_IMAGE, 0, 0, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth() - 1, w.height, w.canvas)

		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)

		-- draw spin buttons
		local btnUp = love.graphics.newQuad(0, 0, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight())
		local btnDown = love.graphics.newQuad(0, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2, minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight())
		
		if w.btnUp == false then
			minGUI_draw_quad(MG_SPIN_BUTTON_UP_IMAGE, btnUp, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()))
		else
			minGUI_draw_quad(MG_SPIN_BUTTON_DOWN_IMAGE, btnUp, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight()))
		end

		if w.btnDown == false then
			minGUI_draw_quad(MG_SPIN_BUTTON_UP_IMAGE, btnDown, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2))
		else
			minGUI_draw_quad(MG_SPIN_BUTTON_DOWN_IMAGE, btnDown, w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth(), (w.height - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getHeight() / 2))
		end

		-- Draw the selected part of the numeric value.
		minGUI_spin_sync(w)
		local font = minGUI.font[minGUI.numFont]
		local textWidth = font:getWidth(w.text)
		local x = (w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth() - textWidth) / 2
		local y = (w.height - font:getHeight()) / 2
		love.graphics.setFont(font)
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.print(w.text, x, y)
		local first, last = minGUI_spin_selection(w)
		if minGUI.gfocus == num and first ~= last then
			local selected = minGUI_sub_string(w.text, first + 1, last)
			local sx = x + font:getWidth(minGUI_sub_string(w.text, 1, first))
			love.graphics.rectangle("fill", sx, y, font:getWidth(selected), font:getHeight())
			love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
			love.graphics.print(selected, sx, y)
		end

		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_EDITOR then
		minGUI_editor_layout(w)
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with gadget's background color
		if w.editable == true then
			love.graphics.clear(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.clear(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
	
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])
	
		-- set color to pen color for the gadget
		if w.editable == true then
			love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		else
			love.graphics.setColor(w.rpengreyed, w.gpengreyed, w.bpengreyed, w.apengreyed)
		end

		local font = minGUI.font[minGUI.numFont]
		local lines = minGUI_explode(w.text, "\n")
		local first, last = minGUI_editor_selection(w)
		local position = 0
		for row, line in ipairs(lines) do
			local y = (row - 1) * font:getHeight() - w.scrollY
			if y + font:getHeight() > 0 and y < w.viewHeight then
				if w.editable then
					love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
				else
					love.graphics.setColor(w.rpengreyed, w.gpengreyed, w.bpengreyed, w.apengreyed)
				end
				love.graphics.print(line, -w.scrollX, y)
				local start = math.max(0, first - position)
				local finish = math.min(utf8.len(line), last - position)
				if minGUI.gfocus == num and first < last and first <= position + utf8.len(line) and last > position then
					local x = font:getWidth(minGUI_sub_string(line, 1, start)) - w.scrollX
					local selected = minGUI_sub_string(line, start + 1, finish)
					local width = font:getWidth(selected)
					if last > position + utf8.len(line) then width = width + font:getWidth(' ') end
					love.graphics.rectangle('fill', x, y, width, font:getHeight())
					love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
					love.graphics.print(selected, x, y)
				end
			end
			position = position + utf8.len(line) + 1
		end

		-- restore drawing on the window's canvas
		love.graphics.setCanvas()

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		-- draw the border
		love.graphics.setColor(w.rborder, w.gborder, w.bborder, w.aborder)
		love.graphics.rectangle("line", ox + w.x, oy + w.y, w.width, w.height)
		
		-- draw 'inside' border
		if w.editable == true then
			love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
		else
			love.graphics.setColor(w.rpapergreyed, w.gpapergreyed, w.bpapergreyed, w.apapergreyed)
		end
		
		love.graphics.rectangle("fill", ox + w.x + 1, oy + w.y + 1, w.width - 2, w.height - 2)

		-- draw the canvas
		love.graphics.setColor(1, 1, 1, 1)

		-- draw
		love.graphics.draw(w.canvas, ox + w.x + 2, oy + w.y + 2)

		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_SCROLLBAR then
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			-- draw vertical scrollbar bar
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width , w.height - (w.size * 2), w.canvas)
		else
			-- draw horizontal scrollbar bar
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width - (w.size * 2), w.height, w.canvas)
		end

		-- draw scrollbar button 1
		if not w.down1 then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, 0, 0, w.size, w.size, w.canvas1)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.size, w.size, w.canvas1)
		end

		-- draw scrollbar button 2
		if not w.down2 then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, 0, 0, w.size, w.size, w.canvas2)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.size, w.size, w.canvas2)
		end
		
		-- draw scrollbar button 3
		minGUI_draw_9slice(MG_SCROLLBAR_IMAGE, 0, 0, w.size_width, w.size_height, w.canvas3)
		
		-- calculate arrows position and size
		local size = math.floor(w.size / 2)
		local x1 = math.floor((w.size - size) / 2)
		local x2 = x1 + size
		local x3 = x1 + math.floor(size / 2)

		-- calculate triangle
		local p1 = {}
		local p2 = {}
		
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			p1 = {x1, x2, x2, x2, x3, x1}
			p2 = {x1, x1, x2, x1, x3, x2}
		else
			p1 = {x2, x1, x2, x2, x1, x3}
			p2 = {x1, x1, x1, x2, x2, x3}
		end
		
		-- draw the text arrow on the gadget's canvas
		love.graphics.setCanvas(w.canvas1)
		
		-- draw the text value in its area
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.polygon("fill", p1)

		-- draw the text arrow on the gadget's canvas
		love.graphics.setCanvas(w.canvas2)
		
		-- draw the text value in its area
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.polygon("fill", p2)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)
		
		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)		
		
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			-- draw vertical scrollbar bar at screen
			love.graphics.draw(w.canvas, ox + w.x, oy + w.y + w.size)
		else
			-- draw horizontal scrollbar bar at screen
			love.graphics.draw(w.canvas, ox + w.x + w.size, oy + w.y)
		end
		
		-- calculate offset of the scrollbar central button
		local offset = w.thumbOffset or (math.floor((w.value - w.minValue) / w.inc) * w.min_size)
		
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			love.graphics.draw(w.canvas1, ox + w.x, oy + w.y)
			love.graphics.draw(w.canvas2, ox + w.x, oy + w.y + w.height - w.size)
			love.graphics.draw(w.canvas3, ox + w.x, oy + w.y + w.size + offset)
		else
			love.graphics.draw(w.canvas1, ox + w.x, oy + w.y)
			love.graphics.draw(w.canvas2, ox + w.x + w.width - w.size, oy + w.y)
			love.graphics.draw(w.canvas3, ox + w.x + w.size + offset, oy + w.y)
		end
		
		-- reset scissor			
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- draw images
	elseif w.tp == MG_IMAGE then
		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- clear the canvas with transparent color
		love.graphics.clear(0, 0, 0, 0)
		
		-- draw the image
		if not w.down.left then
			love.graphics.draw(w.image, 4, 4, 0, (w.width - 8) / w.image:getWidth(), (w.height - 8) / w.image:getHeight())
		else
			love.graphics.draw(w.image, 8, 8, 0, (w.width - 16) / w.image:getWidth(), (w.height - 16) / w.image:getHeight())
		end
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- restore color
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)		

		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function minGUI_draw_internal_gadget(num, ox, oy, popupOnly)
	local w = minGUI.gtree[num]
			
	-- get scissors from parent gadgets
	local scx, scy, scw, sch = minGUI_get_gadget_parents_scissor(w.parent, w.tp == MG_INTERNAL_MENU or (minGUI.gtree[w.parent] and minGUI.gtree[w.parent].tp == MG_SCROLLAREA))

	if w.tp == MG_INTERNAL_SCROLLBAR then
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			-- draw vertical scrollbar bar
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width , w.height - (w.size * 2), w.canvas)
		else
			-- draw horizontal scrollbar bar
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width - (w.size * 2), w.height, w.canvas)
		end

		-- draw scrollbar button 1
		if not w.down1 then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, 0, 0, w.size , w.size, w.canvas1)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.size , w.size, w.canvas1)
		end

		-- draw scrollbar button 2
		if not w.down2 then
			minGUI_draw_9slice(MG_BUTTON_UP_IMAGE, 0, 0, w.size , w.size, w.canvas2)
		else
			minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.size , w.size, w.canvas2)
		end
		
		-- draw scrollbar button 3
		minGUI_draw_9slice(MG_SCROLLBAR_IMAGE, 0, 0, w.size_width , w.size_height, w.canvas3)
		
		-- calculate arrows position and size
		local size = math.floor(w.size / 2)
		local x1 = math.floor((w.size - size) / 2)
		local x2 = x1 + size
		local x3 = x1 + math.floor(size / 2)

		-- calculate triangle
		local p1 = {}
		local p2 = {}
		
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			p1 = {x1, x2, x2, x2, x3, x1}
			p2 = {x1, x1, x2, x1, x3, x2}
		else
			p1 = {x2, x1, x2, x2, x1, x3}
			p2 = {x1, x1, x1, x2, x2, x3}
		end
		
		-- draw the text arrow on the gadget's canvas
		love.graphics.setCanvas(w.canvas1)
		
		-- draw the text value in its area
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.polygon("fill", p1)

		-- draw the text arrow on the gadget's canvas
		love.graphics.setCanvas(w.canvas2)
		
		-- draw the text value in its area
		love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
		love.graphics.polygon("fill", p2)
		
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to screen
		love.graphics.setColor(1, 1, 1, 1)
		
		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)

		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			-- draw vertical scrollbar bar at screen
			love.graphics.draw(w.canvas, ox + w.x, oy + w.y + w.size)
		else
			-- draw horizontal scrollbar bar at screen
			love.graphics.draw(w.canvas, ox + w.x + w.size, oy + w.y)
		end
		
		-- calculate offset of the scrollbar central button
		local offset = w.thumbOffset or (math.floor((w.value - w.minValue) / w.inc) * w.min_size)
		
		if minGUI_flag_active(w.flags, MG_FLAG_SCROLLBAR_VERTICAL) then
			love.graphics.draw(w.canvas1, ox + w.x, oy + w.y)
			love.graphics.draw(w.canvas2, ox + w.x, oy + w.y + w.height - w.size)
			love.graphics.draw(w.canvas3, ox + w.x, oy + w.y + w.size + offset)
		else
			love.graphics.draw(w.canvas1, ox + w.x, oy + w.y)
			love.graphics.draw(w.canvas2, ox + w.x + w.width - w.size, oy + w.y)
			love.graphics.draw(w.canvas3, ox + w.x + w.size + offset, oy + w.y)
		end
		
		-- reset scissor
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	elseif w.tp == MG_INTERNAL_BOX then
		-- draw a corner box
		minGUI_draw_9slice(MG_BUTTON_DOWN_IMAGE, 0, 0, w.width , w.height, w.canvas)

		-- draw the canvas to the screen		
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)		
		
		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)
		
		-- reset scissor
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- draw menus
	elseif w.tp == MG_INTERNAL_MENU then
		if not popupOnly then
		-- draw each 'head' menu
		love.graphics.setColor(1, 1, 1, 1)
		minGUI_draw_9slice(MG_MENU_UP_IMAGE, 0, 0, w.width, w.height, w.canvas)

		-- draw the text on the gadget's canvas
		love.graphics.setCanvas(w.canvas)
		
		-- set current selected font (or default, if not changed)
		love.graphics.setFont(minGUI.font[minGUI.numFont])

		local x = 0
		
		for i = 1, #w.array do
			local menu_width = minGUI.font[minGUI.numFont]:getWidth(" " .. w.array[i].head_menu .. " ")
			local menu_height = minGUI.font[minGUI.numFont]:getHeight()
			
			love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)

			if w.menu.selected == i then
				love.graphics.setColor(1, 1, 1, 1)
				minGUI_draw_9slice(MG_MENU_DOWN_IMAGE, x, 0, menu_width, w.height, w.canvas)
				
				love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
			end
			
			-- draw the text on the gadget's canvas
			love.graphics.setCanvas(w.canvas)
			love.graphics.print(" " .. w.array[i].head_menu .. " ", x, (w.height - menu_height) / 2)
			
			x = x + menu_width
		end
			
		-- restore drawing on the window's canvas
		love.graphics.setCanvas()
		
		-- draw the canvas to the screen
		love.graphics.setColor(1, 1, 1, 1)

		-- set scissor
		love.graphics.setScissor(scx, scy, scw, sch)		
		
		-- draw
		love.graphics.draw(w.canvas, ox + w.x, oy + w.y)

		-- reset scissor
		love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		
        end
        -- Popups are drawn in a final pass, above every internal gadget.
        if popupOnly and w.menu.selected > 0 then
            local ml = #w.array[w.menu.selected].menu_list
            local px, py, mw, popupHeight, rowHeight = minGUI_menu_popup_geometry(w)
            if w.canvas1:getWidth() ~= mw or w.canvas1:getHeight() ~= popupHeight then
                w.canvas1 = love.graphics.newCanvas(mw, popupHeight)
            end
            love.graphics.setScissor()
            love.graphics.setFont(minGUI.font[minGUI.numFont])
			-- draw menu list background
			love.graphics.setColor(1, 1, 1, 1)
			minGUI_draw_9slice(MG_SUBMENU_UP_IMAGE, 0, 0, mw, popupHeight, w.canvas1)
			
			-- draw menu list items
			for i = 1, ml do
				-- set canvas
				love.graphics.setCanvas(w.canvas1)
				
				if w.array[w.menu.selected].menu_list[i] ~= "-" then
					if w.menu.hover == i then
						love.graphics.setColor(1, 1, 1, 1)
						minGUI_draw_9slice(MG_SUBMENU_DOWN_IMAGE, 0, 1 + (rowHeight * (i - 1)), mw, rowHeight, w.canvas1)
						
						love.graphics.setCanvas(w.canvas1)
						love.graphics.setColor(w.rpaper, w.gpaper, w.bpaper, w.apaper)
					else
						-- set the right color
						love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
					end

					-- draw the text on the gadget's canvas
					love.graphics.print(" " .. w.array[w.menu.selected].menu_list[i] .. " ", 0, 2 + (rowHeight * (i - 1)))
				else
					-- set the right color
					love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
					
					love.graphics.line(0, (rowHeight * (i - 1 + 0.5)), mw - 1, 2 + (rowHeight * (i - 1 + 0.5)))
				end
			end
			
			-- restore drawing on the window's canvas
			love.graphics.setCanvas()

			-- draw the canvas1 to the screen
			love.graphics.setColor(1, 1, 1, 1)
			
			-- set scissor
			love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())

			-- draw
			love.graphics.draw(w.canvas1, px, py)

			-- reset scissor
			love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		end
	end
end

-- function to call from love.draw()
function minGUI_draw_all()
    love.graphics.clear(minGUI.bgcolor.r, minGUI.bgcolor.g, minGUI.bgcolor.b, minGUI.bgcolor.a)
    love.graphics.setColor(1, 1, 1, 1)
    for id, root in minGUI_each_gadget() do
        if not root.isInternal and root.parent == nil then
            minGUI_draw_gadget(id, 0, 0)
            if root.can_have_sons then minGUI_draw_sons(id, 0, 0) end
            if minGUI.gfocus == id then minGUI_draw_cursor_on_focused_gadget(id, 0, 0) end
            -- Internal widgets belong to this layer, below the next window.
            for childID, child in minGUI_each_gadget() do
                if child.isInternal and minGUI_root_gadget(childID) == id then
                    local ox, oy = minGUI:get_parent_internal_gadget_offset(childID, child.tp)
                    minGUI_draw_internal_gadget(childID, ox, oy)
                end
            end
        end
    end
    for id, menu in minGUI_each_interactive_gadget() do
        if menu.tp == MG_INTERNAL_MENU and menu.menu.selected > 0 then
            local ox, oy = minGUI:get_parent_internal_gadget_offset(id, menu.tp)
            minGUI_draw_internal_gadget(id, ox, oy, true)
        end
    end
end

-- draw the text cursor in the focused gadget
function minGUI_draw_text_cursor(num, ox, oy)
	local w = minGUI.gtree[num]

	local xc1 = 0
	local yc1 = 0
	local xc2 = 0
	local yc2 = 0	

	-- draw the cursor at right place
	if w.tp == MG_STRING then
		xc1 = ox + w.x + 2
		yc1 = oy + w.y + 2
		xc2 = minGUI.font[minGUI.numFont]:getWidth(minGUI_sub_string(w.text, w.offset + 1, w.cursorx))
		yc2 = ((w.height - 4) - minGUI.font[minGUI.numFont]:getHeight()) / 2
	elseif w.tp == MG_SPIN then
		xc1 = ox + w.x
		yc1 = oy + w.y
		xc2 = (((w.width - minGUI.sprite[MG_SPIN_BUTTON_UP_IMAGE]:getWidth()) - minGUI.font[minGUI.numFont]:getWidth(w.text)) / 2) + minGUI.font[minGUI.numFont]:getWidth(minGUI_sub_string(w.text, 1, w.cursorx))
		yc2 = ((w.height + 2) - minGUI.font[minGUI.numFont]:getHeight()) / 2
	end
	
	-- resize cursor's canvas
	if w.cursor_canvas:getWidth() ~= minGUI.font[minGUI.numFont]:getWidth("|")
		or w.cursor_canvas:getHeight() ~= minGUI.font[minGUI.numFont]:getHeight() then
		w.cursor_canvas = love.graphics.newCanvas(minGUI.font[minGUI.numFont]:getWidth("|"), minGUI.font[minGUI.numFont]:getHeight())
	end

	-- draw the cursor on its canvas
	love.graphics.setCanvas(w.cursor_canvas)
	love.graphics.clear(0, 0, 0, 0)
	love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
	love.graphics.print(w.tp == MG_STRING and w.overwrite and "_" or "|", 0, 0)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas()	

	-- draw the cursor on the text's canvas
	love.graphics.setCanvas(w.canvas)	
	love.graphics.draw(w.cursor_canvas, xc2, yc2 - 2)
	love.graphics.setCanvas()	

	-- Clip the cursor to the same parent area as the field.
	local scx, scy, scw, sch = minGUI_get_gadget_parents_scissor(w.parent)
	love.graphics.setScissor(scx, scy, scw, sch)
	love.graphics.draw(w.canvas, xc1, yc1)
	love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

-- draw the editor cursor
function minGUI_draw_editor_cursor(num, ox, oy)
	local w = minGUI.gtree[num]
	if not w.editable then return end
	minGUI_editor_layout(w)
	local font = minGUI.font[minGUI.numFont]
	local line = minGUI_explode(w.text, "\n")[w.cursory + 1]
	local x = font:getWidth(minGUI_sub_string(line, 1, w.cursorx)) - w.scrollX
	local y = w.cursory * font:getHeight() - w.scrollY
	love.graphics.setCanvas(w.canvas)
	love.graphics.setFont(font)
	love.graphics.setColor(w.rpen, w.gpen, w.bpen, w.apen)
	love.graphics.print(w.overwrite and '_' or '|', x, y)
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1, 1)
	local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(w.parent)
	love.graphics.setScissor(sx, sy, sw, sh)
	love.graphics.draw(w.canvas, ox + w.x + 2, oy + w.y + 2)
	love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

-- load 9-slice sprite
function minGUI_load_9slice(num, filename)
	if minGUI_get_file_exists(filename) == true then
		minGUI.sprite[num] = love.graphics.newImage(filename)
	else
		minGUI:runtime_error("Can't load the file " .. filename)
	end
end

-- load a sprite
function minGUI_load_sprite(num, filename)
	if minGUI_get_file_exists(filename) == true then
		minGUI.sprite[num] = love.graphics.newImage(filename)
	else
		minGUI:runtime_error("Can't load the file " .. filename)
	end
end

-- draw a 9-slice sprite
function minGUI_draw_9slice(num, x, y, width, height, canvas)
	-- can't go under a special size
	if width <= 0 then return end
	if height <= 0 then return end
	
	-- parts of images
	local p = {}
	
	-- quads size x & y
	local qsx = math.floor(minGUI.sprite[num]:getWidth() / 3)
	local qsy = math.floor(minGUI.sprite[num]:getHeight() / 3)
	
	-- maximum number of rows and columns of quads
	local tx = math.floor(width / qsx)
	local ty = math.floor(height / qsy)

	-- unused pieces of tiles
	local px = math.floor(width - (tx * qsx))
	local py = math.floor(height - (ty * qsy))

	-- get limits
	local limitx = tx - 1
	local limity = ty - 1
	
	-- separate texture in 9 quads
	p[1] = love.graphics.newQuad(0, 0, qsx, qsy, minGUI.sprite[num])
	p[2] = love.graphics.newQuad(qsx, 0, qsx, qsy, minGUI.sprite[num])
	p[3] = love.graphics.newQuad(qsx * 2, 0, qsx, qsy, minGUI.sprite[num])
	p[4] = love.graphics.newQuad(0, qsy, qsx, qsy, minGUI.sprite[num])
	p[5] = love.graphics.newQuad(qsx, qsy, qsx, qsy, minGUI.sprite[num])
	p[6] = love.graphics.newQuad(qsx * 2, qsy, qsx, qsy, minGUI.sprite[num])
	p[7] = love.graphics.newQuad(0, qsy * 2, qsx, qsy, minGUI.sprite[num])
	p[8] = love.graphics.newQuad(qsx, qsy * 2, qsx, qsy, minGUI.sprite[num])
	p[9] = love.graphics.newQuad(qsx * 2, qsy * 2, qsx, qsy, minGUI.sprite[num])

	-- draw the quads on the canvas
	--=============================

	-- render to the canvas
	love.graphics.setCanvas(canvas)

	-- draw top left corner
	love.graphics.draw(minGUI.sprite[num], p[1], x, y)

	-- draw top edge
	for x9 = 1, limitx do
		love.graphics.draw(minGUI.sprite[num], p[2], x + (x9 * qsx), y)
	end

	-- draw top right corner
	love.graphics.draw(minGUI.sprite[num], p[3], x + (limitx * qsx) + px, y)

	-- draw left edge
	for y9 = 1, limity do
		love.graphics.draw(minGUI.sprite[num], p[4], x, y + (y9 * qsy))
	end
		
	-- draw center
	for y9 = 1, limity do
		for x9 = 1, limitx do
			love.graphics.draw(minGUI.sprite[num], p[5], x + (x9 * qsx), y + (y9 * qsy))
		end
	end
	
	-- draw right edge
	for y9 = 1, limity do
		love.graphics.draw(minGUI.sprite[num], p[6], x + (limitx * qsx) + px, y + (y9 * qsy))
	end
	
	-- draw bottom left corner
	love.graphics.draw(minGUI.sprite[num], p[7], x, y + (limity * qsy) + py)

	-- draw bottom edge
	for x9 = 1, limitx do
		love.graphics.draw(minGUI.sprite[num], p[8], x + (x9 * qsx), y + (limity * qsy) + py)
	end

	-- draw bottom right corner
	love.graphics.draw(minGUI.sprite[num], p[9], x + (limitx * qsx) + px, y + (limity * qsy) + py)

	-- render to window
	love.graphics.setCanvas()
end

-- draw a single sprite
function minGUI_draw_sprite(num, x, y)
	-- draw the image
	love.graphics.draw(minGUI.sprite[num], x, y)
end

-- get sprite size
function minGUI_get_sprite_size(num)
	return minGUI.sprite[num]:getWidth(), minGUI.sprite[num]:getHeight()
end

-- draw a quad of a sprite
function minGUI_draw_quad(num, quad, x, y)
	-- draw the quad
	love.graphics.draw(minGUI.sprite[num], quad, x, y)
end

-- draw cursor on focused gadget
function minGUI_draw_cursor_on_focused_gadget(num, ox, oy)
	local v = minGUI.gtree[num]
	
	-- if the focused gadget is a string gadget...
	if v.tp == MG_STRING and v.editable then
		local t = math.floor(minGUI.timer * 1000) % 1000
			
		if t < 500 then
			minGUI_draw_text_cursor(v.num, ox, oy)
		end
	-- if the focused gadget is a spin gadget...
	elseif v.tp == MG_SPIN and not v.valueSelected then
		local t = math.floor(minGUI.timer * 1000) % 1000
						
		if t < 500 then
			minGUI_draw_text_cursor(v.num, ox, oy)
		end
	-- if the focused gadget is an editor gadget...
	elseif v.tp == MG_EDITOR then
		local t = math.floor(minGUI.timer * 1000) % 1000
						
		if t < 500 then
			minGUI_draw_editor_cursor(v.num, ox, oy)
		end
	end
end

-- draw sons gadgets
function minGUI_draw_sons(num, ox, oy)
	local v = minGUI.gtree[num]
	
	for j, w in minGUI_each_gadget() do
		if w.parent == v.num and not w.isInternal then
			-- parent is a window with a menu ?
			local childOX, childOY = minGUI_get_parent_gadget_offset(w.num)

			-- draw the current gadget
			minGUI_draw_gadget(w.num, childOX, childOY)
			
			-- draw sons of sons
			if w.can_have_sons then
				minGUI_draw_sons(w.num, childOX, childOY)
			end
			
			-- draw cursor on focused object,if needed
			if minGUI.gfocus ~= nil and minGUI.gfocus == j then
				if minGUI.gtree[j] ~= nil then
					minGUI_draw_cursor_on_focused_gadget(j, childOX, childOY)
				end
			end
		end
	end
end
