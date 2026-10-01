-- Multiline editing uses absolute UTF-8 positions, including newline characters.
local function clamp(value, low, high) return math.max(low, math.min(high, value)) end
local function shift() return love.keyboard.isDown('lshift', 'rshift') end
local function control() return love.keyboard.isDown('lctrl', 'rctrl', 'lgui', 'rgui') end

function minGUI_editor_position(g)
	local lines = minGUI_explode(g.text, '\n')
	g.cursory = clamp(g.cursory or 0, 0, #lines - 1)
	g.cursorx = clamp(g.cursorx or 0, 0, utf8.len(lines[g.cursory + 1]))
	local position = g.cursorx
	for row = 1, g.cursory do position = position + utf8.len(lines[row]) + 1 end
	g.position = position
	return position
end

function minGUI_editor_set_position(g, position)
	position = clamp(position, 0, utf8.len(g.text))
	g.position = position
	local lines = minGUI_explode(g.text, '\n')
	for row, line in ipairs(lines) do
		local length = utf8.len(line)
		if position <= length then g.cursorx, g.cursory = position, row - 1; return end
		position = position - length - 1
	end
end

function minGUI_editor_selection(g)
	local position = minGUI_editor_position(g)
	local anchor = clamp(g.selectionAnchor or position, 0, utf8.len(g.text))
	return math.min(position, anchor), math.max(position, anchor)
end

-- Recalculate the viewport and proportional thumbs as the document changes.
function minGUI_editor_layout(g, reveal)
	local font = minGUI.font[minGUI.numFont]
	local bars = not minGUI_flag_active(g.flags, MG_FLAG_NO_SCROLLBARS)
	g.viewWidth = math.max(1, g.width - 4 - (bars and MG_SCROLLBAR_SIZE or 0))
	g.viewHeight = math.max(1, g.height - 4 - (bars and MG_SCROLLBAR_SIZE or 0))
	if g.canvas:getWidth() ~= g.viewWidth or g.canvas:getHeight() ~= g.viewHeight then
		g.canvas = love.graphics.newCanvas(g.viewWidth, g.viewHeight)
	end
	local lines = minGUI_explode(g.text, '\n')
	local width = font:getWidth('|')
	for _, line in ipairs(lines) do width = math.max(width, font:getWidth(line) + font:getWidth('|')) end
	local height = #lines * font:getHeight()
	g.maxScrollX, g.maxScrollY = math.max(0, width - g.viewWidth), math.max(0, height - g.viewHeight)
	g.scrollX = clamp(g.scrollX or 0, 0, g.maxScrollX)
	g.scrollY = clamp(g.scrollY or 0, 0, g.maxScrollY)
	minGUI_editor_position(g)
	if reveal then
		local x = font:getWidth(minGUI_sub_string(lines[g.cursory + 1], 1, g.cursorx))
		local y = g.cursory * font:getHeight()
		if x < g.scrollX then g.scrollX = x end
		if x + font:getWidth('|') > g.scrollX + g.viewWidth then g.scrollX = x + font:getWidth('|') - g.viewWidth end
		if y < g.scrollY then g.scrollY = y end
		if y + font:getHeight() > g.scrollY + g.viewHeight then g.scrollY = y + font:getHeight() - g.viewHeight end
	end
	for _, bar in minGUI_each_gadget() do
		if bar.parent == g.num and bar.tp == MG_INTERNAL_SCROLLBAR then
			local vertical = minGUI_flag_active(bar.flags, MG_FLAG_SCROLLBAR_VERTICAL)
			local viewport, content = vertical and g.viewHeight or g.viewWidth, vertical and height or width
			local track = bar.internalBarSize
			local thumb = math.min(track, math.max(MG_MIN_SCROLLBAR_BUTTON_SIZE, math.floor(track * math.min(1, viewport / content) + 0.5)))
			bar.minValue, bar.maxValue, bar.inc = 0, vertical and g.maxScrollY or g.maxScrollX, vertical and font:getHeight() or 8
			bar.value = vertical and g.scrollY or g.scrollX
			bar.thumbTravel = track - thumb
			bar.thumbOffset = bar.maxValue > 0 and bar.value / bar.maxValue * bar.thumbTravel or 0
			local w, h = vertical and bar.size or thumb, vertical and thumb or bar.size
			bar.size_width, bar.size_height = w, h
			if bar.canvas3:getWidth() ~= w or bar.canvas3:getHeight() ~= h then bar.canvas3 = love.graphics.newCanvas(w, h) end
		end
	end
end

function minGUI_editor_replace(g, text, deleting)
	text = text:gsub('\r\n', '\n'):gsub('\r', '\n')
	if text == '' and not deleting then return end
	local first, last = minGUI_editor_selection(g)
	if first == last and g.overwrite and not deleting and not text:find('\n', 1, true) then
		local line = minGUI_explode(g.text, '\n')[g.cursory + 1]
		last = first + math.min(utf8.len(text), utf8.len(line) - g.cursorx)
	end
	g.text = minGUI_sub_string(g.text, 1, first) .. text .. minGUI_sub_string(g.text, last + 1)
	g.selectionAnchor, g.preferredColumn = nil, nil
	minGUI_editor_set_position(g, first + utf8.len(text))
	minGUI_editor_layout(g, true)
end

local function mousePosition(g)
	local ox, oy = minGUI_get_parent_gadget_offset(g.num)
	local font = minGUI.font[minGUI.numFont]
	local lines = minGUI_explode(g.text, '\n')
	local row = clamp(math.floor((minGUI.mouse.y - oy - g.y - 2 + g.scrollY) / font:getHeight()), 0, #lines - 1)
	local x = minGUI.mouse.x - ox - g.x - 2 + g.scrollX
	local line, column, previous = lines[row + 1], utf8.len(lines[row + 1]), 0
	for index = 1, utf8.len(line) do
		local width = font:getWidth(minGUI_sub_string(line, 1, index))
		if x < (previous + width) / 2 then column = index - 1; break end
		previous = width
	end
	local position = column
	for index = 1, row do position = position + utf8.len(lines[index]) + 1 end
	return position
end

function minGUI_editor_mouse_pressed(g)
	minGUI_editor_layout(g)
	local position = mousePosition(g)
	g.selectionAnchor = shift() and (g.selectionAnchor or minGUI_editor_position(g)) or position
	minGUI_editor_set_position(g, position)
	g.preferredColumn = nil
	minGUI.editorDrag = g.num
end

local keys = {'left','right','up','down','pageup','pagedown','home','end','backspace','delete','insert','return','kpenter','a','c','x','v'}
function minGUI_update_editor_keyboard()
	local g = minGUI.gtree[minGUI.gfocus]
	if not g or g.tp ~= MG_EDITOR then minGUI.editorKeyboardFocus, minGUI.editorDrag = nil, nil; return end
	if minGUI.editorKeyboardFocus ~= g.num then g.keyrepeat = {}; minGUI.editorKeyboardFocus = g.num end
	minGUI_editor_layout(g)
	if minGUI.editorDrag == g.num then
		if minGUI.mouse.mbtn[MG_LEFT_BUTTON] then
			minGUI_editor_set_position(g, mousePosition(g)); minGUI_editor_layout(g, true)
		else minGUI.editorDrag = nil end
	end
	for _, key in ipairs(keys) do
		local command = key == 'a' or key == 'c' or key == 'x' or key == 'v'
		local state = g.keyrepeat[key]
		if not love.keyboard.isDown(key) or (command and not control()) then g.keyrepeat[key] = nil
		elseif not state or (not command and key ~= 'insert' and minGUI.timer >= state) then
			local position = minGUI_editor_position(g)
			local first, last = minGUI_editor_selection(g)
			local length = utf8.len(g.text)
			if command then
				if key == 'a' then g.selectionAnchor = 0; minGUI_editor_set_position(g, length)
				elseif key == 'c' or key == 'x' then
					if first ~= last then
						love.system.setClipboardText(minGUI_sub_string(g.text, first + 1, last))
						if key == 'x' and g.editable then minGUI_editor_replace(g, '', true) end
					end
				elseif key == 'v' and g.editable then minGUI_editor_replace(g, love.system.getClipboardText()) end
			elseif key == 'left' or key == 'right' or key == 'up' or key == 'down' or key == 'pageup' or key == 'pagedown' or key == 'home' or key == 'end' then
				if shift() then g.selectionAnchor = g.selectionAnchor or position end
				local target = position
				local lines = minGUI_explode(g.text, '\n')
				if key == 'up' or key == 'down' or key == 'pageup' or key == 'pagedown' then
					g.preferredColumn = g.preferredColumn or g.cursorx
					local page = key == 'pageup' or key == 'pagedown'
					local step = page and math.max(1, math.floor(g.viewHeight / minGUI.font[minGUI.numFont]:getHeight())) or 1
					local direction = (key == 'up' or key == 'pageup') and -1 or 1
					local row = clamp(g.cursory + direction * step, 0, #lines - 1)
					if page then
						g.scrollY = clamp(g.scrollY + (row - g.cursory) * minGUI.font[minGUI.numFont]:getHeight(), 0, g.maxScrollY)
					end
					g.cursorx, g.cursory = math.min(g.preferredColumn, utf8.len(lines[row + 1])), row
					target = minGUI_editor_position(g)
				else
					g.preferredColumn = nil
					if key == 'home' then target = control() and 0 or position - g.cursorx
					elseif key == 'end' then target = control() and length or position - g.cursorx + utf8.len(lines[g.cursory + 1])
					elseif first ~= last and not shift() then target = key == 'left' and first or last
					else target = position + (key == 'left' and -1 or 1) end
				end
				minGUI_editor_set_position(g, target)
				if not shift() then g.selectionAnchor = nil end
			elseif g.editable then
				if key == 'insert' then g.overwrite = not g.overwrite
				elseif key == 'return' or key == 'kpenter' then minGUI_editor_replace(g, '\n')
				elseif key == 'delete' or key == 'backspace' then
					if first == last then g.selectionAnchor = clamp(position + (key == 'delete' and 1 or -1), 0, length) end
					minGUI_editor_replace(g, '', true)
				end
			end
			g.keyrepeat[key] = minGUI.timer + (state and MG_QUICK_DELAY or MG_SLOW_DELAY)
			minGUI_editor_layout(g, true)
		end
	end
end

-- Internal scrollbar mouse capture prevents clicks from reaching the editor below.
function minGUI_update_editor_scrollbars()
	for _, g in minGUI_each_gadget() do if g.tp == MG_EDITOR then minGUI_editor_layout(g) end end
	local capture = minGUI.editorScrollCapture
	if capture and not minGUI.gtree[capture.id] then minGUI.editorScrollCapture = nil; capture = nil end
	if not capture and minGUI.mouse.mpressed[MG_LEFT_BUTTON] then
		for id, bar in minGUI_each_gadget(true) do
			local g = minGUI.gtree[bar.parent]
			if bar.tp == MG_INTERNAL_SCROLLBAR and g and g.tp == MG_EDITOR then
				local ox, oy = minGUI:get_parent_internal_gadget_offset(id, bar.tp)
				local x, y = minGUI.mouse.x - ox - bar.x, minGUI.mouse.y - oy - bar.y
				local sx, sy, sw, sh = minGUI_get_gadget_parents_scissor(bar.parent)
				if x >= 0 and y >= 0 and x < bar.width and y < bar.height
					and minGUI.mouse.x >= sx and minGUI.mouse.x < sx + sw and minGUI.mouse.y >= sy and minGUI.mouse.y < sy + sh then
					local vertical = minGUI_flag_active(bar.flags, MG_FLAG_SCROLLBAR_VERTICAL)
					local axis, extent = vertical and y or x, vertical and bar.height or bar.width
					local thumb = vertical and bar.size_height or bar.size_width
					local mode = axis < bar.size and 'first' or (axis >= extent - bar.size and 'last' or 'thumb')
					local grab = axis - bar.size - bar.thumbOffset
					if mode == 'thumb' and (grab < 0 or grab > thumb) then
						bar.value = clamp(bar.value + (grab < 0 and -1 or 1) * (vertical and g.viewHeight or g.viewWidth), 0, bar.maxValue)
						mode = 'page'
					end
					capture = {id=id, mode=mode, grab=grab, nextTime=minGUI.timer}
					minGUI.editorScrollCapture = capture
					minGUI.gfocus = g.num
					break
				end
			end
		end
	end
	if not capture then return false end
	local bar = minGUI.gtree[capture.id]
	local g = minGUI.gtree[bar.parent]
	local vertical = minGUI_flag_active(bar.flags, MG_FLAG_SCROLLBAR_VERTICAL)
	if minGUI.mouse.mbtn[MG_LEFT_BUTTON] then
		if capture.mode == 'thumb' and bar.thumbTravel > 0 then
			local ox, oy = minGUI:get_parent_internal_gadget_offset(bar.num, bar.tp)
			local axis = vertical and (minGUI.mouse.y - oy - bar.y) or (minGUI.mouse.x - ox - bar.x)
			bar.value = clamp((axis - bar.size - capture.grab) / bar.thumbTravel * bar.maxValue, 0, bar.maxValue)
		elseif (capture.mode == 'first' or capture.mode == 'last') and minGUI.timer >= capture.nextTime then
			bar.value = clamp(bar.value + (capture.mode == 'first' and -bar.inc or bar.inc), 0, bar.maxValue)
			capture.nextTime = minGUI.timer + MG_MEDIUM_DELAY
		end
		bar.down, bar.down1, bar.down2 = capture.mode == 'thumb', capture.mode == 'first', capture.mode == 'last'
	else
		bar.down, bar.down1, bar.down2 = false, false, false
		minGUI.editorScrollCapture = nil
	end
	if vertical then g.scrollY = bar.value else g.scrollX = bar.value end
	minGUI_editor_layout(g)
	return true
end
