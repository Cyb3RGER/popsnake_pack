-- from https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- dumps a table in a readable string
function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            local kc = k
            if type(k) ~= 'number' then
                kc = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. kc .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function except(a, b)
	local res = {}
	for _, av in ipairs(a) do
		local found_in_b = false
		for _, bv in ipairs(b) do
			if av == bv then
				found_in_b = true
			end
		end
		if not found_in_b then
			table.insert(res, av)
		end
	end
	return res
end

function pick_random(a)
	return a[math.random(1, #a)]
end

function is_ap_connected()
    return AutoTracker:GetConnectionState("AP") == 3
end

function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
