local bot_behavior = {}

local fuel_items
local bot_fuel_capacity = 48000
local bot_fuel_min = 22000
local bot_fuel_consumption = 1.15

bot_behavior.bot_actions = {
    idle = 1,
    mining = 2,
    running = 3,
    search_field = 4,
    home = 5,
    refueling = 6,
    depot = 7
}

local function getsign(dx)
    if dx < 0 then
        dx = -1
    elseif dx > 0 then
        dx = 1
    end
    return dx
end

local function v_in_table(v, t)
    for i = 1, #t do
        if t[i] == v then return true end
    end
end

function bot_behavior.search_zones_near(r)
    local mbot = storage.wm_creep_miners[r]
    local origin_pos = {
        x = math.floor((mbot.pos_found_tiles.x)/8),
        y = math.floor((mbot.pos_found_tiles.y)/8)
        }
    local our_field
    local diff_x = mbot.entity.position.x - (origin_pos.x*8 + 4)
    local diff_y = mbot.entity.position.y - (origin_pos.y*8 + 4)
    local autolist_offsets = {}
    local dx = getsign(diff_x)
    local dy = getsign(diff_y)
    if diff_x * diff_x > diff_y * diff_y then
        autolist_offsets = {
            {dx, 0},
            {dx, dy},
            {0, dy},
            {dx, -dy},
            {0, -dy},
            {-dx, dy},
            {-dx, 0},
            {-dx, -dy}
        }
    else
        autolist_offsets = {
            {0, dy},
            {dx, dy},
            {dx, 0},
            {-dx, dy},
            {-dx, 0},
            {dx, -dy},
            {0, -dy},
            {-dx, -dy}
        }
    end
    if diff_x * diff_x > 9 or diff_y * diff_y > 9 then
        table.insert(autolist_offsets, 4, {0,0})
    else
        table.insert(autolist_offsets, 1, {0,0})
    end
    local cur_pos
    for i = 1, 9 do
        cur_pos = {
            x = origin_pos.x + autolist_offsets[i][1],
            y = origin_pos.y + autolist_offsets[i][2]
        }
        our_field = storage.wm_cr_fields_meta[cur_pos.x .. ":" .. cur_pos.y]
        if not our_field then
            return cur_pos
        end
        -- ( ((1 + #our_field.bots)*4) <= our_field.size_now or (mbot.searching_field.final and #our_field.bots < our_field.size_now) )
        if our_field.size_now > 0 and (not v_in_table(r, our_field.bots)) then
            table.insert(our_field.bots, r)
            table.insert(mbot.field, cur_pos)
            mbot.activity = bot_behavior.bot_actions.idle
            return
        end
    end
    if mbot.searching_field.final then
        if mbot.activity == bot_behavior.bot_actions.search_field then
            mbot.activity = bot_behavior.bot_actions.home
        else
            mbot.searching_field.n = 9
        end
    else
        mbot.searching_field.final = true
    end
end
--[[
function bot_behavior.search_zones_legacy(r)
    local offsets_list = {
        {x = 0, y = 0},
        {x = 0, y = -1},
        {x = 1, y = -1},
        {x = 1, y = 0},
        {x = 1, y = 1},
        {x = 0, y = 1},
        {x = -1, y = 1},
        {x = -1, y = 0},
        {x = -1, y = -1}
    }
    local mbot = storage.wm_creep_miners[r]
    local n = mbot.searching_field.n
    local f_pos = {
        x = math.floor((mbot.pos_found_tiles.x)/8) + offsets_list[n].x,
        y = math.floor((mbot.pos_found_tiles.y)/8) + offsets_list[n].y
        }
    local our_field = storage.wm_cr_fields_meta[f_pos.x .. ":" .. f_pos.y]
    if not our_field then
        return f_pos
    end
    if our_field.size_now > 0 and (((1 + #our_field.bots)*4) <= our_field.size_now or
     (mbot.searching_field.final and #our_field.bots < our_field.size_now))
      then
        table.insert(our_field.bots, r)
        table.insert(mbot.field, f_pos)
        mbot.activity = bot_behavior.bot_actions.idle
        return
    else
        if mbot.searching_field.n < #offsets_list then
            mbot.searching_field.n = mbot.searching_field.n + 1
        elseif mbot.searching_field.final then
            mbot.searching_field = nil
            mbot.activity = bot_behavior.bot_actions.home
            return
        else
            mbot.searching_field.n = 1
            mbot.searching_field.final = true
        end
        return bot_behavior.search_zones_legacy(r)
    end
end
]]
local function gg_fuel_items()
    if not fuel_items then
        fuel_items = {}
        for _, item in pairs (prototypes.get_item_filtered{{ filter = 'fuel-value', comparison = '>', value = '1'}}) do
            if item.fuel_category == "chemical" then
                table.insert(fuel_items, {name = item.name, value = item.fuel_value * 0.0008})
            end
        end
        table.sort(fuel_items, function(a, b) return prototypes.item[a.name].stack_size > prototypes.item[b.name].stack_size end)
    end
end

function bot_behavior.fuel_reserve_by_char(playerN)
    if not playerN then return end
    local char1 = game.get_player(playerN).character
    if not char1 or not char1.valid then return end
    local CharInv = char1.get_main_inventory()
    if not CharInv and not CharInv.valid then return end
    if CharInv.get_item_count("wm-ochre") == 0 then
        game.get_player(playerN).create_local_flying_text{text = "Not enough ochre found in player's inventory", position = char1.position, time_to_live = 150}
        return
    end
    gg_fuel_items()
    for _, item in pairs (fuel_items) do
       local count = math.min(math.floor(bot_fuel_capacity / item.value), CharInv.get_item_count(item.name))
       if count >= math.ceil(bot_fuel_min / item.value) then
        return CharInv.remove({name = item.name, count = count}) * item.value ,
         CharInv.remove({name="wm-ochre", count = math.min(CharInv.get_item_count("wm-ochre"), 5)}) * 5 ,
          item.name
       end
    end
    game.get_player(playerN).create_local_flying_text{text = "Not enough fuel found in player's inventory", position = char1.position, time_to_live = 150}
end

function bot_behavior.extract_fuel(fuel, fuel_name)
    --{name = "coal", count = math.floor(mbot.fuel/3200) - 1})
    local f
    fuel = fuel - 50
    if fuel_name and fuel > 0 then
        gg_fuel_items()
        for _, item in pairs (fuel_items) do
            if item.name == fuel_name then
                f = math.floor(fuel / item.value)
                if f > 0 then return f end
                return
            end
        end
    else
        return
    end
end

function bot_behavior.consume_fuel_mining(r)
    local mbot = storage.wm_creep_miners[r]
    mbot.fuel = mbot.fuel - 900 * bot_fuel_consumption
    if mbot.fuel < 1 then
        game.print("Unit " .. r .. " overconsumed fuel by value of " .. -mbot.fuel)
    end
    --game.get_player("garrotte").create_local_flying_text{text = "Fuel left: " .. mbot.fuel, position = mbot.entity.position, time_to_live = 100}
end

function bot_behavior.consume_fuel_basic(r, e_tick, Fuel_Coeff)
    local mbot = storage.wm_creep_miners[r]
    if not mbot.entity.active then return false end
    if not Fuel_Coeff then
        if mbot.entity.commandable.command then
            Fuel_Coeff = mbot.entity.commandable.command.type
        else
            return true
        end
        if Fuel_Coeff == defines.command.wander then Fuel_Coeff = 3
         elseif Fuel_Coeff == defines.command.stop then Fuel_Coeff = 1
          elseif Fuel_Coeff == defines.command.go_to_location then Fuel_Coeff = 5
           else Fuel_Coeff = 3
        end
    end
    local ToConsume = 0
    ToConsume = (e_tick - mbot.t_activity) * Fuel_Coeff * bot_fuel_consumption    
    if ToConsume > 0 then
        mbot.fuel = mbot.fuel - ToConsume
        mbot.entity.surface.pollute(mbot.entity.position, ToConsume/1800, mbot.entity.name)
        if mbot.fuel < 1 then
            game.print("Unit " .. r .. " overconsumed fuel by value of " .. -mbot.fuel)
        end
        mbot.t_activity = e_tick
        --game.get_player("garrotte").create_local_flying_text{text = "Fuel left: " .. mbot.fuel, position = mbot.entity.position, time_to_live = 100}
        if mbot.fuel < 2200 then
            mbot.entity.active = false
            if mbot.tileOid then
                storage.wm_creep_fields[math.floor((mbot.tile.x)/8) .. ":" .. math.floor((mbot.tile.y)/8)][mbot.tileOid].hunter = nil
            end
            mbot.tileOid = nil
            mbot.activity = bot_behavior.bot_actions.refueling
            return false
        else
            return true
        end
    else
        return true
    end
end

return bot_behavior