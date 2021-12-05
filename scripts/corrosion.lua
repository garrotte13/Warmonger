local math = require("__flib__.math")
local util = require("scripts.util")
local area = require("__flib__.area")
local corrosion = {}

function corrosion.init()
 global.corrosion = {
 enabled = true,
 affected = {},
 affected_num = 0
 }
end

function corrosion.engaging (entity)
 if (not global.corrosion.enabled) or (not entity.destructible) or (not entity.is_entity_with_health) then return end
 local turret_area = entity.selection_box
 area.ceil(turret_area)
 local surface = entity.surface
 -- game.print("Installed building of name: " .. entity.name .. " located at top left x:" .. turret_area.left_top.x .. " y:" .. turret_area.left_top.y .. ", bottom right x:" .. turret_area.right_bottom.x .. " y:" .. turret_area.right_bottom.y)
 local creep_amount = 0
 creep_amount = surface.count_tiles_filtered{
 area = turret_area,
 name = "kr-creep"
 }
 -- game.print("How many creep tiles are under this building: " .. creep_amount)
 if creep_amount > 0 then
  global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = entity
  global.corrosion.affected_num = global.corrosion.affected_num + 1
 end

end

function corrosion.disengaging (entity)
 if (not global.corrosion.enabled) or (entity.force.name~="player") then return end
 local turret_area = entity.selection_box
 area.ceil(turret_area)
 -- game.print("Disappeared object of name: " .. entity.name)

  if global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] then
    global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = nil
    global.corrosion.affected_num = global.corrosion.affected_num - 1
    -- game.print("Creep was underneath. Objects tortured left:" .. global.corrosion.affected_num)
  end
end

corrosion.commands = {
  ["disable-corrosion"] = function()
    global.corrosion.enabled = false
    game.print({ "message.corrosion-disabled" })
  end,
  ["enable-corrosion"] = function()
    global.corrosion.enabled = true
    game.print({ "message.corrosion-enabled" })
  end,
}


function corrosion.affecting()
 if not global.corrosion.enabled then return end
 for _, entity in pairs(global.corrosion.affected) do
  if entity.valid then
  local dmg = math.floor( entity.health * ( 0.1 + game.forces.enemy.evolution_factor/10 ) )  -- at least 5 health will be left for biters/worms to finish
  local recieved_dmg = entity.damage(dmg, "enemy", "acid")
  end
 end
end

function corrosion.update_tiles(surface)
  if not global.corrosion.enabled then return end
  local i = 0
  for _, entity in pairs(global.corrosion.affected) do
    i = i + 1
    if entity.valid then
      local obj_area = entity.selection_box
      area.ceil(obj_area)
      local creep_amount = 0
      creep_amount = surface.count_tiles_filtered{
        area = obj_area,
        name = "kr-creep"
      }
      if creep_amount == 0 then
        global.corrosion.affected[obj_area.left_top.x .. ":" .. obj_area.left_top.y] = nil
        global.corrosion.affected_num = global.corrosion.affected_num - 1
        -- game.print("Freed of creep object with name: " .. entity.name .. " located at top left x:" .. obj_area.left_top.x .. " y:" .. obj_area.left_top.y .. ", bottom right x:" .. obj_area.right_bottom.x .. " y:" .. obj_area.right_bottom.y)        
      end
    end
 end
 -- game.print("Objects tortured left:" .. global.corrosion.affected_num)
 -- game.print("Objects tortured processed:" .. i)
end

return corrosion