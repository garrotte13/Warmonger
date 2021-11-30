local event = require("__flib__.event")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")
local on_tick_n = require("__flib__.on-tick-n")

local constants = require("scripts.constants")
local creep_collector = require("scripts.creep-collector")
local creep = require("scripts.creep")
local migrations = require("scripts.migrations")
local util = require("scripts.util")

remote.add_interface("kr-creep", creep.remote_interface)

-- BOOTSTRAP

event.on_init(function()
  -- Initialize libraries
  on_tick_n.init()

  -- Initialize `global` table
  creep.init()

  -- Initialize mod
  migrations.generic()
end)




event.on_biter_base_built(function(e)
  creep.on_biter_base_built(e.entity)
end)


event.register({
  defines.events.on_player_selected_area,
  defines.events.on_player_alt_selected_area,
}, function(e)
  local player = game.get_player(e.player_index)
  if e.item == "kr-creep-collector" then
    creep_collector.collect(player, e.surface, e.tiles, e.area)
--  elseif e.item == "kr-jackhammer" then
--    jackhammer.collect(player, e.surface, e.tiles, e.area)
  end
end)



event.on_chunk_generated(function(e)
  creep.on_chunk_generated(e.area, e.surface)
end)

