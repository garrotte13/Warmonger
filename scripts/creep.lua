local table = require("__flib__.table")
local misc = require("__flib__.misc")
local area = require("__flib__.area")
local constants = require("scripts.constants")
local corrosion = require("scripts.corrosion")

local creep = {}

-- We can safely assume that all of the entities will be on the same surface
local function generate_creep(entities)
  local surface = entities[1].surface
  if not global.creep.surfaces[surface.index] then
    return
  end
  for _, entity in pairs(entities) do
    global.creep.creep_queue[global.creep.creep_id_counter] = {
      radius = math.random(4, constants.creep_max_range) + math.floor(game.forces.enemy.evolution_factor*20),
      position = entity.position,
      stage = 0,
      surface = surface,
      fake = false
    }
    global.creep.creep_id_counter = global.creep.creep_id_counter + 1
  end
end

function creep.init()
  global.creep = {
    on_biter_base_built = true,
    on_chunk_generated = true,
    creep_id_counter = 0,
    last_creep_id_counter = 0,
    creep_queue = {},
    surfaces = { [game.get_surface("nauvis").index] = true },
  }
end

function creep.on_biter_base_built(entity)
  if settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value then return end
  if (entity.type == "unit-spawner" or entity.type == "turret") and global.creep.surfaces[entity.surface.index] then
    generate_creep({ entity })
  end
end

function creep.on_chunk_generated(chunk_area, surface)
  if (not global.creep.surfaces[surface.index]) or (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then
    return
  end
  local entities = surface.find_entities_filtered({ type = { "unit-spawner", "turret" }, area = chunk_area, force = "enemy" })
  for _, entity in pairs(entities) do
    if entity.valid then generate_creep({ entity }) end
  end
end

function creep.update()
    if not global.creep.creep_id_counter then
        global.creep.creep_id_counter = 1
    end
    if not global.creep.last_creep_id_counter then
        global.creep.last_creep_id_counter = 1
    end
    if not global.creep.creep_queue then
        global.creep.creep_queue = {}
    end
end

function creep.process_creep_queue()
    if global.creep.creep_id_counter == global.creep.last_creep_id_counter then
        return
    end

    local creep_pack = global.creep.creep_queue[global.creep.last_creep_id_counter]
    if creep_pack.stage == 0 then
        creep_pack.tiles = creep_pack.surface.find_tiles_filtered({
                position = creep_pack.position,
                radius = creep_pack.radius,
                collision_mask={"ground-tile"}
        })
        creep_pack.stage = 1
    elseif creep_pack.stage == 1 then
        creep_pack.creep_tiles = {}
        local n = 1
        local ne_coef = 2
        local ne_prob = 19
        if (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then
          ne_coef = 3.7
          ne_prob = 9.7
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
            r = 3
          else
            local d = misc.get_distance(creep_pack.tiles[i].position, creep_pack.position)
            if (d > 4) and ( (creep_pack.radius - d) < 4) then   -- no biomass on distal rings
              if math.random(1,10) > 6 then r = 4 else r = 3 end  -- 60% fake creep, 40% nothing
            elseif (d > (2 + math.floor(ne_coef * game.forces.enemy.evolution_factor)) ) then -- bigger and bigger 100% biomass core underneath growing New Enemies structures
              if math.random(1,(3 + math.ceil(ne_prob * game.forces.enemy.evolution_factor))) > 1 then r = 3 end -- less biomass with every ~9% or 6% evo increase
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
        if global.corrosion.enabled then
          creep_pack.stage = 3
        else
          global.creep.creep_queue[global.creep.last_creep_id_counter] = nil
          global.creep.last_creep_id_counter = global.creep.last_creep_id_counter + 1
        end
    elseif creep_pack.stage == 3 then
      if creep_pack.fake and creep_pack.position then
        for i=1, global.creep_miners_last do
          if global.creep_miners[i] and global.creep_miners[i].stage == 50
           and global.creep_miners[i].entity and global.creep_miners[i].entity.valid then
            local d = (constants.miner_range(global.creep_miners[i].entity.name) + creep_pack.radius)^2
            if ((global.creep_miners[i].x - creep_pack.position.x)^2 + (global.creep_miners[i].y - creep_pack.position.y)^2) <= d then
              global.creep_miners[i].entity.active = true
              global.creep_miners[i].stage = 0
            end
          end
        end
--        local entities = creep_pack.surface.find_entities_filtered{ position = creep_pack.position, radius = creep_pack.radius,  force = "player" }
--        for _, entity in pairs(entities) do
--          if entity.valid and entity.destructible and entity.is_entity_with_health then
--            corrosion.engaging_fast(entity)
--         end
--        end
      end
          for _, tile in pairs(creep_pack.creep_tiles) do
            local entities = creep_pack.surface.find_entities_filtered{
              area = {
                left_top = { x = tile.position.x, y = tile.position.y },
                right_bottom = { x = tile.position.x + 1, y = tile.position.y + 1 },
              },
              force = "player"}
            for _, entity in pairs(entities) do
              if entity.valid and entity.destructible and entity.is_entity_with_health then
                corrosion.engaging_fast(entity)
              end
            end
          end
      --end
      global.creep.creep_queue[global.creep.last_creep_id_counter] = nil
      global.creep.last_creep_id_counter = global.creep.last_creep_id_counter + 1
    end
end

creep.remote_interface = {
  set_creep_on_chunk_generated = function(value)
    if not global.creep then
      return
    end
    if type(value) ~= "boolean" then
      error("Value for 'creep_on_chunk_generated' must be a boolean.")
    end
    global.creep.on_chunk_generated = value
  end,
  set_creep_on_biter_base_built = function(value)
    if not global.creep then
      return
    end
    if type(value) ~= "boolean" then
      error("Value for 'creep_on_biter_base_built' must be a boolean.")
    end
    global.creep.on_biter_base_built = value
  end,
  spawn_creep_at_position = function(surface, position, override)
    if not global.creep then
      return
    end
    if type(surface) ~= "table" or type(position) ~= "table" or not surface.valid then
      error("The surface or the position are invalid.")
    end
    -- The code here is duplicated from `generate_creep()` because that function is specifically optimized for multiple
    -- if not global.creep then return end
    -- entities, while this function only needs to do it once.
    -- if not global.creep then return end
    if not global.creep.surfaces[surface.index] and not override then
      return
    end

    global.creep.creep_queue[global.creep.creep_id_counter] = {
        radius = math.random(3, constants.creep_max_range) + math.ceil(game.forces.enemy.evolution_factor*20),
        position = position,
        stage = 0,
        surface = surface,
        fake = false
    }
    global.creep.creep_id_counter = global.creep.creep_id_counter + 1
  end,

  spawn_fake_creep_at_position_radius = function(surface, position, override, radius_ext)
    if not global.creep then return end
    if type(surface) ~= "table" or type(position) ~= "table" or not surface.valid then
      error("The surface or the position are invalid.")
    end
    if not global.creep.surfaces[surface.index] and not override then return end
    global.creep.creep_queue[global.creep.creep_id_counter] = {
      radius = radius_ext,
      position = position,
      stage = 0,
      surface = surface,
      fake = true
  }
  global.creep.creep_id_counter = global.creep.creep_id_counter + 1
  end,

  spawn_creep_tiles = function(surface, tiles, override)
    if not global.creep then return end
    if not global.creep.surfaces[surface.index] and not override then return end
    global.creep.creep_queue[global.creep.creep_id_counter] = {
      stage = 2,
      surface = surface,
      fake = true,
      creep_tiles = tiles
  }
  global.creep.creep_id_counter = global.creep.creep_id_counter + 1
  end
}

function creep.check_strike (killed_e, killer_e, killer_force)
  if (killer_force and killer_force.name == "enemy") or (not killer_e) or (not killer_e.valid) or math.random(1,3) < 2 then return end
  -- local range_debug = math.sqrt( (killer_e.position.x - killed_e.position.x)^2 + (killer_e.position.y - killed_e.position.y)^2 )
  local range_ratio = ( math.sqrt( (killer_e.position.x - killed_e.position.x)^2 + (killer_e.position.y - killed_e.position.y)^2 ) ) / (math.ceil(game.forces.enemy.evolution_factor*20)+constants.creep_max_range+1)
  --game.print("Killed enemy structure distance is: " .. math.ceil(range_debug))
  if range_ratio < 1.86 then return end
  local revengers_raw = killed_e.surface.find_entities_filtered{ position = killed_e.position, radius = 64, type = "unit-spawner", force = "enemy" }
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
  else return end
  if revengers[1] then
    punisher = revengers[math.random(1,#revengers)]
  else
    --game.print("There is no one left nearby to revenge!")
    return
  end
    local range = math.sqrt( (killer_e.position.x - punisher.position.x)^2 + (killer_e.position.y - punisher.position.y)^2 )
    range_ratio = range / (math.ceil(game.forces.enemy.evolution_factor*20)+constants.creep_max_range+1)

  local attack_area_radius = 2
  local attack_inaccuracy = 2
  if range_ratio > 8.5 then
    attack_area_radius = 5
    attack_inaccuracy = 7
  elseif range_ratio > 3.6 then
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
      max_range = 5 + range
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

function creep.landed_strike(effect_id, surface, target_position, target)
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
    somewhere = surface.find_non_colliding_position("small-biter", attack_pos, attack_area_radius+2, 0.05, false )
    if somewhere then someone = surface.create_entity{name = "small-biter", position = somewhere, force = "enemy"} end
  end
  local entities = surface.find_entities_filtered{ position = attack_pos, radius = attack_area_radius + 0.6,  force = "player" }
  local dmg_coeff = 1 + (math.random(1,31)-16)*0.02
  for _, entity in pairs(entities) do
    if entity.valid and entity.destructible and entity.is_entity_with_health then
      local hitpoints = entity.prototype.max_health
      if entity.prototype.type == "character" then
        hitpoints = hitpoints * (1 + entity.player.character_health_bonus) + 300
        -- hitpoints = hitpoints * (1 + entity.player.force.character_health_bonus)
      end
      if entity.prototype.type == "spider-vehicle" then -- cheaters pay triple price
        hitpoints = hitpoints * 6
      end
      local dmg = math.ceil( hitpoints * ( 0.1 + game.forces.enemy.evolution_factor/5 ) ) -- big one time damage and can be lethal
      if hitpoints > 200 then
        dmg = dmg * 0.6 + math.ceil( 70 * ( 1 + 1.2 * game.forces.enemy.evolution_factor ) )
      elseif hitpoints > 100 then
        dmg = dmg * 0.8 + math.ceil( 30 * ( 1 + 1.2 * game.forces.enemy.evolution_factor ) )
      end
      dmg = dmg * dmg_coeff
      local recieved_dmg1 = entity.damage(dmg/3, "enemy", "acid")
      if entity.valid then
        local recieved_dmg2 = entity.damage((2*dmg)/3, "enemy", "impact")
        --if entity.valid then
          --game.print("Natives strike back with lethal corrosion on your: " .. entity.name .. ". Damage received: " .. recieved_dmg1+recieved_dmg2)
        --end
      end
    end
  end

  remote.call("kr-creep", "spawn_fake_creep_at_position_radius", surface, attack_pos, true, attack_area_radius + 0.6)
end

return creep
