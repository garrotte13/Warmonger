local event = require("__flib__.event")

--local constants = require("scripts.constants")
local creep_collector = require("scripts.creep-collector")
local creep_eater = require("scripts.creep-eater")
local circle_rendering = require("scripts.miner-circle-rendering")
local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local migrations = require("scripts.migrations")

--local util = require("scripts.util")
--util.add_commands(corrosion.commands)

remote.add_interface("kr-creep", creep.remote_interface)

event.on_init(function()
  -- Initialize libraries
  --on_tick_n.init()

  creep.init()
  corrosion.init()
  creep_eater.init()


end)

event.on_nth_tick(60, function(e)
 corrosion.affecting()
end)

 event.on_nth_tick(3, function(e)
  creep_eater.process()
end)

event.on_configuration_changed(function(ChangedModData)

    migrations.generic(ChangedModData)
  
end)

event.on_load(function()

end)

--[[
script.on_event(defines.events.on_player_main_inventory_changed, function(e)
  local player = game.players[e.player_index]
  circle_rendering.SwapInventory(player)
end)
--]]


script.on_event(defines.events.on_script_trigger_effect, function(e)
  local surface = game.surfaces[e.surface_index]
    creep.landed_strike(e.effect_id, surface, e.target_position, e.target_entity)
end)


script.on_event(defines.events.on_selected_entity_changed, function(e)
  local player = game.players[e.player_index]
  circle_rendering.selection_changed(player)
end)


script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
  local player = game.players[e.player_index]
  circle_rendering.cursor_changed(player)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == "wm-CreepCorrosion" then global.corrosion.enabled = settings.global["wm-CreepCorrosion"].value
  elseif e.setting == "wm-CounterStrike" then global.corrosion.strike_back = settings.global["wm-CounterStrike"].value
  elseif e.setting == "wm-CreepMinerHints" then global.corrosion.creepminer_hints = settings.global["wm-CreepMinerHints"].value
  elseif e.setting == "wm-CreepMinerFueling" then global.creep_miner_refuel = settings.global["wm-CreepMinerFueling"].value end
end)


script.on_event(defines.events.on_built_entity, function(e)
  if e.created_entity.valid and (e.created_entity.name == "creep-miner1-radar" or e.created_entity.name == "creep-miner0-radar") then
    creep_eater.add (e.created_entity)
  elseif e.created_entity.name == "entity-ghost" and (e.created_entity.ghost_name == "creep-miner1-radar" or e.created_entity.ghost_name == "creep-miner0-radar") then
    circle_rendering.add_circle(e.created_entity, game.players[e.player_index])
  else corrosion.engaging(e.created_entity) end
end)

script.on_event(defines.events.on_player_mined_entity, function(e)
  corrosion.disengaging(e.entity)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar") then
    creep_eater.remove (e.entity, false)
  end
end)

script.on_event(defines.events.on_entity_died, function(e)
  corrosion.disengaging(e.entity)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar") then
    creep_eater.remove (e.entity, true)
  elseif global.corrosion.enabled and global.corrosion.strike_back
   and (e.entity.force.name == "enemy") and (e.entity.type == "unit-spawner" or e.entity.type == "turret")
    and game.forces.enemy.evolution_factor > 0.38 then
     creep.check_strike(e.entity, e.cause, e.force)
  end
end)

script.on_event(defines.events.on_robot_mined_entity, function(e)
  corrosion.disengaging(e.entity)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar") then
    creep_eater.remove (e.entity, false)
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(e)
  if e.created_entity.valid and (e.created_entity.name == "creep-miner1-radar" or e.created_entity.name == "creep-miner0-radar") then
    creep_eater.add (e.created_entity)
  else corrosion.engaging(e.created_entity) end
end)

script.on_event(defines.events.script_raised_built, function(e)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar" or
  e.entity.name == "entity-ghost" and (e.entity.ghost_name == "creep-miner1-radar" or e.entity.ghost_name == "creep-miner0-radar")) then
    local last_user = game.players[e.player_index]
    circle_rendering.add_circle(e.entity, last_user)
  end
end)

script.on_event(defines.events.script_raised_destroy, function(e)
  if e.entity.valid and
    (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar" or
      e.entity.name == "entity-ghost" and (e.entity.ghost_name == "creep-miner1-radar" or e.entity.ghost_name == "creep-miner0-radar")) then
        circle_rendering.remove_circle(e.entity)
  end
end)

script.on_event(defines.events.on_tick, function()
  creep.process_creep_queue()
end)

script.on_event(defines.events.on_sector_scanned, function(e)
  creep_eater.scanned(e.radar)
end, {{filter="name", name="creep-miner1-radar"}, {filter="name", name="creep-miner0-radar"}} )


event.register({
  defines.events.on_player_selected_area
  --defines.events.on_player_alt_selected_area,
}, function(e)
  local player = game.get_player(e.player_index)
  if (e.item == "kr-creep-collector") and (player.render_mode == defines.render_mode.game) then
    creep_collector.collect(player, e.surface, e.tiles, e.area)
  end
end)

event.register({
  defines.events.on_player_alt_selected_area
}, function(e)
  local player = game.get_player(e.player_index)
  if (e.item == "kr-creep-collector") then
    creep_collector.priority_box(player, e.surface, e.tiles, e.area)
  end
end)

script.on_event(defines.events.on_pre_player_removed, function(e)
  if global.prio_creep_mine then creep_collector.player_removed(e.player_index) end
end)

if not (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then

  event.on_chunk_generated(function(e)
    creep.on_chunk_generated(e.area, e.surface)
  end)

  event.on_biter_base_built(function(e)
    creep.on_biter_base_built(e.entity)
  end)

end