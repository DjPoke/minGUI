-- Cursor and selection positions are between characters in the numeric display.
function minGUI_spin_sync(g)
	local length = utf8.len(g.text)
	if g.spinText ~= g.text then
		g.spinText, g.cursorx, g.selectionAnchor = g.text, length, nil
	end
	g.cursorx = math.max(0, math.min(length, g.cursorx or length))
	if g.valueSelected and g.selectionAnchor == nil then
		g.selectionAnchor, g.cursorx = 0, length
	end
end

function minGUI_spin_selection(g)
	minGUI_spin_sync(g)
	return minGUI_string_selection(g)
end

local function commit(g, text, cursor, selected)
	g.text, g.spinText = text, text
	g.cursorx = math.min(cursor or utf8.len(text), utf8.len(text))
	g.selectionAnchor = selected and 0 or nil
	g.valueSelected = selected and text ~= '' or false
	minGUI_shift_text(g.num, text)
end

local function numeric(text)
	text = text:match('^%s*(.-)%s*$')
	local mantissa = text:match('^([+-]?[%d%.]+)[eE][+-]?%d+$') or text
	if not (mantissa:match('^[+-]?%d+%.?%d*$') or mantissa:match('^[+-]?%.%d+$')) then return end
	local value = tonumber(text)
	if value and value == value and value ~= math.huge and value ~= -math.huge then return value end
end

function minGUI_spin_replace(g, text, paste)
	local value = numeric(text)
	if not value then return end
	local first, last = minGUI_spin_selection(g)
	if paste then
		text = tostring(math.floor(value + 0.5))
		if first == last then first, last = 0, utf8.len(g.text) end
	end
	local candidate = minGUI_sub_string(g.text, 1, first) .. text .. minGUI_sub_string(g.text, last + 1)
	local number = numeric(candidate)
	if not number then return end
	local result = frameTextValue(math.floor(number + 0.5), g.minValue, g.maxValue)
	commit(g, result, result == candidate and (first + utf8.len(text)) or utf8.len(result), paste)
end

local function shift() return love.keyboard.isDown('lshift', 'rshift') end
local function control() return love.keyboard.isDown('lctrl', 'rctrl', 'lgui', 'rgui') end
local keys = {'left', 'right', 'home', 'end', 'backspace', 'delete', 'a', 'c', 'x', 'v'}
function minGUI_update_spin_clipboard()
	local g = minGUI.gtree[minGUI.gfocus]
	if not g or g.tp ~= MG_SPIN then minGUI.spinClipboardFocus = nil; return end
	if minGUI.spinClipboardFocus ~= g.num then g.spinKeys = {}; minGUI.spinClipboardFocus = g.num end
	minGUI_spin_sync(g)
	for _, key in ipairs(keys) do
		local command = key == 'a' or key == 'c' or key == 'x' or key == 'v'
		local state = g.spinKeys[key]
		if not love.keyboard.isDown(key) or (command and not control()) then g.spinKeys[key] = nil
		elseif not state or (not command and minGUI.timer >= state) then
			local first, last = minGUI_spin_selection(g)
			local cursor, length = g.cursorx, utf8.len(g.text)
			if command then
				if key == 'a' then g.selectionAnchor, g.cursorx = 0, length
				elseif key == 'c' or key == 'x' then
					if first == last then first, last = 0, length; g.selectionAnchor, g.cursorx = first, last end
					if first ~= last then
						love.system.setClipboardText(minGUI_sub_string(g.text, first + 1, last))
						if key == 'x' then
							commit(g, minGUI_sub_string(g.text, 1, first) .. minGUI_sub_string(g.text, last + 1), first)
						end
					end
				elseif key == 'v' then minGUI_spin_replace(g, love.system.getClipboardText(), true) end
			elseif key == 'left' or key == 'right' or key == 'home' or key == 'end' then
				if shift() then g.selectionAnchor = g.selectionAnchor or cursor end
				if key == 'home' then g.cursorx = 0
				elseif key == 'end' then g.cursorx = length
				elseif first ~= last and not shift() then g.cursorx = key == 'left' and first or last
				else g.cursorx = math.max(0, math.min(length, cursor + (key == 'left' and -1 or 1))) end
				if not shift() then g.selectionAnchor = nil end
			elseif key == 'backspace' or key == 'delete' then
				if first == last then
					if key == 'backspace' then first = math.max(0, cursor - 1)
					else last = math.min(length, cursor + 1) end
				end
				commit(g, minGUI_sub_string(g.text, 1, first) .. minGUI_sub_string(g.text, last + 1), first)
			end
			local start, finish = minGUI_string_selection(g)
			g.valueSelected = start ~= finish
			g.spinKeys[key] = minGUI.timer + (state and MG_QUICK_DELAY or MG_SLOW_DELAY)
		end
	end
end
