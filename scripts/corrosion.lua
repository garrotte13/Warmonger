local util = require("scripts.util")
local corrosionF = {}

function corrosionF.init()
  if not storage.corrosion then
    storage.corrosion = {
    --enabled = settings.global["wm-CreepCorrosion"].value,
    affected = {},
    affected_num = 0,
    --creepminer_hints = settings.global["wm-CreepMinerHints"].value
 }
  end
end

function corrosionF.engaging (entity, t)
 if (not entity.destructible) or (not entity.is_entity_with_health) or entity.prototype.type == "unit" 
  or entity.prototype.weight or entity.prototype.type == "logistic-robot" or entity.prototype.type == "construction-robot" or entity.prototype.type == "character"
   then return end
 local e_area = util.box_ceiling(entity.selection_box)
 local surface = entity.surface
 -- game.print("Installed building of name: " .. entity.name .. " located at top left x:" .. e_area.left_top.x .. " y:" .. e_area.left_top.y .. ", bottom right x:" .. e_area.right_bottom.x .. " y:" .. e_area.right_bottom.y)
 local creep_amount = 0
 creep_amount = surface.count_tiles_filtered{
 area = e_area,
 limit = 1,
 name = {"kr-creep", "fk-creep"}
 }
 -- game.print("How many creep tiles are under this building: " .. creep_amount)
 local second_area = entity.secondary_selection_box
 if second_area and ( creep_amount == 0 ) then
  second_area = util.box_ceiling(second_area)
  creep_amount = surface.count_tiles_filtered{
    area = second_area,
    limit = 1,
    name = {"kr-creep", "fk-creep"}
    }
 end
 if creep_amount > 0 then
  t = t + 12 + math.random(1,15)
  storage.corrosion.affected[e_area.left_top.x .. ":" .. e_area.left_top.y] = {e = entity, next_tick = t, no_check = true}
  storage.corrosion.affected_num = storage.corrosion.affected_num + 1
  if storage.dissention[t] then
    if storage.dissention[t].corrosion_affected then
      table.insert(storage.dissention[t].corrosion_affected, {x = e_area.left_top.x, y = e_area.left_top.y})
    else
      storage.dissention[t].corrosion_affected = {{x = e_area.left_top.x, y = e_area.left_top.y}}
    end
  else
    storage.dissention[t] = { corrosion_affected = {{x = e_area.left_top.x, y = e_area.left_top.y}} }
  end
 end

end

-- no_check = false MEANS that building must be checked for tile collision at next corruption event !!

function corrosionF.engaging_fast (entity, t, please_no_check)
  if entity.prototype.weight or entity.prototype.type == "logistic-robot" or entity.prototype.type == "construction-robot"
   or entity.prototype.type == "character" or entity.prototype.type == "unit"  then return end
  local e_area = util.box_ceiling(entity.selection_box)
  t = t + 14 + math.random(1,20)
  if not storage.corrosion.affected[e_area.left_top.x .. ":" .. e_area.left_top.y] then
    storage.corrosion.affected[e_area.left_top.x .. ":" .. e_area.left_top.y] = {e = entity, next_tick = t, no_check = please_no_check}
    storage.corrosion.affected_num = storage.corrosion.affected_num + 1
  if storage.dissention[t] then
    if storage.dissention[t].corrosion_affected then
      table.insert(storage.dissention[t].corrosion_affected, {x = e_area.left_top.x, y = e_area.left_top.y})
    else
      storage.dissention[t].corrosion_affected = {{x = e_area.left_top.x, y = e_area.left_top.y}}
    end
  else
    storage.dissention[t] = { corrosion_affected = {{x = e_area.left_top.x, y = e_area.left_top.y}} }
  end
  end
  

end

local function disengage_it (posX, posY)
  if storage.corrosion.affected[posX .. ":" .. posY] then
    local t = storage.corrosion.affected[posX .. ":" .. posY].next_tick
    local to_keep = {}
    local i = 0
    if t and t > 0 and storage.dissention[t] then
      for _, pos in pairs(storage.dissention[t].corrosion_affected) do
        if pos.x ~= posX or posY ~= pos.y then
          table.insert(to_keep, pos)
        else i = i + 1
        end
      end
    end
    if i > 0 then storage.dissention[t].corrosion_affected = to_keep else game.print("Shit happened!") end
    storage.corrosion.affected[posX .. ":" .. posY] = nil
    storage.corrosion.affected_num = storage.corrosion.affected_num - 1
    -- game.print("Creep was underneath. Objects tortured left:" .. storage.corrosion.affected_num)
  end
end
  

function corrosionF.disengaging (entity)
 if (entity.force.name~="player") then return end
 local turret_area = util.box_ceiling(entity.selection_box)
 -- game.print("Disappeared object of name: " .. entity.name)
 disengage_it (turret_area.left_top.x, turret_area.left_top.y)
end

--[[
corrosionF.commands = {
  ["disable-corrosion"] = function()
    storage.corrosion.enabled = false
    game.print({ "message.corrosion-disabled" })
  end,
  ["enable-corrosion"] = function()
    storage.corrosion.enabled = true
    game.print({ "message.corrosion-enabled" })
  end,
  ["disable-corrosion-strikes"] = function()
    storage.corrosion.strike_back = false
    game.print({ "message.corrosion-strikes-disabled" })
  end,
  ["enable-corrosion-strikes"] = function()
    storage.corrosion.strike_back = true
    game.print({ "message.corrosion-strikes-enabled" })
  end,
  ["disable-creepminer-hints"] = function()
    storage.corrosion.creepminer_hints = false
    game.print({ "message.creepminer-hints-disabled" })
  end,
  ["enable-creepminer-hints"] = function()
    storage.corrosion.creepminer_hints = true
    game.print({ "message.creepminer-hints-enabled" })
  end,
}
]]

function corrosionF.affect(entity)
     local surface = entity.surface
     local h_ratio = entity.get_health_ratio() / 2
     local rnd_coeff = (math.random() / 4) + 0.25
     local dmg = math.floor( rnd_coeff * entity.health * ( 0.09 + game.forces.enemy.get_evolution_factor(surface)/8 ) * ( 1 - h_ratio ) )
     -- at least 5 health will be left for biters/worms to finish
     local recieved_dmg = entity.damage(dmg, "enemy", "acid")
     if recieved_dmg > 0 then
       surface.play_sound{path = "acid_burns", position = entity.position}
     end
 end

function corrosionF.update_tiles(surface, tiles)
  --if not storage.corrosion.enabled then return end
  --local i = 0
  --local j = 0
  local entity
  for _, aff in pairs(storage.corrosion.affected) do
    --i = i + 1
    entity = aff.e
    if entity and entity.valid and entity.surface == surface then
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
        elseif sec_area and ( util.contains_point(sec_area, tiles[k].position, false) ) then
          touched = true
          break
        end
      end
      if touched then
        aff.no_check = false
        --j = j + 1
        --[[
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
          disengage_it (obj_area.left_top.x, obj_area.left_top.y)
          -- game.print("Freed of creep object with name: " .. entity.name .. " located at top left x:" .. obj_area.left_top.x .. " y:" .. obj_area.left_top.y .. ", bottom right x:" .. obj_area.right_bottom.x .. " y:" .. obj_area.right_bottom.y)
        end
        ]]
      end
    end
 end
 --if j > 0 then game.print("Miner sends ".. j .. "/" .. i .. " entities for check.") end
 -- game.print("Objects tortured left:" .. storage.corrosion.affected_num)
 -- game.print("Objects tortured processed:" .. i)
end

function corrosionF.is_still_affected(entity)
  local obj_area = util.box_ceiling(entity.selection_box)
  local sec_area = entity.secondary_selection_box
  if sec_area then
    sec_area= util.box_ceiling(sec_area)
  end
  local creep_amount = 0
  creep_amount = entity.surface.count_tiles_filtered{
    area = obj_area,
    limit = 1,
    name = {"kr-creep", "fk-creep"}
  }
  if sec_area and ( creep_amount == 0 ) then
    creep_amount = entity.surface.count_tiles_filtered{
      area = sec_area,
      limit = 1,
      name = {"kr-creep", "fk-creep"}
    }
  end
  --game.print("Checking entity: ".. entity.name .. " located at top left x:" .. obj_area.left_top.x .. " y:" .. obj_area.left_top.y)
  if creep_amount == 0 then
    return false
    --disengage_it (obj_area.left_top.x, obj_area.left_top.y)
    -- game.print("Freed of creep object with name: " .. entity.name .. " located at top left x:" .. obj_area.left_top.x .. " y:" .. obj_area.left_top.y .. ", bottom right x:" .. obj_area.right_bottom.x .. " y:" .. obj_area.right_bottom.y)
  else
    return true
  end
end

return corrosionF