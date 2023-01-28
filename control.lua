--local constants = require("scripts.constants")
local creep_collector = require("scripts.creep-collector")
local creep_eater = require("scripts.creep-eater")
local circle_rendering = require("scripts.miner-circle-rendering")
local creep = require("scripts.creep")
local corrosionF = require("scripts.corrosion")
local migrations = require("scripts.migrations")

local action_ticks
local corrosion
local miner_queue

--local util = require("scripts.util")
--util.add_commands(corrosion.commands)

remote.add_interface("kr-creep", creep.remote_interface)

local function add_hooks()
  if not (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then

    script.on_event(defines.events.on_chunk_generated, function(e)
      creep.on_chunk_generated(e.area, e.surface)
    end)

    script.on_event(defines.events.on_biter_base_built, function(e)
      creep.on_biter_base_built(e.entity)
    end)
  end

end

script.on_init(function()

  creep.init()
  corrosionF.init()
  corrosion = global.corrosion
  creep_eater.init()
  global.dissention = {}
  global.dissention[0] = {active_miner = nil}
  action_ticks = global.dissention
  miner_queue = global.creep_miners_queue
  add_hooks()
end)

script.on_load(function(e)
  action_ticks = global.dissention
  corrosion = global.corrosion
  miner_queue = global.creep_miners_queue
  add_hooks()
end)

--[[script.on_nth_tick(60, function(e)
 corrosion.affecting()
end) 

script.on_nth_tick(3, function(e)
  creep_eater.process()
end)
--]]

script.on_event(defines.events.on_tick, function(event)
  local t = event.tick
  creep.process_creep_queue(t)
  local act_now = action_ticks[t]
  if act_now then   -- we have something to do today
    if act_now.active_miner then -- we do have some troubling creep miner today
      if global.creep_miners[act_now.active_miner] then
        global.creep_miners[act_now.active_miner].next_tick = 0
        if global.creep_miners[act_now.active_miner].stage == 0 and global.creep_miners[act_now.active_miner].ready_tiles > 0 then
          global.creep_miners_lastq = global.creep_miners_lastq + 1
          global.creep_miners_queue[global.creep_miners_lastq] = act_now.active_miner
        elseif global.creep_miners[act_now.active_miner].stage == 60 then
          creep_eater.process(action_ticks, act_now.active_miner, t)
        end
      end
  end
    if corrosion.enabled and act_now.corrosion_affected then -- we do have something to corrode today
      for _, pos in pairs(act_now.corrosion_affected) do
        local entity = corrosion.affected[pos.x .. ":" .. pos.y].e
        if entity.valid and ( corrosion.affected[pos.x .. ":" .. pos.y].no_check or corrosionF.is_still_affected(entity) ) then
          corrosion.affected[pos.x .. ":" .. pos.y].no_check = true
          corrosionF.affect(entity)
          if action_ticks[t+30] then
            if action_ticks[t+30].corrosion_affected then
              table.insert(action_ticks[t+30].corrosion_affected, {x = pos.x, y = pos.y})
            else
              action_ticks[t+30].corrosion_affected = {{x = pos.x, y = pos.y}}
            end
          else
            action_ticks[t+30] = { corrosion_affected = {{x = pos.x, y = pos.y}} }
          end
          corrosion.affected[pos.x .. ":" .. pos.y].next_tick = t+30

        else
          corrosion.affected_num = corrosion.affected_num - 1
          corrosion.affected[pos.x .. ":" .. pos.y] = nil
        end
      end
    end
    act_now[t] = nil
  end
  if global.creep_miners_queue[1] and creep_eater.process(action_ticks, global.creep_miners_queue[global.creep_miners_id], t) then
    global.creep_miners_id = global.creep_miners_id + 1
    if global.creep_miners_id > global.creep_miners_lastq then
      global.creep_miners_queue = {}
      global.creep_miners_id = 1
      global.creep_miners_lastq = 0
      --game.print("No more miners to process tiles.")
    end
  end
end)

script.on_configuration_changed(function(ChangedModData)

    migrations.generic(ChangedModData)
    action_ticks = global.dissention
    corrosion = global.corrosion
    miner_queue = global.creep_miners_queue
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
  if e.setting == "wm-CreepCorrosion" then corrosion.enabled = settings.global["wm-CreepCorrosion"].value
  elseif e.setting == "wm-CounterStrike" then corrosion.strike_back = settings.global["wm-CounterStrike"].value
  elseif e.setting == "wm-CreepMinerHints" then corrosion.creepminer_hints = settings.global["wm-CreepMinerHints"].value
  elseif e.setting == "wm-CreepMinerFueling" then global.creep_miner_refuel = settings.global["wm-CreepMinerFueling"].value end
end)


script.on_event(defines.events.on_built_entity, function(e)
  if e.created_entity.valid and (e.created_entity.name == "creep-miner1-radar" or e.created_entity.name == "creep-miner0-radar") then
    creep_eater.add (e.created_entity, e.tick)
  elseif e.created_entity.name == "entity-ghost" and (e.created_entity.ghost_name == "creep-miner1-radar" or e.created_entity.ghost_name == "creep-miner0-radar") then
    circle_rendering.add_circle(e.created_entity, game.players[e.player_index])
  else corrosionF.engaging(e.created_entity, e.tick) end
end)

script.on_event(defines.events.on_player_mined_entity, function(e)
  corrosionF.disengaging(e.entity)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar") then
    creep_eater.remove (e.entity, false)
  end
end)

script.on_event(defines.events.on_entity_died, function(e)
  corrosionF.disengaging(e.entity)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar") then
    creep_eater.remove (e.entity, true)
  elseif corrosion.enabled and corrosion.strike_back
   and (e.entity.force.name == "enemy") and (e.entity.type == "unit-spawner" or e.entity.type == "turret")
    and game.forces.enemy.evolution_factor > 0.38 then
     creep.check_strike(e.entity, e.cause, e.force)
  end
end)

script.on_event(defines.events.on_robot_mined_entity, function(e)
  corrosionF.disengaging(e.entity)
  if e.entity.valid and (e.entity.name == "creep-miner1-radar" or e.entity.name == "creep-miner0-radar") then
    creep_eater.remove (e.entity, false)
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(e)
  if e.created_entity.valid and (e.created_entity.name == "creep-miner1-radar" or e.created_entity.name == "creep-miner0-radar") then
    creep_eater.add (e.created_entity, e.tick)
  else corrosionF.engaging(e.created_entity, e.tick) end
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

script.on_event(defines.events.on_sector_scanned, function(e)
  creep_eater.scanned(e.radar, e.tick)
end, {{filter="name", name="creep-miner1-radar"}, {filter="name", name="creep-miner0-radar"}} )


script.on_event(defines.events.on_player_selected_area, function(e)
  local player = game.get_player(e.player_index)
  if (e.item == "kr-creep-collector") and (player.render_mode == defines.render_mode.game) then
    creep_collector.collect(player, e.surface, e.tiles, e.area)
  end
end)

script.on_event(defines.events.on_player_alt_selected_area, function(e)
  local player = game.get_player(e.player_index)
  if (e.item == "kr-creep-collector") then
    creep_collector.priority_box(player, e.surface, e.tiles, e.area)
  end
end)

script.on_event(defines.events.on_pre_player_removed, function(e)
  if global.prio_creep_mine then creep_collector.player_removed(e.player_index) end
end)
