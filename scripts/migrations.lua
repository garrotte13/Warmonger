local on_tick_n = require("__flib__.on-tick-n")

local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local creep_eater = require("scripts.creep-eater")

local util = require("scripts.util")

local migrations = {}

function migrations.generic(ChangedModsData)

  creep.update()
  if ChangedModsData.mod_changes["Warmonger"] then
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
    if old and (old:match("1%.3%.%d") ) then
      settings.global["wm-CounterStrike"] = {value = global.corrosion.strike_back}
      settings.global["wm-CreepMinerHints"] = {value = global.corrosion.creepminer_hints}
    end
    if old and (old:match("1%.2%.%d") or old:match("1%.3%.%d")) then
      settings.global["wm-CreepCorrosion"] = {value = global.corrosion.enabled}
    end
    if old and (old=="1.3.9" or old=="1.3.8") then
      if settings.global["wm-CreepMiningPollution"].value ~= settings.startup["wm-CreepMiningPollution_s"].value then
        game.print("Miner pollution has been migrated to Startup mod settings. Please change it manually to your preferred value of: ".. settings.global["wm-CreepMiningPollution"].value)
      end
    end
    global.creep_miner_refuel = settings.global["wm-CreepMinerFueling"].value
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
