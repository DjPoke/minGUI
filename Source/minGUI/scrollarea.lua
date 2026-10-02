-- Scroll areas keep child coordinates in content space; only the viewport moves.
function minGUI_scrollarea_layout(g)
	g.scrollX = math.max(0, math.min(g.maxScrollX, g.scrollX or 0))
	g.scrollY = math.max(0, math.min(g.maxScrollY, g.scrollY or 0))
	for _, bar in minGUI_each_gadget() do
		if bar.parent == g.num and bar.tp == MG_INTERNAL_SCROLLBAR then
			local vertical = minGUI_flag_active(bar.flags, MG_FLAG_SCROLLBAR_VERTICAL)
			local view = vertical and g.viewHeight or g.viewWidth
			local content = vertical and g.realHeight or g.realWidth
			local track = bar.internalBarSize
			local thumb = math.min(track, math.max(MG_MIN_SCROLLBAR_BUTTON_SIZE, math.floor(track * view / content)))
			bar.minValue, bar.maxValue, bar.inc = 0, vertical and g.maxScrollY or g.maxScrollX, 16
			bar.value = vertical and g.scrollY or g.scrollX
			bar.thumbTravel = track - thumb
			bar.thumbOffset = bar.maxValue > 0 and bar.value / bar.maxValue * bar.thumbTravel or 0
			local w, h = vertical and bar.size or thumb, vertical and thumb or bar.size
			bar.size_width, bar.size_height = w, h
			if bar.canvas3:getWidth() ~= w or bar.canvas3:getHeight() ~= h then
				bar.canvas3 = love.graphics.newCanvas(w, h)
			end
		end
	end
end

function minGUI_scrollable_layout(g)
	if g.tp == MG_LIST or g.tp == MG_COMBO_BOX then minGUI_choice_layout(g)
	elseif g.tp == MG_SCROLLAREA then minGUI_scrollarea_layout(g)
	else minGUI_editor_layout(g) end
end

-- Prevent invisible child gadgets from receiving pointer events.
function minGUI_pointer_in_parent(g)
	local x, y, w, h = minGUI_get_gadget_parents_scissor(g.parent)
	return minGUI.mouse.x >= x and minGUI.mouse.x < x + w
		and minGUI.mouse.y >= y and minGUI.mouse.y < y + h
end
