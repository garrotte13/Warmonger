local creep_collector = require("scripts.creep-collector")
local creep = require("scripts.creep")
local creepmining = require("scripts.bot-creep-mining")

local biters_eco
local strike_back
local action_ticks

remote.add_interface("kr-creep", creep.remote_interface)

local function add_hooks()
--  if not (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then

    script.on_event(defines.events.on_chunk_generated, function(e)
      creep.on_chunk_generated(e.area, e.surface)
    end)

    script.on_event(defines.events.on_biter_base_built, function(e)
      creep.on_biter_base_built(e.entity)
    end)
--  end

end

script.on_init(function()
  storage.wm_creep_miners = {}
  storage.wm_creep_miners_count = 0
  storage.wm_creep_fields = {}
  storage.wm_cr_fields_meta = {}
  storage.dissention = {}
  storage.dissention[0] = {bot = nil}
  action_ticks = storage.dissention
  creep.init()
  add_hooks()
  creep.creepify()
  biters_eco = settings.global["wm-ecoFriendlyBiters"].value
  strike_back = settings.global["wm-CounterStrike"].value 
end)

script.on_load(function(e)
  biters_eco = settings.global["wm-ecoFriendlyBiters"].value
  strike_back = settings.global["wm-CounterStrike"].value
  action_ticks = storage.dissention
  add_hooks()
end)

script.on_event(defines.events.on_tick, function(event)
  local t = event.tick
  creep.process_creep_queue(t)
  local act_now = action_ticks[t]
  if act_now then
    if act_now.tree then
      local foundPosition
      local n_tree
      foundPosition = act_now.tree.surface.find_non_colliding_position(act_now.tree.name, act_now.tree.position, 5, 0.5)
      if foundPosition then
        n_tree = act_now.tree.surface.create_entity({
          name = act_now.tree.name,
          position = foundPosition,
          force = act_now.tree.force,
          direction = act_now.tree.direction,
          raise_built = true,
        })

      end
     --[[if n_tree then game.print("A tree is re-built at [gps=".. foundPosition.x ..",".. foundPosition.y .."]") else
      game.print("Tree rebuilding failed at [gps=".. act_now.tree.position.x ..",".. act_now.tree.position.y .."]")
      end]]
    end
    if act_now.bot then
      creepmining.process(act_now.bot, t)
    end
    action_ticks[t] = nil
  end
end)

script.on_event(defines.events.on_script_trigger_effect, function(e)
  local surface = game.surfaces[e.surface_index]
    creep.landed_strike(e.effect_id, surface, e.target_position, e.target_entity)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == "wm-ecoFriendlyBiters" then biters_eco = settings.global["wm-ecoFriendlyBiters"].value
  elseif e.setting == "wm-CounterStrike" then strike_back = settings.global["wm-CounterStrike"].value end
end)



script.on_event(defines.events.on_built_entity, function(e)
  if e.entity.valid and e.entity.name == "wm-droid-1" then
    creepmining.add(e.entity, e.player_index, e.tick)
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(e) -- shouldn't happen?
  if e.entity.valid and e.entity.name == "wm-droid-1" then
    creepmining.add(e.entity, nil, e.tick)
  end
end)

script.on_event(defines.events.on_player_mined_entity, function(e)
  if e.entity.valid and e.entity.name == "wm-droid-1" then
    creepmining.remove(nil, e.entity, e.buffer, e.tick)
  end
end)

script.on_event(defines.events.on_robot_mined_entity, function(e) -- shouldn't happen?
  if e.entity.valid and e.entity.name == "wm-droid-1" then
    creepmining.remove(nil, e.entity, e.buffer, e.tick)
  end
end)

script.on_event(defines.events.on_entity_died, function(e)
  if e.entity.valid and e.entity.name == "wm-droid-1" then
    creepmining.remove(nil, e.entity, nil, e.tick)
  elseif biters_eco and e.entity.type == "tree" and e.force.name == "enemy" then
    local new_tree = {
      name = e.entity.name,
      position = e.entity.position,
      force = e.entity.force,
      surface = e.entity.surface,
      direction = e.entity.direction
    }
    local next_tick = e.tick + 55000 + math.random(1, 1200)
    while action_ticks[next_tick] and action_ticks[next_tick].tree do
      next_tick = next_tick + 1
    end
    if action_ticks[next_tick] then action_ticks[next_tick].tree = new_tree
    else
        action_ticks[next_tick] = { tree = new_tree }
    end
    --game.print("A tree was destroyed by biters")
  elseif strike_back
   and (e.entity.force.name == "enemy") and (e.entity.type == "unit-spawner" or e.entity.type == "turret")
    and game.forces.enemy.get_evolution_factor(e.entity.surface) > 0.38 then
      --game.print("Checking if it's time for counter attack...")
     creep.check_strike(e.entity, e.cause, e.force)
  end
end)


script.on_event(defines.events.on_ai_command_completed, function(e)
  if storage.wm_creep_miners[e.unit_number] then
    if e.result == defines.behavior_result.success then
      creepmining.arrival(e.unit_number, e.tick)
    else
      creepmining.confusion(e.unit_number, e.tick)
    end
  end
end)

script.on_event(defines.events.on_selected_entity_changed, function(e)
  creepmining.Show_Selected(e)
end)


script.on_event(defines.events.on_player_built_tile, function(e)
  creep_collector.tiles_mined(e.tiles, game.surfaces[e.surface_index], e.tick, game.players[e.player_index])
end)
script.on_event(defines.events.on_robot_built_tile, function(e)
  creep_collector.tiles_mined(e.tiles, game.surfaces[e.surface_index], e.tick, nil, e.robot)
end)

script.on_event(defines.events.on_player_selected_area, function(e)
  local player = game.get_player(e.player_index)
  if (e.item == "kr-creep-collector") then
    creep_collector.collect(player, e.surface, e.tiles, e.area)
  end
end)