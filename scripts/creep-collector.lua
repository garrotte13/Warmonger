local area = require("__flib__.area")
local math = require("__flib__.math")
local misc = require("__flib__.misc")
local corrosion = require("scripts.corrosion")

local constants = require("scripts.constants")
local util = require("scripts.util")

local creep_collector = {}

function IsTileInArray (tile_position, tiles_array)
  for a=1, #tiles_array do
    if ( tiles_array[a][1] == tile_position[1] ) and ( tiles_array[a][2] == tile_position[2] ) then return true end
  end
  return false
end

function NoEnemiesFound (check_surface, tiles_array)
  for a=1, #tiles_array do
    if check_surface.get_tile(tiles_array[a]).name == "kr-creep" then  --we check only true creep for collision with enemies, because fake creep is never under enemy buildings!
      if check_surface.count_entities_filtered{
        position = tiles_array[a],
      type = {"unit-spawner", "turret"},
      force = "enemy"
    } > 0 then return false -- check failed, immediate exit
    end
    end
  end
  return true
end

function creep_collector.collect(player, surface, tiles, sel_area)
  local i = 0
  local j = 0
  local enemies_found = 0
  local tiles_to_set = {}
  local player_pos = player.position
  local max_cr_range = constants.creep_max_range + math.ceil(game.forces.enemy.evolution_factor*10) + 1
  local protecting_entities_types = {"unit-spawner", "turret"}
  local prot_area = sel_area
  local search_enemy_tiles = nil
  local s = 0 -- for debug
  area.ceil(prot_area)

  --   area.expand (prot_area, 32 + math.floor(game.forces.enemy.evolution_factor*85) ) -- checking 1 chunk + evolution
  area.expand (prot_area, max_cr_range)

  enemies_found = enemies_found + surface.count_entities_filtered{
	    area = prot_area,
		type = protecting_entities_types,
		force = "enemy"
	}

  if enemies_found == 0 then
   for _, tile in pairs(tiles) do
    if misc.get_distance(tile.position, player_pos) <= constants.creep_max_reach then --filtering out all tiles exceeding shovel reach
      j = j + 1
      if tile.name == "kr-creep" then
        if search_enemy_tiles then
          if ( enemies_found == 0 ) and (IsTileInArray(tile.position, search_enemy_tiles) ) then  -- it's a fast function or LUA sucks!
            i = i + 1
            tiles_to_set[j] = { name = tile.hidden_tile or "landfill", position = tile.position }
          elseif enemies_found == 0 then s = s + 1 end -- hey, man you selected two separate creep areas, debug counter incremented
        else
          search_enemy_tiles = surface.get_connected_tiles (tile.position, {"fk-creep", "kr-creep"}) -- this can be a little slow function
          if NoEnemiesFound (surface, search_enemy_tiles) then  -- this can be really slow, need to test!
            i = i + 1
            tiles_to_set[j] = { name = tile.hidden_tile or "landfill", position = tile.position }
          else enemies_found = enemies_found + 1 end
        end
      else
       tiles_to_set[j] = { name = tile.hidden_tile or "landfill", position = tile.position }
      end
    end
   end
  end
  if s > 0 then game.print("How many foreign true creep tiles you wrongly selected: " .. s) end -- number of tiles selected from another footprint (not the one with enemy check done)
  if j > 0 and enemies_found == 0 then
    -- local percentage = math.random(constants.creep_collection_rate.min, constants.creep_collection_rate.max)
    local percentage = 100 -- no random gathering anymore
    local collected_amount = math.ceil(i * (percentage / 100))
    local inventory = player.get_main_inventory()
    if i>0 and inventory.can_insert({ name = "biomass", count = collected_amount }) then
      inventory.insert({ name = "biomass", count = collected_amount })
     elseif i>0 then
      util.flying_text_with_sound(player, { "message.kr-inventory-is-full" }, { position = area.center(sel_area) })
      return creep_collector
    end
      util.flying_text_with_sound(player, { "message.kr-collected-amount", collected_amount, { "item-name.biomass" } }, {
      position = area.center(sel_area),
      sound = { path = "kr-collect-creep", volume_modifier = 1 },
    })
      surface.set_tiles(tiles_to_set)
      corrosion.update_tiles(surface)
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
