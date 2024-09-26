ENABLE_DEBUG_LOG = true
DEBUG = true

print("-- Snake in PopTracker --")
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

-- Utility Script for helper functions etc.
require "scripts.utils"
-- Custom Item Scripts
require "scripts.custom_items.arrow"

-- Items
Tracker:AddItems("items/items.jsonc")
ArrowItem("Left")
ArrowItem("Right")
ArrowItem("Up")
ArrowItem("Down")
-- Maps
Tracker:AddMaps("maps/maps.jsonc")
-- Game Logic
require "scripts.logic.game"
-- Locations
Tracker:AddLocations("locations/locations.jsonc")
-- Layout
Tracker:AddLayouts("layouts/items.jsonc")
Tracker:AddLayouts("layouts/tracker.jsonc")
Tracker:AddLayouts("layouts/settings.jsonc")

require "scripts.logic.archipelago"

init_game()
