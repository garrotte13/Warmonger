local util = require("scripts.util")
local corrosion = {}

function corrosion.init()
 global.corrosion = {
 enabled = settings.global["wm-CreepCorrosion"].value,
 strike_back = settings.global["wm-CounterStrike"].value,
 affected = {},
 affected_num = 0,
 creepminer_hints = settings.global["wm-CreepMinerHints"].value
 }
end

function corrosion.engaging (entity)
 if (not global.corrosion.enabled) or (not entity.destructible) or (not entity.is_entity_with_health)
  or entity.prototype.weight or entity.prototype.type == "logistic-robot" or entity.prototype.type == "construction-robot" or entity.prototype.type == "character"
   then return end
 local turret_area = util.box_ceiling(entity.selection_box)
 local surface = entity.surface
 -- game.print("Installed building of name: " .. entity.name .. " located at top left x:" .. turret_area.left_top.x .. " y:" .. turret_area.left_top.y .. ", bottom right x:" .. turret_area.right_bottom.x .. " y:" .. turret_area.right_bottom.y)
 local creep_amount = 0
 creep_amount = surface.count_tiles_filtered{
 area = turret_area,
 name = {"kr-creep", "fk-creep"}
 }
 -- game.print("How many creep tiles are under this building: " .. creep_amount)
 local second_area = entity.secondary_selection_box
 if second_area and ( creep_amount == 0 ) then
  second_area = util.box_ceiling(second_area)
  creep_amount = surface.count_tiles_filtered{
    area = second_area,
    name = {"kr-creep", "fk-creep"}
    }
 end
 if creep_amount > 0 then
  global.corrosion.affected[turret_area.left_top.x .. ":" .. turret_area.left_top.y] = entity
  global.corrosion.affected_num = global.corrosion.affected_num + 1
 end

end

function corrosion.engaging_fast (entity)
  if entity.prototype.weight or entity.prototype.type == "logistic-robot" or entity.prototype.type == "construction-robot" or entity.prototype.type == "character" then return end
  local e_area = util.box_ceiling(entity.selection_box)
  if not global.corrosion.affected[e_area.left_top.x .. ":" .. e_area.left_top.y] then
    global.corrosion.affected[e_area.left_top.x .. ":" .. e_area.left_top.y] = entity
    global.corrosion.affected_num = global.corrosion.affected_num + 1
  end
end

function corrosion.disengaging (entity)
 if (not global.corrosion.enabled) or (entity.force.name~="player") then return end
 local turret_area = util.box_ceiling(entity.selection_box)
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
  ["disable-corrosion-strikes"] = function()
    global.corrosion.strike_back = false
    game.print({ "message.corrosion-strikes-disabled" })
  end,
  ["enable-corrosion-strikes"] = function()
    global.corrosion.strike_back = true
    game.print({ "message.corrosion-strikes-enabled" })
  end,
  ["disable-creepminer-hints"] = function()
    global.corrosion.creepminer_hints = false
    game.print({ "message.creepminer-hints-disabled" })
  end,
  ["enable-creepminer-hints"] = function()
    global.corrosion.creepminer_hints = true
    game.print({ "message.creepminer-hints-enabled" })
  end,
}


function corrosion.affecting()
 if not global.corrosion.enabled then return end
 for _, entity in pairs(global.corrosion.affected) do
  if entity.valid then
    local surface = entity.surface
    local h_ratio = entity.get_health_ratio() / 2
    local rnd_coeff = (math.random() / 2) + 0.5
    local dmg = math.floor( rnd_coeff * entity.health * ( 0.05 + game.forces.enemy.evolution_factor/12 ) * ( 1 - h_ratio ) )
    -- at least 5 health will be left for biters/worms to finish
    local recieved_dmg = entity.damage(dmg, "enemy", "acid")
    if recieved_dmg > 0 then
      surface.play_sound{path = "acid_burns", position = entity.position}
    end
  end
 end
end


function corrosion.update_tiles(surface, tiles)
  if not global.corrosion.enabled then return end
  local i = 0
  for _, entity in pairs(global.corrosion.affected) do
    i = i + 1
    if entity.valid and entity.surface == surface then
      local obj_area = util.box_ceiling(entity.selection_box)
      local sec_area = entity.secondary_selection_box
      if sec_area then
        sec_area= util.box_ceiling(sec_area)
      end
      local touched = false
      for k=1,#tiles do
        if util.contains_point(obj_area, tiles[k].position, false) then
          touched = true
          break
        end
        if sec_area and ( util.contains_point(sec_area, tiles[k].position, false) ) then
          touched = true
          break
        end
      end
      if touched then
        local creep_amount = 0
        creep_amount = surface.count_tiles_filtered{
          area = obj_area,
          name = {"kr-creep", "fk-creep"}
        }
        if sec_area and ( creep_amount == 0 ) then
          creep_amount = surface.count_tiles_filtered{
            area = sec_area,
            name = {"kr-creep", "fk-creep"}
          }
        end
        if creep_amount == 0 then
          global.corrosion.affected[obj_area.left_top.x .. ":" .. obj_area.left_top.y] = nil
          global.corrosion.affected_num = global.corrosion.affected_num - 1
          -- game.print("Freed of creep object with name: " .. entity.name .. " located at top left x:" .. obj_area.left_top.x .. " y:" .. obj_area.left_top.y .. ", bottom right x:" .. obj_area.right_bottom.x .. " y:" .. obj_area.right_bottom.y)        
        end
      end
    end
 end
 -- game.print("Objects tortured left:" .. global.corrosion.affected_num)
 -- game.print("Objects tortured processed:" .. i)
end

function corrosion.update_surface(surface) -- OBSOLETE for obsolete creep_collector tool
  if not global.corrosion.enabled then return end
  local i = 0
  for _, entity in pairs(global.corrosion.affected) do
    i = i + 1
    if entity.valid and entity.surface == surface then
      local obj_area = util.box_ceiling(entity.selection_box)
      local creep_amount = 0
      creep_amount = surface.count_tiles_filtered{
        area = obj_area,
        name = {"kr-creep", "fk-creep"}
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