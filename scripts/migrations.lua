local on_tick_n = require("__flib__.on-tick-n")

local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local creep_eater = require("scripts.creep-eater")

local util = require("scripts.util")

local migrations = {}

function migrations.generic()

  creep.update()
  

end

migrations.versions = {
  ["1.0.1"] = function()
-- game.print("Mod Warmonger changed from 1.0.1")
    local old_global = global
    global = {}

    -- REINITIALIZE

    on_tick_n.init()

    creep.init()
	  corrosion.init()
    creep_eater.init()

    -- MIGRATE
--    local old_enabled = old_global.radioactivity_enabled
    -- The old `global` didn't store the variable until it was needed
--    if old_enabled == nil then
 --     old_enabled = true
    
 --   global.radioactivity.enabled = old_enabled
	
	global.corrosion.enabled = true

    -- Creep
    global.creep.on_biter_base_built = old_global.creep_on_biter_base_built
    global.creep.on_chunk_generated = old_global.creep_on_chunk_generated
    if not old_global.creep_on_chunk_generated then
      global.creep.surfaces[game.get_surface("nauvis").index] = nil
    end
  end


}

return migrations
