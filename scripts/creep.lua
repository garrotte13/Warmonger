local table = require("__flib__.table")
local constants = require("scripts.constants")

local creep = {}

-- We can safely assume that all of the entities will be on the same surface
local function generate_creep(entities)
  -- Check if this surface is allowed to generate creep
  local surface = entities[1].surface
  if not global.creep.surfaces[surface.index] then
    return
  end

  local radius = math.random(3, constants.creep_max_range)
  local to_add = {}
  local i = 0
  for _, entity in pairs(entities) do
    ---@type LuaTile
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
    surfaces = { [game.get_surface("nauvis").index] = true },
  }
end

function creep.on_biter_base_built(entity)
  if entity.type == "unit-spawner" and global.creep.surfaces[entity.surface.index] then
    generate_creep({ entity })
  end
end

function creep.on_chunk_generated(chunk_area, surface)
  if not global.creep.surfaces[surface.index] then
    return
  end

  local entities = surface.find_entities_filtered({ type = { "unit-spawner" }, area = chunk_area, force = "enemy" })

  for _, entity in pairs(entities) do
    generate_creep({ entity })
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
    local radius = math.random(3, constants.creep_max_range)
    surface.set_tiles(table.map(surface.find_tiles_filtered({ position = position, radius = radius }), function(tile)
      if not global.creep then
        return
      end
      if not tile.collides_with("player-layer") then
        return { name = "kr-creep", position = tile.position }
      end
    end))
  end,
}

return creep
