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
 if (not global.corrosion.enabled) or (not entity.destructible) then return end
 local turret_area = entity.selection_box
 area.ceil(turret_area)
 local surface = entity.surface
 game.print("Installed turret of name: " .. entity.name .. " located at top left x:" .. turret_area.left_top.x .. " y:" .. turret_area.left_top.y .. ", bottom right x:" .. turret_area.right_bottom.x .. " y:" .. turret_area.right_bottom.y)
 local creep_amount = 0
 creep_amount = surface.count_tiles_filtered{
 area = turret_area,
 name = "kr-creep", 
 }
 game.print("How many creep tiles are under this turret: " .. creep_amount)
 if creep_amount > 0 then
  global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = entity
  global.corrosion.affected_num = global.corrosion.affected_num + 1
 end

end

function corrosion.disengaging (entity)
 if not global.corrosion.enabled then return end
 local turret_area = entity.selection_box
 area.ceil(turret_area)
 game.print("Disappeared turret of name: " .. entity.name .. " located at top left x:" .. turret_area.left_top.x .. " y:" .. turret_area.left_top.y)
 if global.corrosion.affected then
  global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = nil
  global.corrosion.affected_num = global.corrosion.affected_num - 1
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
   dmg = math.floor( entity.health * ( 0.1 + game.forces.enemy.evolution_factor/10 ) )  -- at least 5 health will be left for biters/worms to finish
   recieved_dmg = entity.damage(dmg, "enemy", "acid")
  end
 end
end
return corrosion