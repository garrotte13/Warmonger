local corrosion = require("scripts.corrosion")
local circle_rendering = require("scripts.miner-circle-rendering")

local constants = require("scripts.constants")
local util = require("scripts.util")

local creep_collector = {}

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

function creep_collector.tiles_mined(tiles, surface, t, player, robot)
  local cr_tiles = {}
  local cr_count = 1
  local fk_count = 0
  local kr_count = 0
  for i=1, #tiles do
    if tiles[i].old_tile.name == "kr-creep" or tiles[i].old_tile.name == "fk-creep" then
      cr_tiles[cr_count] = {
        name = tiles[i].old_tile.name,
        position = tiles[i].position
      }
      if tiles[i].old_tile.name == "kr-creep" then kr_count = kr_count + 1 else fk_count = fk_count + 1 end
      cr_count = cr_count + 1
    end
  end
  if cr_count == 1 then return end
  --game.print("Creep tiles replaced: " .. cr_count-1)
  surface.set_tiles(cr_tiles)
  local dmg = (cr_count - 1) * math.random(5,7)
  if robot and robot.valid and robot.destructible then
    robot.damage(dmg, "enemy", "acid")
  elseif player then
    local char = player.character
    if char and char.valid then
      char.damage(dmg*2, "enemy", "acid")
    end
  end
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
    for i=1, global.creep_miners_last do
      if global.creep_miners[i] and global.creep_miners[i].entity and global.creep_miners[i].entity.valid then
        if not global.creep_miners[i].prio_box then global.creep_miners[i].prio_box = {} end
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
