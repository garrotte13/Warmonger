local on_tick_n = require("__flib__.on-tick-n")

local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local creep_eater = require("scripts.creep-eater")

local util = require("scripts.util")

local migrations = {}

function migrations.generic(ChangedModsData)

  creep.update()
  local old = ChangedModsData.mod_changes["Warmonger"].old_version
  if old and (old:match("1%.2%.%d") or old:match("1%.0%.%d") or old:match("1%.1%.%d") ) then
    creep_eater.init()
    if game.forces["player"].technologies["advanced-material-processing"].researched then
      game.forces["player"].recipes["creep-miner0-radar"].enabled = true
    end
    if game.forces["player"].technologies["electric-energy-distribution-2"].researched then
      game.forces["player"].recipes["creep-miner1-radar"].enabled = true
    end
    if game.forces["player"].technologies["kr-bio-processing"].researched then
      game.forces["player"].recipes["wm-residue-sulphuric-acid"].enabled = true
    end
  end
  if old and (old:match("1%.0%.%d") ) then
    corrosion.init()
  end
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
    --creep_eater.init()

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
