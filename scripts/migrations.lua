local creep = require("scripts.creep")
local corrosion = require("scripts.corrosion")
local creep_eater = require("scripts.creep-eater")
local util = require("scripts.util")

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
      global.dissention = {}
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
    if (minor > 0 and minor < 3) or ( minor == 3 and build_ver < 18) then
      global.dissention = {}
      global.dissention[0] = {active_miner = nil}
      local t = game.tick
      if global.corrosion.affected_num > 0 then
        local new_wave = {}
        local my_tick
        for pos_Str, entity in pairs(global.corrosion.affected) do
          local e_area = util.box_ceiling(entity.selection_box)
          my_tick = t + 17 + math.random(1, 15)
          new_wave[pos_Str] = {e = entity, next_tick = my_tick, no_check = false} -- will re-check every corrosion affected building
          if global.dissention[my_tick] then
            if global.dissention[my_tick].corrosion_affected then
              table.insert(global.dissention[my_tick].corrosion_affected, {x = e_area.left_top.x, y = e_area.left_top.y})
            else
              global.dissention[my_tick].corrosion_affected = {{x = e_area.left_top.x, y = e_area.left_top.y}}
            end
          else
            global.dissention[my_tick] = { corrosion_affected = {{x = e_area.left_top.x, y = e_area.left_top.y}} }
          end
        end
        global.corrosion.affected = new_wave
      end
      global.creep_miners_queue = {}
      global.creep_miners_id = 1
      global.creep_miners_lastq = 0
      if global.creep_miners_count > 0 then
        local gt = game.ticks_played
        local my_tick
        local miner
        for i = 1, global.creep_miners_last do
          if global.creep_miners[i] then
            if global.creep_miners[i].entity and global.creep_miners[i].entity.valid then
              miner = global.creep_miners[i]
              if miner.stage == 0 and miner.ready_tiles > 0 then
                creep_eater.add_action_tick(global.dissention, i, t + math.random(1, 30))
              elseif miner.stage == 0 then
                miner.next_tick = 0
              elseif miner.stage == 40 then
                  creep_eater.add_action_tick(global.dissention, i, t + math.random(1, 20))
                  miner.stage = 0
              elseif miner.stage == 60 then
                my_tick = (gt - miner.deactivation_tick) - 600
                if my_tick < 5 then my_tick = 5 end
                creep_eater.add_action_tick(global.dissention, i, t + my_tick + math.random(1, 70))
              elseif miner.stage == 51 then
                my_tick = (gt - miner.deactivation_tick) - 180
                if my_tick < 1 then my_tick = 1 end
                creep_eater.add_action_tick(global.dissention, i, t + my_tick + math.random(1, 50))
                miner.stage = 0
              elseif miner.stage == 50 then
                my_tick = (gt - miner.deactivation_tick) - 7200
                if my_tick < 10 then my_tick = 10 end
                creep_eater.add_action_tick(global.dissention, i, t + my_tick + math.random(1, 150))
                miner.stage = 0
              else -- currently processed miner
                global.creep_miners_queue[1] = i
                global.creep_miners_lastq = 1
                if miner.stage == 3 then miner.stage = 5 end
                --creep_eater.add_action_tick(global.dissention, i, t + math.random(1, 15))
              end
            else
              global.creep_miners[i] = nil
              global.creep_miners_count = global.creep_miners_count - 1
            end
          end
        end
      end

    end
  end
end

return migrations
