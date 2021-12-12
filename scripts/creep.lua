local table = require("__flib__.table")
local misc = require("__flib__.misc")
local area = require("__flib__.area")
local constants = require("scripts.constants")

local creep = {}

-- We can safely assume that all of the entities will be on the same surface
local function generate_creep(entities)
  -- Check if this surface is allowed to generate creep
  local surface = entities[1].surface
  if not global.creep.surfaces[surface.index] then
    return
  end

  local radius = math.random(4, constants.creep_max_range) + math.floor(game.forces.enemy.evolution_factor*10)
  local to_add = {}
  local i = 0
  for _, entity in pairs(entities) do
    for _, tile in pairs(surface.find_tiles_filtered({ position = entity.position, radius = radius })) do
      if not tile.collides_with("player-layer") then
        i = i + 1
        to_add[i] = { name = "kr-creep", position = tile.position }
      end
    end
  end
  surface.set_tiles(to_add)
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
  if entity.type == "unit-spawner" and global.creep.surfaces[entity.surface.index] then
    generate_creep({ entity })
  end
end

function creep.on_chunk_generated(chunk_area, surface)
  if (not global.creep.surfaces[surface.index]) or (settings.startup["rampant--newEnemies"] and settings.startup["rampant--newEnemies"].value) then
  --if (not global.creep.surfaces[surface.index]) then
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
          if creep_pack.fake then
            creep_pack.creep_tiles[i] = { name = "fk-creep", position = creep_pack.tiles[i].position }
          else
            local r = 1
            local d = misc.get_distance(creep_pack.tiles[i].position, creep_pack.position)
            if (d > 3) and ( (creep_pack.radius - d) <= 3) then r = math.random(1,5) end
            if r < 4 then
              creep_pack.creep_tiles[i] = { name = "kr-creep", position = creep_pack.tiles[i].position }
            elseif r == 4 then
              creep_pack.creep_tiles[i] = { name = "fk-creep", position = creep_pack.tiles[i].position }
            end
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
  end
}

return creep
