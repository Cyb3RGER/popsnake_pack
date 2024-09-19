MAX_LINE_LENGTH = 150
CURRENT_HINTS = {}
DISPLAY_HINTS = {}
NAME_CACHE = {
	locations = {},
	items = {},
	clear = function(self)
		self.locations = {}
		self.items = {}
	end,
	add_loc = function(self, id, name, game)
		if self.locations[game] == nil then
			self.locations[game] = {}
		end
		self.locations[game][id] = name
	end,
	add_item = function(self, id, name, game)
		if self.items[game] == nil then
			self.items[game] = {}
		end
		self.items[game][id] = name
	end,
	has_loc = function(self, id, game)
		if self.locations[game] == nil then
			return false
		end
		return self.locations[game][id] ~= nil
	end,
	has_item = function(self, id, game)
		if self.items[game] == nil then
			return false
		end
		return self.items[game][id] ~= nil
	end,
	get_loc_name = function(self, id, player)
		local is_connected = is_ap_connected()
		if not is_connected then
			return "Unknown"
		end
		if player == nil then
			player = Archipelago.PlayerNumber
		end
		local game = Archipelago:GetPlayerGame(player)
		if game == "Unknown" then
			return game
		end
		if self:has_loc(id,game) then
			return self.locations[game][id]
		end
		local name = Archipelago:GetLocationName(id, game)
		if name == "Unknown" then
			return name
		end
		self:add_loc(id, name, game)
		return name
	end,
	get_item_name = function(self, id, player)
		local is_connected = is_ap_connected()
		if not is_connected then
			return "Unknown"
		end
		if player == nil then
			player = Archipelago.PlayerNumber
		end
		local game = Archipelago:GetPlayerGame(player)
		if game == "Unknown" then
			return game
		end
		if self:has_item(id,game) then
			return self.items[game][id]
		end
		local name = Archipelago:GetItemName(id, game)
		if name == "Unknown" then
			return name
		end
		self:add_item(id, name, game)
		return name
	end,
	get_player_name = function(self, player)
		local name = Archipelago:GetPlayerAlias(player)
		if name == "Unknown" then
			return "Player " .. player
		end
		return name
	end
}

function _get_hints_key()
	return string.format("_read_hints_%s_%s", Archipelago.TeamNumber, Archipelago.PlayerNumber)
end

function onClear(slot_data)
	NAME_CACHE:clear()
	local keys = { _get_hints_key() }
	Archipelago:Get(keys)
	Archipelago:SetNotify(keys)
end

function trySendHint()
	if not is_ap_connected() then return end

	local missing = except(Archipelago.MissingLocations, CURRENT_HINTS)
	if #missing > 0 then
		Archipelago:LocationScouts({ pick_random(missing) }, 1)
	end
end

function onRetrieved(key, value)
	if key ~= _get_hints_key() then return end
	CURRENT_HINTS = {}
	DISPLAY_HINTS = {}
	for _, hint in ipairs(value) do
		table.insert(DISPLAY_HINTS, hint)
		table.insert(CURRENT_HINTS, hint.location)
	end
	update_hint_display()
end

function onScout(locationId, locationName, itemId, itemName, itemPlayer)
	NAME_CACHE:add(locationId, locationName, itemId, itemName, itemPlayer)
	update_hint_display()
end

function update_hint_display()
	local str = ""
	for _, v in ipairs(DISPLAY_HINTS) do
		str = str .. build_hint_as_text(v)
	end
	local obj = Tracker:FindObjectForCode("hint_display")
	if obj then
		obj:SetOverlay(str)
		obj:SetOverlayAlign("center")
		obj:SetOverlayBackground("#aaaaaaaa")
		obj:SetOverlayFontSize(16)
	end
end

function get_item_type(flags)
	if flags & 1 == 1 then
		return "progressive"
	end
	if flags & 2 == 2 then
		return "important"
	end
	if flags & 4 == 4 then
		return "trap"
	end
	return "filler"
end

function build_hint_as_text(hint)
	local str = string.format(
		"%s's %s (%s) is at %s in %s's World",
		NAME_CACHE:get_player_name(hint.receiving_player),
		NAME_CACHE:get_item_name(hint.item, hint.receiving_player),
		get_item_type(hint.item_flags),
		NAME_CACHE:get_loc_name(hint.location),
		NAME_CACHE:get_player_name(hint.finding_player),
		hint.entrace
	)
	if hint.entrace and hint.entrace ~= "" then
		str = str .. string.format(" at entrace %s", hint.entrace)
	end
	str = str .. "."
	if hint.found then
		str = str .. " (found)"
	else
		str = str .. " (not found)"
	end
	str = autoLineBreak(str) .. '\n'
	return str
end

function autoLineBreak(str)
	local newstr = ""
	for line in string.gmatch(str, "([^\r\n]+)") do
		while #line > MAX_LINE_LENGTH do
			local cur_line = string.sub(line, 1, MAX_LINE_LENGTH)
			local index = string.find(cur_line, "[\t\f\v ][^\t\f\v ]*$") or MAX_LINE_LENGTH
			cur_line = string.sub(cur_line, 1, index)
			cur_line = trim(cur_line)
			if cur_line ~= "" then
				newstr = newstr .. cur_line .. '\n'
			end
			line = string.sub(line, index + 1, -1)
		end
		newstr = newstr .. line
	end
	return newstr
end

Archipelago:AddClearHandler("onClear", onClear)
Archipelago:AddRetrievedHandler("onRetrieved", onRetrieved)
Archipelago:AddSetReplyHandler("onSetReply", onRetrieved)
Archipelago:AddScoutHandler("onScout", onScout)
