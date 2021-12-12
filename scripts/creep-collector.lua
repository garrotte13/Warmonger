local area = require("__flib__.area")
local math = require("__flib__.math")
local misc = require("__flib__.misc")
local corrosion = require("scripts.corrosion")

local constants = require("scripts.constants")
local util = require("scripts.util")

local creep_collector = {}


function creep_collector.collect(player, surface, tiles, sel_area)
  local i = 0
  local enemies_found = 0
  local tiles_to_set = {}
  local player_pos = player.position
  local max_cr_range = constants.creep_max_range + math.ceil(game.forces.enemy.evolution_factor*10) + 1
  local protecting_entities_types = {"unit-spawner", "turret"}
  local prot_area = sel_area
  area.ceil(prot_area)

  if settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value then
    -- we miss here for Rampant interface to find nearby bases (if it's possible to do in real time)
    area.expand (prot_area, 64) -- checking 2 not-aligned chunks radius
  else
    area.expand (prot_area, max_cr_range) -- checking only for creep spawners in easy game
  end

  enemies_found = enemies_found + surface.count_entities_filtered{
	    area = prot_area,
		type = protecting_entities_types,
		force = "enemy"
	}
  if enemies_found == 0 then
   for _, tile in pairs(tiles) do
    if misc.get_distance(tile.position, player_pos) <= constants.creep_max_reach then
      if tile.name == "kr-creep" then i = i + 1 end -- fake creep doesn't give biomass
      tiles_to_set[i] = { name = tile.hidden_tile or "landfill", position = tile.position }
    end
   end
  end
  if i > 0 then
    -- local percentage = math.random(constants.creep_collection_rate.min, constants.creep_collection_rate.max)
    local percentage = 100 -- no random gathering anymore
    local collected_amount = math.ceil(i * (percentage / 100))
    local inventory = player.get_main_inventory()
    if inventory.can_insert({ name = "biomass", count = collected_amount }) then
      inventory.insert({ name = "biomass", count = collected_amount })
      surface.set_tiles(tiles_to_set)
      corrosion.update_tiles(surface)
      util.flying_text_with_sound(player, { "message.kr-collected-amount", collected_amount, { "item-name.biomass" } }, {
        position = area.center(sel_area),
        sound = { path = "kr-collect-creep", volume_modifier = 1 },
      })
    else
      util.flying_text_with_sound(player, { "message.kr-inventory-is-full" }, { position = area.center(sel_area) })
    end
  else
   if enemies_found == 0 then
      util.flying_text_with_sound(player, { "message.kr-no-creep-in-selection" }, { position = area.center(sel_area) })
   else
    util.flying_text_with_sound(player, { "message.wm-protected-creep-in-selection" }, { position = area.center(sel_area),
     sound = { path = "creep-access-denied", volume_modifier = 1 },
    })
   end
  end
end

return creep_collector
