local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local creep_eater = require("scripts.creep-eater")

--local util = require("scripts.util")

local migrations = {}

function migrations.generic(ChangedModsData)

  creep.update()
  if ChangedModsData.mod_changes["Warmonger"] then
    local old = ChangedModsData.mod_changes["Warmonger"].old_version

    if not old then
      return
    end
    local major_str, minor_str, build_ver_str = string.match(old, "(%d)%.(%d)%.(%d+)")
    local major = tonumber(major_str)
    local minor = tonumber(minor_str)
    local build_ver = tonumber(build_ver_str)
    if minor < 3 then
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
    if minor == 0 then
      corrosion.init()
    end
    if minor == 3 and build_ver < 8 then
      settings.global["wm-CounterStrike"] = {value = global.corrosion.strike_back}
      settings.global["wm-CreepMinerHints"] = {value = global.corrosion.creepminer_hints}
    end
    if (minor == 2) or ( minor == 3 and build_ver < 8 ) then
      settings.global["wm-CreepCorrosion"] = {value = global.corrosion.enabled}
    end
    if minor == 3 and ( build_ver == 9 or build_ver == 8 ) then
      if settings.global["wm-CreepMiningPollution"].value ~= settings.startup["wm-CreepMiningPollution_s"].value then
        game.print("Miner pollution has been migrated to Startup mod settings. Please change it manually to your preferred value of: ".. settings.global["wm-CreepMiningPollution"].value)
      end
    end
    if minor == 3 and (build_ver > 9 and build_ver < 17) then
     if settings.startup["wm-CreepMiningPollution_s"].value == 1.2 then game.print("Warmonger update recommends reducing Creep Miner emissions coefficient to value = 1 in Startup Mod Settings and reload.") end
     if settings.startup["wm-CreepMiningPollution_s"].value == 0.6 then game.print("Warmonger update recommends reducing Creep Miner emissions coefficient to value = 0.5 in Startup Mod Settings and reload.") end
    end
    global.creep_miner_refuel = settings.global["wm-CreepMinerFueling"].value
  end
end

return migrations
