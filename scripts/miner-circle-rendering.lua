local constants = require("scripts.constants")
local circle_rendering = {}

local function miner_cursor(player)
  local pcs = player.cursor_stack
  local pcg = player.cursor_ghost
  if pcs and pcs.valid_for_read and pcs.valid and (pcs.name:match("creep%-miner%d%-")) then
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
        game.print("Destroyed circle:".. id)
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
    local miner_range = constants.miner_range(miner.name)
    if player and miner_cursor(player) then
      id = rendering.draw_circle{color={r=0.5, g=0.2, b=0.5, a=0.25}, radius = miner_range, filled=true, target=miner, players={player}, surface = miner.surface, draw_on_ground=true, visible=true}
      game.print("Drawn visible circle:".. id)
    else
      id = rendering.draw_circle{color={r=0.5, g=0.2, b=0.5, a=0.25}, radius = miner_range, filled=true, target=miner, players={}, surface = miner.surface, visible=false, draw_on_ground=true}
      game.print("Drawn invisible circle:".. id)
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
    if rendering.is_valid(id) and rendering.get_type(id):match("circle") then
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
  local target
  local match
  local players
  for _, id in pairs(renders) do
    if rendering.is_valid(id) and rendering.get_type(id):match("circle") then
      target = rendering.get_target(id)
      if target.entity.force == player.force then
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
      end
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
  end

  local itemCount = inventory.get_item_count("creep-miner1-chest")
  if (itemCount > 0) then
      inventory.remove({name = "creep-miner1-chest", count = itemCount})
      inventory.insert({name = "creep-miner1-overlay", count = itemCount})
  end
  itemCount = inventory.get_item_count("creep-miner1-radar")
  if (itemCount > 0) then inventory.remove({name = "creep-miner1-radar", count = itemCount}) end
end

function circle_rendering.SwapItemStack(player)
  local stack
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
  local item = { name = dst, count = stack.count }
  if stack.can_set_stack(item) then
    stack.set_stack(item)
  end
end


return circle_rendering