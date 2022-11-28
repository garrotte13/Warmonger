local constants = require("scripts.constants")
local circle_rendering = {}

local function miner_cursor(player)
  local pcs = player.cursor_stack
  local pcg = player.cursor_ghost
  if pcs and pcs.valid_for_read and pcs.valid and (pcs.name:match("creep%-miner%d%-") or pcs.name == "kr-creep-collector") then
  --if pcs and pcs.valid_for_read and pcs.valid and (pcs.name=="creep-miner0-radar" or pcs.name=="creep-miner0-overlay" or pcs.name=="creep-miner0-chest") then
    return true
  elseif pcg and pcg.valid and (pcg.name:match("creep%-miner%d%-") ) then
  --elseif pcg and pcg.valid and (pcg.name=="creep-miner0-radar" or pcg.name=="creep-miner0-overlay" or pcg.name=="creep-miner0-chest") then
    return true
  end
end

local function match_players(players, player, remove)
  if not players then return false, {} end
  for k, v in pairs(players) do
    if v == player then
      if remove then table.remove(players, k) end
      return true, players
    end
  end
  return false, players
end

function circle_rendering.remove_circle(miner)
  if not miner or not miner.valid then return end
  local renders = rendering.get_all_ids("Warmonger")
  local target
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and rendering.get_type(id):match("circle") then
      target = rendering.get_target(id)
      if target.entity == miner then
        --game.print("Destroyed circle:".. id)
        rendering.destroy(id)
        return
      end
    end
  end
end

function circle_rendering.hide_circle(miner, player)
  if not miner or not miner.valid then return end
  local renders = rendering.get_all_ids("Warmonger")
  local target
  local match
  local players
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and rendering.get_type(id):match("circle") then
      target = rendering.get_target(id)
      if target.entity == miner then
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, true)
          if match then
            rendering.set_players(id, players)
          end
          if #players == 0 then
            rendering.set_visible(id, false)
          end
        end
      end
    end
  end
end

function circle_rendering.add_circle(miner, player)
  if not miner or not miner.valid then return end
  local renders = rendering.get_all_ids("Warmonger")
  local target
  local found = false
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and rendering.get_type(id):match("circle") then
      target = rendering.get_target(id)
      if target.entity == miner then
        found = true
      end
    end
  end
  if not found then
    local id
    local miner_range
    if miner.name == "entity-ghost" then miner_range = constants.miner_range(miner.ghost_name) + 0.6 else miner_range = constants.miner_range(miner.name) + 0.6 end
    if player and miner_cursor(player) then
      id = rendering.draw_circle{color={r=0.05, g=0.10, b=0.10, a=0.05}, radius = miner_range, filled=true, target=miner, players={player}, surface = miner.surface, draw_on_ground=true, visible=true}
      --game.print("Drawn visible circle:".. id)
    else
      id = rendering.draw_circle{color={r=0.05, g=0.10, b=0.10, a=0.05}, radius = miner_range, filled=true, target=miner, players={}, surface = miner.surface, visible=false, draw_on_ground=true}
      --game.print("Drawn invisible circle:".. id)
    end

  end
end

function circle_rendering.show_circle(miner, player)
  if not miner or not miner.valid then return end
  local renders = rendering.get_all_ids("Warmonger")
  local target
  local found = false
  local match
  local players
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and rendering.get_type(id):match("circle") then
      target = rendering.get_target(id)
      if target.entity == miner then
        found = true
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, false)
          players = rendering.get_players(id)
          if not match then
            table.insert(players, player)
            rendering.set_players(id, players)
          end
        else
          rendering.set_players(id, {player})
          rendering.set_visible(id, true)
        end
      end
    end
  end
  if not found then
    circle_rendering.add_circle(miner, player)
  end
end

function circle_rendering.hide_all_circles(player)
  local renders = rendering.get_all_ids("Warmonger")
  local match
  local players
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and ( rendering.get_type(id):match("circle") or rendering.get_forces(id)[1] == player.force ) then
      if rendering.get_visible(id) then
        match, players = match_players(rendering.get_players(id), player, true)
        if match then
          rendering.set_players(id, players)
        end
        if #players == 0 then
          rendering.set_visible(id, false)
        end
      end
    end
  end
end

function circle_rendering.show_all_circles(player)
  local renders = rendering.get_all_ids("Warmonger")
--  local target
  local match
  local players
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and ( ( rendering.get_type(id):match("circle") and rendering.get_target(id).entity.force == player.force )
     or rendering.get_forces(id)[1] == player.force ) then
--      target = rendering.get_target(id)
--      if target.entity.force == player.force then
        if rendering.get_visible(id) then
          match, players = match_players(rendering.get_players(id), player, false)
          players = rendering.get_players(id)
          if match then
          else
            table.insert(players, player)
            rendering.set_players(id, players)
          end
        else
          rendering.set_players(id, {player})
          rendering.set_visible(id, true)
        end
--      end
    end
  end
end

function circle_rendering.selection_changed(player)
  local selection = player.selected
  if selection and selection.valid and (selection.name:match("creep%-miner%d%-radar") or selection.name:match("creep%-miner%d%-overlay")) then
    circle_rendering.add_circle(selection, player)
  end
end

function circle_rendering.cursor_changed(player)
  if miner_cursor(player) then
    circle_rendering.show_all_circles(player)
  else
    circle_rendering.hide_all_circles(player)
  end
end


function circle_rendering.SwapInventory(player)
  local inventory = player.get_main_inventory()
  if inventory and inventory.valid then

    local itemCount = inventory.get_item_count("creep-miner0-chest")
    if (itemCount > 0) then
        inventory.remove({name = "creep-miner0-chest", count = itemCount})
        inventory.insert({name = "creep-miner0-overlay", count = itemCount})
    end
    itemCount = inventory.get_item_count("creep-miner0-radar")
    if (itemCount > 0) then inventory.remove({name = "creep-miner0-radar", count = itemCount}) end

    itemCount = inventory.get_item_count("creep-miner1-chest")
    if (itemCount > 0) then
      inventory.remove({name = "creep-miner1-chest", count = itemCount})
      inventory.insert({name = "creep-miner1-overlay", count = itemCount})
    end
    itemCount = inventory.get_item_count("creep-miner1-radar")
    if (itemCount > 0) then inventory.remove({name = "creep-miner1-radar", count = itemCount}) end
  end
end

function circle_rendering.SwapItemStack(player)
  local stack
  local inv = player.get_main_inventory()
  if player and player.valid then
    stack = player.cursor_stack
  else return end

  local dst
  if stack and stack.valid and stack.valid_for_read then
    if (stack.name == "creep-miner0-radar") then dst = "creep-miner0-overlay"
    elseif (stack.name == "creep-miner0-chest") then dst = "creep-miner0-overlay"
    elseif (stack.name == "creep-miner1-radar") then dst = "creep-miner1-overlay"
    elseif (stack.name == "creep-miner1-chest") then dst = "creep-miner1-overlay"
    else return end
  else return end
  local itemCount = inv.get_item_count(dst)
  if itemCount == 0 then itemCount = stack.prototype.stack_size end
  local item = { name = dst, count = itemCount }
  local DelCount =  math.min(itemCount, stack.prototype.stack_size)
  inv.remove({name = dst, count = DelCount})
  if stack.can_set_stack(item) then
    stack.set_stack(item)
  end
  

end
-- {r=0.35, g=0.35, b=0.0, a=0.05}
function circle_rendering.add_prio_rect(area, player, surface)
  local id
  if player and miner_cursor(player) then
    id = rendering.draw_rectangle{color = player.color, left_top = area.left_top, right_bottom = area.right_bottom, filled=true, players={player}, forces = {player.force}, surface = surface, draw_on_ground=true, visible=true}
    --game.print("Drawn visible rect:".. id)
  else
    id = rendering.draw_rectangle{color = player.color, left_top = area.left_top, right_bottom = area.right_bottom, filled=true, players={}, forces = {player.force}, surface = surface, visible=false, draw_on_ground=true}
    --game.print("Drawn invisible rect:".. id)
  end
end

function circle_rendering.del_prio_rect(area, player)

  local renders = rendering.get_all_ids("Warmonger")
  local pos
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and rendering.get_type(id):match("rectangle") then
      pos = rendering.get_left_top(id)
      if pos and pos.position and rendering.get_forces(id)[1] == player.force and pos.position.x == area.left_top.x and pos.position.y == area.left_top.y then
        --game.print("Destroyed circle:".. id)
        rendering.destroy(id)
        return
      end
    end
  end
end

return circle_rendering