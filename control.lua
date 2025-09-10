local creep_collector = require("scripts.creep-collector")
local creep = require("scripts.creep")

local biters_eco
local strike_back

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

  creep.init()
  add_hooks()
  creep.creepify()
  biters_eco = settings.global["wm-ecoFriendlyBiters"].value
  strike_back = settings.global["wm-CounterStrike"].value 
end)

script.on_load(function(e)
  biters_eco = settings.global["wm-ecoFriendlyBiters"].value
  strike_back = settings.global["wm-CounterStrike"].value
  add_hooks()
end)

script.on_event(defines.events.on_script_trigger_effect, function(e)
  local surface = game.surfaces[e.surface_index]
    creep.landed_strike(e.effect_id, surface, e.target_position, e.target_entity)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  if e.setting == "wm-ecoFriendlyBiters" then biters_eco = settings.global["wm-ecoFriendlyBiters"].value
  elseif e.setting == "wm-CounterStrike" then strike_back = settings.global["wm-CounterStrike"].value end
end)

script.on_event(defines.events.on_entity_died, function(e)
  if strike_back
   and (e.entity.force.name == "enemy") and (e.entity.type == "unit-spawner" or e.entity.type == "turret")
    and game.forces.enemy.get_evolution_factor(e.entity.surface) > 0.38 then
      game.print("Checking if it's time for counter attack...")
     creep.check_strike(e.entity, e.cause, e.force)
  end
end)

script.on_event(defines.events.on_player_built_tile, function(e)
  creep_collector.tiles_mined(e.tiles, game.surfaces[e.surface_index], e.tick, game.players[e.player_index])
end)
script.on_event(defines.events.on_robot_built_tile, function(e)
  creep_collector.tiles_mined(e.tiles, game.surfaces[e.surface_index], e.tick, nil, e.robot)
end)