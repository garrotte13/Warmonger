local corrosion = require("scripts.corrosion")
local circle_rendering = require("scripts.miner-circle-rendering")

local constants = require("scripts.constants")
local util = require("scripts.util")

local creep_collector = {}

function IsTileInArray (tile_position, tiles_array)
  for a=1, #tiles_array do
    if ( tiles_array[a].x == tile_position.x ) and ( tiles_array[a].y == tile_position.y ) then return true end
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

function creep_collector.collect_obsolete(player, surface, tiles, sel_area) -- broken implementation
  local i = 0
  local j = 0
  local enemies_found = 0
  local tiles_to_set = {}
  local player_pos = player.position
  local max_cr_range = constants.creep_max_range + math.ceil(game.forces.enemy.evolution_factor*20) + 1
  local protecting_entities_types = {"unit-spawner", "turret"}
  local prot_area = sel_area
  local search_enemy_tiles = nil
  local s = 0 -- for debug
  --area.ceil(prot_area)

  --   area.expand (prot_area, 32 + math.floor(game.forces.enemy.evolution_factor*85) ) -- checking 1 chunk + evolution
  --area.expand (prot_area, max_cr_range)

  enemies_found = enemies_found + surface.count_entities_filtered{
	    area = prot_area,
		type = protecting_entities_types,
		force = "enemy"
	}

  if enemies_found == 0 then
   for _, tile in pairs(tiles) do
   --if misc.get_distance(tile.position, player_pos) <= constants.creep_max_reach then --filtering out all tiles exceeding shovel reach
      j = j + 1
      if tile.name == "kr-creep" then
        if search_enemy_tiles then
          if ( enemies_found == 0 ) and (IsTileInArray(tile.position, search_enemy_tiles) ) then  -- it's a fast function or LUA sucks!
            i = i + 1
            tiles_to_set[j] = { name = tile.hidden_tile or "landfill", position = tile.position }
          elseif enemies_found == 0 then s = s + 1 end -- hey man, you selected two separate creep areas, debug counter incremented
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
    --end
   end
  end
  -- if s > 0 then game.print("How many foreign true creep tiles you wrongly selected: " .. s) end -- number of tiles selected from another footprint (not the one with enemy check done)
  if j > 0 and enemies_found == 0 then
    -- local percentage = math.random(constants.creep_collection_rate.min, constants.creep_collection_rate.max)
    local percentage = 100 -- no random gathering anymore
    local collected_amount = math.ceil(i * (percentage / 100))
    local inventory = player.get_main_inventory()
    if i>0 and inventory.can_insert({ name = "biomass", count = collected_amount }) then
      inventory.insert({ name = "biomass", count = collected_amount })
     elseif i>0 then
      util.flying_text_with_sound(player, { "message.kr-inventory-is-full" }, { position = util.get_centre(sel_area) })
      return creep_collector
    end
      util.flying_text_with_sound(player, { "message.kr-collected-amount", collected_amount, { "item-name.biomass" } }, {
      position = util.get_centre(sel_area),
      sound = { path = "kr-collect-creep", volume_modifier = 1 },
    })
      surface.set_tiles(tiles_to_set)
      corrosion.update_surface(surface) -- broken! shouldn't be run
  else
   if enemies_found == 0 then
      util.flying_text_with_sound(player, { "message.kr-no-creep-in-selection" }, { position = util.get_centree(sel_area) })
   else
    util.flying_text_with_sound(player, { "message.wm-protected-creep-in-selection" }, { position = util.get_centre(sel_area),
     sound = { path = "creep-access-denied", volume_modifier = 1 },
    })
   end
  end
end

function creep_collector.collect(player, surface, tiles, sel_area)
  local cr_true = 0
  local cr_fake = 0
  for _, tile in pairs(tiles) do
    if tile.name == "kr-creep" then cr_true = cr_true + 1 else cr_fake = cr_fake + 1 end
  end
  player.create_local_flying_text({
    -- create_at_cursor = not options.position,
    position = util.get_centre(sel_area),
    text = {"message.kr-amount-in-selection", cr_true, {"item-name.kr-creep"}, cr_fake, {"item-name.fk-creep"}}
  })
end

function creep_collector.player_removed(player_index)
  if global.prio_creep_mine[player_index] then circle_rendering.del_prio_rect(global.prio_creep_mine[player_index], game.get_player(player_index)) end
  global.prio_creep_mine[player_index] = nil
end

function creep_collector.priority_box(player, surface, tiles, sel_area)
  if not global.prio_creep_mine then global.prio_creep_mine = {} end
  if global.prio_creep_mine[player.index] then circle_rendering.del_prio_rect(global.prio_creep_mine[player.index], player) end
  if tiles and tiles[1] then
    sel_area = util.box_ceiling(sel_area)
    local h_height = math.abs(sel_area.right_bottom.y - sel_area.left_top.y) / 2
    local h_width = math.abs(sel_area.right_bottom.x - sel_area.left_top.x) / 2
    local area_centre = {x = sel_area.left_top.x + h_width, y = sel_area.left_top.y + h_height}
    local add_to_rad = ( h_height * h_height ) + ( h_width * h_width )
    for i=1, global.creep_miners_last do
      if global.creep_miners[i] and global.creep_miners[i].entity and global.creep_miners[i].entity.valid then
        if not global.creep_miners[i].prio_box then global.creep_miners[i].prio_box = {} end
--[[
        if ((global.creep_miners[i].x - area_centre.x)^2 + (global.creep_miners[i].y - area_centre.y)^2) <= ( (constants.miner_range(global.creep_miners[i].entity.name) + 1)^2 + add_to_rad ) then
          global.creep_miners[i].prio_box[player.index] = 1
        else
          global.creep_miners[i].prio_box[player.index] = 2
        end
]]
        global.creep_miners[i].prio_box[player.index] = nil

      end
    end
    global.prio_creep_mine[player.index] = sel_area
    --TO DO Create new render
    circle_rendering.add_prio_rect(sel_area, player, surface)
  else
    global.prio_creep_mine[player.index] = nil
  end

end

return creep_collector
