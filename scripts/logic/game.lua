--fps
TARGET_FPS = 5
TARGET_FRAME_TIME = 1.0 / TARGET_FPS
CURRENT_FRAME_TIME = 0
--map/loc settings
BORDER_THICKNESS = 0
MAP_SIZE_PIXEL = 480
LOC_SIZE_WITH_BORDER = 20
LOC_SIZE = LOC_SIZE_WITH_BORDER - BORDER_THICKNESS
MAP_SIZE_LOCS = math.floor(MAP_SIZE_PIXEL / LOC_SIZE_WITH_BORDER)
--enums
DIRECTIONS = {
	["up"] = { x = 0, y = -1 },
	["down"] = { x = 0, y = 1 },
	["left"] = { x = -1, y = 0 },
	["right"] = { x = 1, y = 0 },
}
GRID_STATES = {
	EMPTY = 0,
	SNAKE = 1,
	FOOD = 2
}
--game state
GRID = {}
START_POS = { x = 10, y = 10 }
START_LENGTH = 3
GAME_STATE = {
	grid = {},
	snake = {
		body = {},
		dir = DIRECTIONS.right
	},
	food = {},
	game_over = false,
	score = 0
}
TRACKER_OBJ_CODES = {
	"score", "update"
}
TRACKER_OBJS = {}
SCORE_FOR_HINT = 5
--game logic
GRID_VAL_ACCESS_MAPPING = {
	[GRID_STATES.EMPTY] = AccessibilityLevel.Inspect,
	[GRID_STATES.SNAKE] = AccessibilityLevel.Normal,
	[GRID_STATES.FOOD] = AccessibilityLevel.None
}

function _get_index_from_pos(pos)
	return (pos.y - 1) * MAP_SIZE_LOCS + pos.x
end

function invert_pos(pos)
	return { x = -pos.x, y = -pos.y }
end

function add_pos(a, b)
	return { x = a.x + b.x, y = a.y + b.y }
end

function compare_pos(a, b)
	return a.x == b.x and a.y == b.y
end

function get_grid_val(pos)
	return GAME_STATE.grid[_get_index_from_pos(pos)]
end

function set_grid_val(pos, val)
	GAME_STATE.grid[_get_index_from_pos(pos)] = val
end

function init_game()
	init_grid()
	add_snake()
	spawn_food()
	reset_score()
	GAME_STATE.game_over = false
end

function init_grid()
	-- Create a grid with EMPTY cells
	for i = 1, MAP_SIZE_LOCS * MAP_SIZE_LOCS do
		GAME_STATE.grid[i] = GRID_STATES.EMPTY
	end
end

function add_snake()
	local pos = START_POS
	local dir = DIRECTIONS.right
	GAME_STATE.snake.dir = dir
	GAME_STATE.snake.body = {}
	for i = 1, START_LENGTH do
		table.insert(GAME_STATE.snake.body, pos)
		set_grid_val(pos, GRID_STATES.SNAKE)
		pos = add_pos(pos, invert_pos(dir))
	end
end

function cell_access(x, y)
	x = tonumber(x)
	y = tonumber(y)
	local grid_val = get_grid_val({ x = x, y = y })
	return GRID_VAL_ACCESS_MAPPING[grid_val]
end

function cell_visible(x, y)
	x = tonumber(x)
	y = tonumber(y)
	local grid_val = get_grid_val({ x = x, y = y })
	--return true
	return grid_val ~= 0
end

function update(delta)
	CURRENT_FRAME_TIME = CURRENT_FRAME_TIME + delta
	if CURRENT_FRAME_TIME < TARGET_FRAME_TIME then return end
	CURRENT_FRAME_TIME = 0
	move_player()
	update_tracker()
end

function update_tracker()
	if GAME_STATE.game_over then return end
	if TRACKER_OBJS.update == nil then
		find_tracker_objs()
	end
	TRACKER_OBJS.update.Active = not TRACKER_OBJS.update.Active
end

function spawn_food()
	local food_pos
	repeat
		food_pos = get_random_pos()
	until get_grid_val(food_pos) == GRID_STATES.EMPTY -- Ensure food doesn't spawn on the snake
	set_grid_val(food_pos, GRID_STATES.FOOD)
	GAME_STATE.food = food_pos
end

function get_random_pos()
	return { x = math.random(1, MAP_SIZE_LOCS), y = math.random(1, MAP_SIZE_LOCS) }
end

function game_over()
	GAME_STATE.game_over = true
	local obj = Tracker:FindObjectForCode("start")
	obj.Active = false
end

function move_player()
	if GAME_STATE.game_over then return end

	local head = GAME_STATE.snake.body[1]
	local newHead = { x = head.x + GAME_STATE.snake.dir.x, y = head.y + GAME_STATE.snake.dir.y }

	-- Check for wall collision
	if newHead.x < 1 or newHead.x > MAP_SIZE_LOCS or newHead.y < 1 or newHead.y > MAP_SIZE_LOCS then
		game_over()
		return
	end

	-- Check for self-collision	
	if get_grid_val(newHead) == GRID_STATES.SNAKE then
		game_over()
		return
	end

	-- Check if the snake eats the food
	local ateFood = (newHead.x == GAME_STATE.food.x and newHead.y == GAME_STATE.food.y)

	-- Add the new head to the snake
	table.insert(GAME_STATE.snake.body, 1, newHead)
	set_grid_val(newHead, GRID_STATES.SNAKE)

	if ateFood then
		-- Increase score and place new food
		add_score()
		spawn_food()
	else
		-- Remove the last segment of the snake if no food was eaten
		local tail = GAME_STATE.snake.body[#GAME_STATE.snake.body]
		set_grid_val(tail, GRID_STATES.EMPTY)
		table.remove(GAME_STATE.snake.body)
	end
end

function add_score(val)
	if val == nil then
		val = 1
	end
	GAME_STATE.score = GAME_STATE.score + val
	update_score()
	if GAME_STATE.score % SCORE_FOR_HINT == 0 and GAME_STATE.score > 0 then
		trySendHint()
	end
end

function reset_score()
	GAME_STATE.score = 0
	update_score()
end

function update_score()
	if TRACKER_OBJS.score == nil then
		find_tracker_objs()
	end
	TRACKER_OBJS.score:SetOverlay(tostring(GAME_STATE.score))
	TRACKER_OBJS.score:SetOverlayFontSize(32)
end

function input(code)
	local dir = DIRECTIONS[code]
	-- don't allow 180 deg turns which would just instantly kill you
	if compare_pos(GAME_STATE.snake.dir, invert_pos(dir)) then
		return
	end
	GAME_STATE.snake.dir = dir
end

function start()
	local obj = Tracker:FindObjectForCode("start")
	if GAME_STATE.game_over and obj and obj.Active then
		init_game()
	end
end

function find_tracker_objs()
	for _, code in ipairs(TRACKER_OBJ_CODES) do
		TRACKER_OBJS[code] = Tracker:FindObjectForCode(code)
	end
end

ScriptHost:AddWatchForCode("start", "start", start)
ScriptHost:AddWatchForCode("placeholder", "placeholder", function (code)
    local obj = Tracker:FindObjectForCode(code)
    if obj then
		obj.Active = false
    end
end)
ScriptHost:AddOnFrameHandler("update", update)
