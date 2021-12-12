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
      radius = math.random(4, constants.creep_max_range) + math.floor(game.forces.enemy.evolution_factor*10),
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
    generate_creep({ entity })
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
        for i=1,#creep_pack.tiles do
          local r = 1 -- by default it will be biomass creep
          local actual_tile = creep_pack.surface.get_tile(creep_pack.tiles[i].position) -- the starting point we could crash replace-path-abuse with new global array
          if actual_tile and (actual_tile.name == "fk-creep" or actual_tile.name == "kr-creep") then -- we mustn't re-write fate or double-check player's entities
            r = 4 -- skipping this tile
          elseif creep_pack.fake then
            r = 3 -- fake creep definitely
          else
            local d = misc.get_distance(creep_pack.tiles[i].position, creep_pack.position)
            if (d > 4) and ( (creep_pack.radius - d) <= 4) then r = math.random(2,4)  -- 33% chance for biomass on distal rings, 33% chance for skipping
            elseif (d > 2) and ( (creep_pack.radius - d) <= 6) then r = math.random(1,3) end -- 67% chance for biomass closer to center, 33% for fake creep
          end
            if r < 3 then
              creep_pack.creep_tiles[i] = { name = "kr-creep", position = creep_pack.tiles[i].position }
            elseif r == 3 then
              creep_pack.creep_tiles[i] = { name = "fk-creep", position = creep_pack.tiles[i].position }
            end
        end
        creep_pack.stage = 2
    elseif creep_pack.stage == 2 then
        creep_pack.surface.set_tiles(creep_pack.creep_tiles)
        creep_pack.stage = 3
    elseif creep_pack.stage == 3 then
      if global.corrosion.enabled then
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
        radius = math.random(3, constants.creep_max_range) + math.ceil(game.forces.enemy.evolution_factor*10),
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
