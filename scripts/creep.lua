local table = require("__flib__.table")
local misc = require("__flib__.misc")
local area = require("__flib__.area")
local constants = require("scripts.constants")

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
  if (entity.type == "unit-spawner" or entity.type == "unit-spawner" == "turret") and global.creep.surfaces[entity.surface.index] then
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
          ne_coef = 5.1
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
              if math.random(1,(4 + math.ceil(ne_prob * game.forces.enemy.evolution_factor))) > 1 then r = 3 end -- less biomass with every ~9% or 6% evo increase
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
        creep_pack.stage = 3
    elseif creep_pack.stage == 3 then
      if global.corrosion.enabled then
        if creep_pack.fake and creep_pack.position then
          local entities = creep_pack.surface.find_entities_filtered{ position = creep_pack.position, radius = creep_pack.radius,  force = "player" }
          for _, entity in pairs(entities) do
            if entity.valid and entity.destructible and entity.is_entity_with_health then
              local turret_area = entity.selection_box
              area.ceil(turret_area)
              local hitpoints = entity.max_health -- Need to add health_bonus for player here
              local dmg = math.ceil( hitpoints * ( 0.1 + game.forces.enemy.evolution_factor/4 ) ) -- bigger one time damage and can be lethal
              local recieved_dmg = entity.damage(dmg, "enemy", "acid")
              game.print("Natives strike back with lethal corrosion on your: " .. entity.name .. ". Damage received: " .. recieved_dmg)
              -- add check for remaining health here !
              if not global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] then
                global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = entity
                global.corrosion.affected_num = global.corrosion.affected_num + 1
              end
            end
          end
        else
        for _, tile in pairs(creep_pack.creep_tiles) do
          local entities = creep_pack.surface.find_entities_filtered{ position = tile.position, force = "player" }
          for _, entity in pairs(entities) do
            if entity.valid and entity.destructible and entity.is_entity_with_health then
              local turret_area = entity.selection_box
              area.ceil(turret_area)
              if not global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] then
                global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = entity
                global.corrosion.affected_num = global.corrosion.affected_num + 1
              end
            end
          end
        end
      end
    end
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

return creep
