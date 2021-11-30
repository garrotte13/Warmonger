local on_tick_n = require("__flib__.on-tick-n")

local creep = require("scripts.creep")
-- local freeplay = require("scripts.freeplay")
local util = require("scripts.util")

local migrations = {}

function migrations.generic()
--  freeplay.add_bonus_items()
--  freeplay.add_to_crash_site()
--  freeplay.disable_rocket_victory()
--  util.ensure_turret_force()


end

local function find_on_all_surfaces(filters)
  local output = {}
  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered(filters)
    for _, entity in pairs(entities) do
      table.insert(output, entity)
    end
  end
  return output
end

migrations.versions = {
  ["1.2.0"] = function()
    -- NUKE EVERYTHING

    local old_global = global
    global = {}

    -- REINITIALIZE

    on_tick_n.init()

    creep.init()

    -- MIGRATE

    -- Creep
    global.creep.on_biter_base_built = old_global.creep_on_biter_base_built
    global.creep.on_chunk_generated = old_global.creep_on_chunk_generated
    if not old_global.creep_on_chunk_generated then
      global.creep.surfaces[game.get_surface("nauvis").index] = nil
    end


  end,
  ["1.2.4"] = function()

  end,
}

return migrations
