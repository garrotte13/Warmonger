local event = require("__flib__.event")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")
local on_tick_n = require("__flib__.on-tick-n")

local constants = require("scripts.constants")
local creep_collector = require("scripts.creep-collector")
-- local mining_creep = require("scripts.mining_creep")
local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local migrations = require("scripts.migrations")
local util = require("scripts.util")

util.add_commands(corrosion.commands)

remote.add_interface("kr-creep", creep.remote_interface)

-- BOOTSTRAP

event.on_init(function()
  -- Initialize libraries
  on_tick_n.init()

  creep.init()
  corrosion.init()

  -- Initialize mod
  migrations.generic()
end)

event.on_nth_tick(60, function(e)
 corrosion.affecting()
end)

event.on_configuration_changed(function(e)
-- game.print("Mod Warmonger version or config changed.")
  corrosion.init()
    migrations.generic()
  
end)

event.on_load(function()
-- corrosion = global.corrosion
end)



script.on_event(defines.events.on_built_entity, function(e)
  corrosion.engaging(e.created_entity)
--end, {{filter = "turret"}})
end)

script.on_event(defines.events.on_player_mined_entity, function(e)
  corrosion.disengaging(e.entity)
end)

script.on_event(defines.events.on_entity_died, function(e)
  corrosion.disengaging(e.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(e)
  corrosion.disengaging(e.entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(e)
  corrosion.engaging(e.created_entity)
end)


event.on_biter_base_built(function(e)
  creep.on_biter_base_built(e.entity)
end)

script.on_event(defines.events.on_tick, function()
  creep.process_creep_queue()
end)

event.register({
  defines.events.on_player_selected_area,
  defines.events.on_player_alt_selected_area,
}, function(e)
  local player = game.get_player(e.player_index)
  if (e.item == "kr-creep-collector") and (player.render_mode == defines.render_mode.game) then
    creep_collector.collect(player, e.surface, e.tiles, e.area)
  end
end)



event.on_chunk_generated(function(e)
  creep.on_chunk_generated(e.area, e.surface)
end)

