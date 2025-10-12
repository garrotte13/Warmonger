local bot_behavior = {}

local fuel_items
local bot_fuel_capacity = 48000
local bot_fuel_min = 22000

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
bot_behavior.bot_actions = {
    idle = 1,
    mining = 2,
    running = 3,
    search_field = 4,
    home = 5
}

function bot_behavior.search_zones(r)
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
        return bot_behavior.search_zones(r)
    end
end

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
       local count = math.min(math.ceil(bot_fuel_capacity / item.value), CharInv.get_item_count(item.name))
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
    gg_fuel_items()
    local f
    if fuel_name then
        for _, item in pairs (fuel_items) do
            if item.name == fuel_name then
                f = math.floor(fuel / item.value) - 1
                if f > 0 then return f end
                return
            end
        end
    end
end

function bot_behavior.consume_fuel_mining(r)
    local mbot = storage.wm_creep_miners[r]
    mbot.fuel = mbot.fuel - 800
    if mbot.fuel < 1 then
        game.print("Unit " .. r .. " overconsumed fuel by value of " .. -mbot.fuel)
    end
    game.get_player("garrotte").create_local_flying_text{text = "Fuel left: " .. mbot.fuel, position = mbot.entity.position, time_to_live = 100}
end

function bot_behavior.consume_fuel_basic(r, e_tick, Fuel_Coeff)
    local mbot = storage.wm_creep_miners[r]
    if not mbot.entity.active then return true end

    -- Defining constants
    local bot_fuel_consumption = 1
    if not Fuel_Coeff then
        Fuel_Coeff = mbot.entity.commandable.command.type
        if Fuel_Coeff == defines.command.wander then Fuel_Coeff = 3
         elseif Fuel_Coeff == defines.command.stop then Fuel_Coeff = 1
          elseif Fuel_Coeff == defines.command.go_to_location then Fuel_Coeff = 5
           else Fuel_Coeff = 0
        end
    end

    local ToConsume = 0
    
        ToConsume = (e_tick - mbot.t_activity) * Fuel_Coeff * bot_fuel_consumption    
        --ToConsume = (e_tick - mbot.t_activity) * bot_fuel_consumption    
    
    if ToConsume > 0 then
        mbot.fuel = mbot.fuel - ToConsume
        if mbot.fuel < 1 then
            game.print("Unit " .. r .. " overconsumed fuel by value of " .. -mbot.fuel)
        end
        mbot.t_activity = e_tick
        --game.get_player("garrotte").create_local_flying_text{text = "Fuel left: " .. mbot.fuel, position = mbot.entity.position, time_to_live = 100}
        if mbot.fuel < 5000 then
            mbot.entity.active = false
            if mbot.tileOid then
                storage.wm_creep_fields[math.floor((mbot.tile.x)/8) .. ":" .. math.floor((mbot.tile.y)/8)][mbot.tileOid].hunter = nil
            end
            mbot.tileOid = nil
            return false
        else
            return true
        end
    else
        return true
    end
end

return bot_behavior