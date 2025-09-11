local constants = require("scripts.constants")
--local corrosion = require("scripts.corrosion")
--local creep_eater = require("scripts.creep-eater")

local creeping = {}

local function generate_creep(entities) -- all entities must be strictly from one surface. Surface is pre-checked for creep allowed
  local surface = entities[1].surface
  local min_r = 2
  for _, entity in pairs(entities) do
    if entity.type == "unit-spawner" then min_r = 1 else min_r = 0 end
    storage.creep.creep_queue[storage.creep.creep_id_counter] = {
      radius = math.random(2, (constants.creep_max_range + min_r - 3)) + min_r + math.floor(game.forces.enemy.get_evolution_factor(surface)*4.5*(min_r+1)),
      position = entity.position,
      stage = 0,
      surface = surface,
      fake = false,
      type = min_r + 1,
      tier = 1 + math.floor(game.forces.enemy.get_evolution_factor(surface) * 9.8)
    }
    storage.creep.creep_id_counter = storage.creep.creep_id_counter + 1
  end
end

function creeping.creepify()
  local surface = game.get_surface("nauvis")
  local entities = surface.find_entities_filtered({ type = { "unit-spawner", "turret" }, force = "enemy" })

  surface.destroy_decoratives{name = {
      "enemy-decal",
      "enemy-decal-transparent",
      "muddy-stump",
      "worms-decal",
      "light-mud-decal",
      "dark-mud-decal",
      --"red-croton",
      --"red-pita",
      --"lichen-decal",
      --"shroom-decal"
    },
  }


   -- if not (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then
    for _, entity in pairs(entities) do
      if entity.valid then generate_creep({ entity }) end
    end
    --[[ else
    for _, entity in pairs(entities) do
      local building_name = entity.name
      local rad
      local type_name
      local building_type
      local building_tier

      type_name, building_tier = string.match(building_name, ".+%-(.+)%-v%d+%-t(%d+)%-rampant")
      if entity.valid and type_name and building_tier then

          local buildings_tbl = {
            ["hive"] = 3,
            ["spitter-spawner"] = 2,
            ["biter-spawner"] = 2,
            ["spawner"] = 2,
            ["worm"] = 1
          }
          building_type = buildings_tbl[type_name]
          rad = math.random(3, (constants.creep_max_range + building_type - 2)) + math.floor(building_type * building_tier * 0.5) + building_type - 2

        storage.creep.creep_queue[storage.creep.creep_id_counter] = {
            radius = rad,
            position = entity.position,
            stage = 0,
            surface = surface,
            fake = false,
            type = building_type,
            tier = building_tier
        }
        storage.creep.creep_id_counter = storage.creep.creep_id_counter + 1
      end
    end
    
  end
  ]]
  local t = game.tick
  while storage.creep.creep_id_counter > (storage.creep.last_creep_id_counter+20) do
    creeping.process_creep_queue(t)
  end
  --[[
  if game.forces["player"].technologies["advanced-material-processing"].researched then
    game.forces["player"].recipes["creep-miner0-radar"].enabled = true
  end
  if game.forces["player"].technologies["electric-energy-distribution-2"].researched then
    game.forces["player"].recipes["creep-miner1-radar"].enabled = true
  end
  ]]
end

function creeping.init()
  storage.creep = {
    on_biter_base_built = true,
    on_chunk_generated = true,
    creep_id_counter = 0,
    last_creep_id_counter = 0,
    creep_queue = {},
    surfaces = { [game.get_surface("nauvis").index] = true },
  }
end

function creeping.on_biter_base_built(entity)
  if (entity.type == "unit-spawner" or entity.type == "turret") and storage.creep.surfaces[entity.surface.index] then
    generate_creep({ entity })
  end
end

function creeping.on_chunk_generated(chunk_area, surface)
  if not storage.creep.surfaces[surface.index] then
    return
  end
  local entities = surface.find_entities_filtered({ type = { "unit-spawner", "turret" }, area = chunk_area, force = "enemy" })
  for _, entity in pairs(entities) do
    if entity.valid then generate_creep({ entity }) end
  end
end

function creeping.update()
    if not storage.creep.creep_id_counter then
        storage.creep.creep_id_counter = 1
    end
    if not storage.creep.last_creep_id_counter then
        storage.creep.last_creep_id_counter = 1
    end
    if not storage.creep.creep_queue then
        storage.creep.creep_queue = {}
    end
end

function creeping.process_creep_queue(t)
    if storage.creep.creep_id_counter == storage.creep.last_creep_id_counter then
        return
    end

    local creep_pack = storage.creep.creep_queue[storage.creep.last_creep_id_counter]
    if creep_pack.stage == 0 then
        creep_pack.tiles = creep_pack.surface.find_tiles_filtered({
                position = creep_pack.position,
                radius = creep_pack.radius,
                collision_mask = { ground_tile=true }
        })
        creep_pack.stage = 1
    elseif creep_pack.stage == 1 then
        creep_pack.creep_tiles = {}
        local n = 1
        local ne_coef
        local ne_prob
        if creep_pack.tier then
          ne_coef = ( (creep_pack.type or 2) * 1.2 ) + ( creep_pack.tier / 16 )
          ne_prob = 3 + ( creep_pack.tier * 4 ) - (creep_pack.type or 2)
        elseif (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then
          ne_coef = 2 + math.floor(3 * game.forces.enemy.get_evolution_factor(creep_pack.surface))
          ne_prob = 4 + math.ceil(12 * game.forces.enemy.get_evolution_factor(creep_pack.surface))
        else
          ne_coef = 2 + math.floor(2 * game.forces.enemy.get_evolution_factor(creep_pack.surface))
          ne_prob = 4 + math.ceil(20 * game.forces.enemy.get_evolution_factor(creep_pack.surface))
        end
        for i=1,#creep_pack.tiles do
          local r = 1 -- by default it will be biomass creep
          -- local actual_tile = creep_pack.surface.get_tile(creep_pack.tiles[i].position) -- the starting point we could crash replace-path-abuse with new global array
          -- local actual_name = ""
          -- if actual_tile then actual_name = actual_tile.name end
          local actual_name = creep_pack.tiles[i].name
          if actual_name == "kr-creep" then -- we mustn't change fate
            r = 4
          elseif creep_pack.fake then
            if math.random(1,10) > 7 then r = 4 else r = 3 end -- 30% nothing for creep revenge strikes
          else
            -- local d = misc.get_distance(creep_pack.tiles[i].position, creep_pack.position)  -- old flib tiles-wrong calculation again
            local d = math.sqrt(((creep_pack.tiles[i].position.x + 0.5) - creep_pack.position.x) ^ 2 + ((creep_pack.tiles[i].position.y + 0.5) - creep_pack.position.y) ^ 2)
            if (d > 3.8) and ( (creep_pack.radius - d) < 4.9) then   -- no biomass on distal rings
              if math.random(1,10) > 6 then r = 4 else r = 3 end  -- 60% fake creep, 40% nothing
            elseif (d > ne_coef ) then -- bigger and bigger 100% biomass core underneath growing New Enemies structures
              if math.random(1,ne_prob) > 2 then r = 3 end -- less biomass with every 10% or 5% evo increase
            end
          end
            if r < 3 then
              creep_pack.creep_tiles[n] = { name = "kr-creep", position = creep_pack.tiles[i].position }
              n = n + 1
            elseif (r == 3) and (actual_name ~="fk-creep" ) then -- if placing fake creep we need to avoid redundant work
              creep_pack.creep_tiles[n] = { name = "fk-creep", position = creep_pack.tiles[i].position }
              n = n + 1
            end
        end
        creep_pack.stage = 2
    elseif creep_pack.stage == 2 then
        creep_pack.surface.set_tiles(creep_pack.creep_tiles)
        --[[if global.corrosion.enabled then
          creep_pack.stage = 3
        else]]
          storage.creep.creep_queue[storage.creep.last_creep_id_counter] = nil
          storage.creep.last_creep_id_counter = storage.creep.last_creep_id_counter + 1
        --end
      --[[elseif creep_pack.stage == 3 then
      if creep_pack.fake and creep_pack.position then -- mine creepers are awoken only by revenge strikes, not by RampantSiegeAI or Creeper2
        for i=1, storage.creep_miners_last do
          if storage.creep_miners[i] and storage.creep_miners[i].stage == 0
           and storage.creep_miners[i].entity and storage.creep_miners[i].entity.valid and (not storage.creep_miners[i].entity.active) then
            local d = (constants.miner_range(storage.creep_miners[i].entity.name) + creep_pack.radius)^2
            if ((storage.creep_miners[i].x - creep_pack.position.x)^2 + (storage.creep_miners[i].y - creep_pack.position.y)^2) <= d then
              local nex_t = storage.creep_miners[i].next_tick
              if nex_t and nex_t > 0 then global.dissention[nex_t].active_miner = nil end
              storage.creep_miners[i].entity.active = true
              creep_eater.add_action_tick(global.dissention, i, t + 1)
            end
          end
        end

      end
      if creep_pack.position then -- let's quickly engage all player's entities found to be timely checked
        local entities = creep_pack.surface.find_entities_filtered{ position = creep_pack.position, radius = creep_pack.radius+1.5,  force = "player" }
        --local i = 0
        for _, entity in pairs(entities) do
          if entity.valid and entity.destructible and entity.is_entity_with_health then
            corrosion.engaging_fast(entity, t, false) -- check building for collision before corruption dmg application
           -- i = i + 1
         end
        end
        --if i > 0 then game.print("Strike sends ".. i .. " entities for check.") end
      elseif creep_pack.fake then -- creeper2 will slow down game as before
      
          for _, tile in pairs(creep_pack.creep_tiles) do   -- that is creeper2 check
            local entities = creep_pack.surface.find_entities_filtered{
              area = {
                left_top = { x = tile.position.x, y = tile.position.y },
                right_bottom = { x = tile.position.x + 0.96875, y = tile.position.y + 0.96875 },
              },
              force = "player"}
            for _, entity in pairs(entities) do
              if entity.valid and entity.destructible and entity.is_entity_with_health then
                corrosion.engaging_fast(entity, t, true) -- apply corruption without check
              end
            end
          end
      end
      storage.creep.creep_queue[storage.creep.last_creep_id_counter] = nil
      storage.creep.last_creep_id_counter = storage.creep.last_creep_id_counter + 1
      ]]
    end
end

creeping.remote_interface = {
  set_creep_on_chunk_generated = function(value)
    if not storage.creep then
      return
    end
    if type(value) ~= "boolean" then
      error("Value for 'creep_on_chunk_generated' must be a boolean.")
    end
    storage.creep.on_chunk_generated = value
  end,
  set_creep_on_biter_base_built = function(value)
    if not storage.creep then
      return
    end
    if type(value) ~= "boolean" then
      error("Value for 'creep_on_biter_base_built' must be a boolean.")
    end
    storage.creep.on_biter_base_built = value
  end,
  spawn_creep_at_position = function(surface, position, override, building_name)
    if not storage.creep then
      return
    end
    if type(surface) ~= "table" or type(position) ~= "table" or not surface.valid then
      error("The surface or the position are invalid.")
    end
    -- The code here is duplicated from `generate_creep()` because that function is specifically optimized for multiple
    -- entities, while this function only needs to do it once.
    if not storage.creep.surfaces[surface.index] and not override then
      return
    end

    local rad
    local building_type
    local building_tier
    if building_name then
      local type_name
      type_name, building_tier = string.match(building_name, ".+%-(.+)%-v%d+%-t(%d+)%-rampant")
      -- faction.type.."-hive-v"..v.."-t"..factionSize.."-rampant"
      -- faction.type.."-spitter-spawner-v"..v.."-t"..factionSize.."-rampant"
      -- faction.type.."-biter-spawner-v"..v.."-t"..factionSize.."-rampant"
      -- faction.type.."-worm-v"..v.."-t"..factionSize.."-rampant", factionSize
      local buildings_tbl = {
        ["hive"] = 3,
        ["spitter-spawner"] = 2,
        ["biter-spawner"] = 2,
        ["spawner"] = 2,
        ["worm"] = 1
      }
      building_type = buildings_tbl[type_name]
      --local gg = building_tier or 0
      --local nname = type_name or "FUCKED"
      --local btype = building_type or 0
      --game.print("Creep for: ".. building_name .. " And name of type is: " .. nname .. " Tier is: " .. gg .. " Type #".. btype)
      rad = math.random(3, (constants.creep_max_range + building_type - 2)) + math.floor(building_type * building_tier * 0.5) + building_type - 2
    else
      rad = math.random(3, constants.creep_max_range - 2) + math.ceil(game.forces.enemy.get_evolution_factor(surface)*9)
    end

    storage.creep.creep_queue[storage.creep.creep_id_counter] = {
        radius = rad,
        position = position,
        stage = 0,
        surface = surface,
        fake = false,
        type = building_type,
        tier = building_tier
    }
    storage.creep.creep_id_counter = storage.creep.creep_id_counter + 1
  end,

  spawn_fake_creep_at_position_radius = function(surface, position, override, radius_ext)
    if not storage.creep then return end
    if type(surface) ~= "table" or type(position) ~= "table" or not surface.valid then
      error("The surface or the position are invalid.")
    end
    if not storage.creep.surfaces[surface.index] and not override then return end
    storage.creep.creep_queue[storage.creep.creep_id_counter] = {
      radius = radius_ext,
      position = position,
      stage = 0,
      surface = surface,
      fake = true
  }
  storage.creep.creep_id_counter = storage.creep.creep_id_counter + 1
  end,

  spawn_creep_tiles = function(surface, tiles, override)
    if not storage.creep then return end
    if not storage.creep.surfaces[surface.index] and not override then return end
    storage.creep.creep_queue[storage.creep.creep_id_counter] = {
      stage = 2,
      surface = surface,
      fake = true,
      creep_tiles = tiles
  }
  storage.creep.creep_id_counter = storage.creep.creep_id_counter + 1
  end
}

function creeping.check_strike (killed_e, killer_e, killer_force)
  if (killer_force and killer_force.name == "enemy") or (not killer_e) or (not killer_e.valid) or (killed_e.surface ~= killer_e.surface) then return end
  local ch = killed_e.type == "unit-spawner" and 4 or 8
  -- if ( killed_e.type == "unit-spawner" and ch < 5 ) or ch < 8 then return end
  -- local range_debug = math.sqrt( (killer_e.position.x - killed_e.position.x)^2 + (killer_e.position.y - killed_e.position.y)^2 )
  local range_ratio = ( math.sqrt( (killer_e.position.x - killed_e.position.x)^2 + (killer_e.position.y - killed_e.position.y)^2 ) ) / ( (game.forces.enemy.get_evolution_factor(killer_e.surface)*32) + constants.creep_max_range - 4)
  --game.print("Killed enemy structure distance is: " .. math.ceil(range_debug))
  if range_ratio < 2.05 then return end
  local revengers_raw = killed_e.surface.find_entities_filtered{ position = killed_e.position, radius = 70, type = "unit-spawner", force = "enemy", limit = 10 }
  local punisher
  local revengers = {}
  if revengers_raw and revengers_raw[1] then
    local k = 1
    for i=1, #revengers_raw do
      if revengers_raw[i].valid and not (revengers_raw[i].position.x == killed_e.position.x and revengers_raw[i].position.y == killed_e.position.y) then
        revengers[k] = revengers_raw[i]
        k = k + 1
      end
    end
  else return end -- no one left to revenge
  if revengers[1] and math.random(1,ch+#revengers) > ch then
    punisher = revengers[math.random(1,#revengers)]
  else
    --game.print("There is no one healthy left nearby to revenge!")
    return
  end
    local range = math.sqrt( (killer_e.position.x - punisher.position.x)^2 + (killer_e.position.y - punisher.position.y)^2 )
    range_ratio = range / ( (game.forces.enemy.get_evolution_factor(killer_e.surface)*32) + constants.creep_max_range + 1)

  local attack_area_radius = 2
  local attack_inaccuracy = 2
  if range_ratio > 8 then
    attack_area_radius = 5
    attack_inaccuracy = 7
  elseif range_ratio > 3 then
    attack_area_radius = 3
    attack_inaccuracy = 4
  end
  local rnd_x = math.random(1,attack_inaccuracy*2+1)-(attack_inaccuracy+1)
  local rnd_y = math.random(1,attack_inaccuracy*2+1)-(attack_inaccuracy+1)
  local attack_pos = {x = killer_e.position.x+rnd_x, y = killer_e.position.y+rnd_y}
  local doll = killed_e.surface.create_entity {name = "wm-revenge-doll", position = attack_pos, force = "neutral"}
  if not doll then
    game.print("We failed to create a revenge strike target!")
    return
  end
  local proj
  if attack_area_radius == 5 then
    proj = killed_e.surface.create_entity {
      name = "wm-revenge-projectile3",
      position = punisher.position,
      force = "enemy",
      target = doll,
      source = punisher,
      speed = 1,
      max_range = 5 + range
    }
    --game.print("sending big one..")
  elseif attack_area_radius == 3 then
    proj = killed_e.surface.create_entity {
      name = "wm-revenge-projectile2",
      position = punisher.position,
      force = "enemy",
      target = doll,
      source = punisher,
      speed = 2,
      max_range = 4 + range
    }
    --game.print("sending middle one..")
  else
    proj = killed_e.surface.create_entity {
      name = "wm-revenge-projectile1",
      position = punisher.position,
      force = "enemy",
      target = doll,
      source = punisher,
      speed = 2.5,
      max_range = 2 + range
    }
    --game.print("sending small one..")
  end
  if not proj then
    game.print("We failed to launch revenge strike shell!")
  end
  doll.destroy{}
end

function creeping.landed_strike(effect_id, surface, target_position, target)
  local attack_pos
  local attack_area_radius
  local attack_incomers

  if effect_id == "wm-strike-back-3" then
    attack_area_radius = 5
    attack_incomers = 3
  elseif effect_id == "wm-strike-back-2" then
    attack_area_radius = 2.9
    attack_incomers = 2
  elseif effect_id == "wm-strike-back-1" then
    attack_area_radius = 1.8
    attack_incomers = 1
  else return end
  attack_incomers = attack_incomers + (math.random(1,4)-3)
  if attack_incomers < 1 then attack_incomers = 1 end

  if target_position then attack_pos = target_position
  elseif target and target.position then attack_pos = target.position
  else
    game.print("We have lost target on revenge strike landing!")
    return
  end

  local somewhere
  local someone
  surface.play_sound{path = "creep-counter-attack-explosion", volume_modifier = 0.7, position = attack_pos}
  for i = 1, attack_incomers do
    somewhere = surface.find_non_colliding_position("small-biter", attack_pos, attack_area_radius+3, 0.05, false )
    if not somewhere then somewhere = attack_pos end
    someone = surface.create_entity{name = "small-biter", position = somewhere, force = "enemy", move_stuck_players = true}
  end
  local entities = surface.find_entities_filtered{ position = attack_pos, radius = attack_area_radius + 0.4,  force = "player" }
  local dmg_coeff = 1 + (math.random(1,31)-16)*0.02
  for _, entity in pairs(entities) do
    if entity.valid and entity.destructible and entity.is_entity_with_health then
      local hitpoints = entity.max_health
      if entity.prototype.type == "character" then
        hitpoints = hitpoints * (1 + entity.player.character_health_bonus) + 300
        -- hitpoints = hitpoints * (1 + entity.player.force.character_health_bonus)
      elseif entity.prototype.type == "spider-vehicle" then -- cheaters pay triple price
        --game.print("Aaah, I got you dirty cheater!")
        hitpoints = hitpoints * 5
      end
      local dmg = math.ceil( hitpoints * ( 0.1 + game.forces.enemy.get_evolution_factor(surface) / 5 ) ) -- big one time damage and can be lethal
      if hitpoints > 600 then
        dmg = dmg * 0.7 + math.ceil( 95 * ( 1 + 1.3 * game.forces.enemy.get_evolution_factor(surface) ) )
      elseif hitpoints > 150 then
        dmg = dmg * 0.7 + math.ceil( 40 * ( 1 + 1.2 * game.forces.enemy.get_evolution_factor(surface) ) )
      end
      dmg = dmg * dmg_coeff
      local recieved_dmg1 = entity.damage(dmg/2, "enemy", "poison")
      if entity.valid then
        local recieved_dmg2 = entity.damage(dmg/2, "enemy", "impact")
        --if entity.valid then
          --game.print("Natives strike back with lethal corrosion on your: " .. entity.name .. ". Damage received: " .. recieved_dmg1+recieved_dmg2)
        --end
      end
    end
  end

--  remote.call("kr-creep", "spawn_fake_creep_at_position_radius", surface, attack_pos, false, attack_area_radius-0.6)
  if storage.creep.surfaces[surface.index] then
    storage.creep.creep_queue[storage.creep.creep_id_counter] = {
      radius = attack_area_radius-0.6,
      position = attack_pos,
      stage = 0,
      surface = surface,
      fake = true
    }
    storage.creep.creep_id_counter = storage.creep.creep_id_counter + 1
  end
end

return creeping
