local mining_bots = {}
local fields_func = require("fields_logic")
local bot_func = require("bot_logic")

local bot_actions = {
    idle = 1,
    mining = 2,
    running = 3,
    search_field = 4,
    home = 5
}


local function find_free_tick(e_tick)
    local action_ticks = storage.dissention
    while action_ticks[e_tick] and action_ticks[e_tick].bot do e_tick = e_tick + 1 end
    if not action_ticks[e_tick] then
        action_ticks[e_tick] = {bot = 0, tree = nil}
    end
return e_tick
end

function mining_bots.add(entity, playerN, e_tick)
    local r = entity.unit_number
    local mbots = storage.wm_creep_miners
    local action_ticks = storage.dissention
    --game.print("Registering bot with a unit number: " .. r)
    local fuel
    local ochre
    local fuel_item
    fuel, ochre, fuel_item = bot_func.fuel_reserve_by_char(playerN)
    if not fuel then
        entity.active = false
        return
    end

    local next_t = find_free_tick(e_tick + 60) -- give the newborn a second to look around
    mbots[r] = {
        tile = nil, -- the target creep tile pos selected by bot
        entity = entity,
        fuel = fuel, -- 12x4MJ 12 units of coal or 4 units of solid fuel. 80% efficiency means 15 coal or 5 solid is needed.
        fuel_name = fuel_item,
        ochre = ochre, -- 5 units, where every 2 units are made of 2 iron and 3 stone + water
        bio1 = 0,
        bio2 = 0,
        tileOid = nil,
        pos_found_tiles = entity.position, -- original position for search of new/existing tiles fields
        field = {}, -- table of fields the bot is processing
        searching_field = nil, -- a pos of the field bot checked for creep last time
        activity = bot_actions.search_field,        
        t_activity = e_tick,
        next_tick = next_t
    }
    action_ticks[next_t].bot = r
    entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
    storage.wm_creep_miners_count = storage.wm_creep_miners_count + 1
end

function mining_bots.remove(r, entity, tempInv, e_tick)
    local action_ticks = storage.dissention
    if not r then r = entity.unit_number end
    local mbot = storage.wm_creep_miners[r]
    if mbot then
        if mbot.next_tick and mbot.next_tick >= e_tick then action_ticks[mbot.next_tick].bot = nil end
        fields_func.unlock_tiles(r)
        fields_func.unlink_fields(r)
        if tempInv and tempInv.valid then
            bot_func.consume_fuel_basic(r, e_tick)
            if mbot.bio1 > 0 then
                tempInv.insert({name = "biomass", count = mbot.bio1})
            end
            if mbot.bio2 > 0 then
                tempInv.insert({name = "wm-bio-remains", count = mbot.bio2})
            end
            if mbot.ochre > 4 then
                tempInv.insert({name = "wm-ochre", count = math.floor(mbot.ochre/5)})
            end
            local f = bot_func.extract_fuel(mbot.fuel, mbot.fuel_name)
            if f then
                tempInv.insert({name = mbot.fuel_name, count = f})
            end
        end
        storage.wm_creep_miners[r] = nil
        storage.wm_creep_miners_count = storage.wm_creep_miners_count - 1
    else
        game.print("Bot with this unit number " .. r .. " is not found in registered list!")
        game.print("Total number of register bots = " .. storage.wm_creep_miners_count)
    end
end

function mining_bots.process(r, e_tick)
    local action_ticks = storage.dissention
    if not storage.wm_creep_miners[r] then
        game.print("Asked to process not registered bot with the number = " .. r)
        return true
    end
    local mbot = storage.wm_creep_miners[r]
    if not mbot.entity or not mbot.entity.valid then
        game.print("A registered bot was suddenly found dead/removed! Number = " .. r)
        fields_func.unlock_tiles(r)
        fields_func.unlink_fields(r)
        storage.wm_creep_miners[r] = nil
        storage.wm_creep_miners_count = storage.wm_creep_miners_count - 1
        return true
    end

    local next_t
 
    -- MINING
    if mbot.activity == bot_actions.mining then
        local pos_f = {x = math.floor((mbot.tile.x)/8), y = math.floor((mbot.tile.y)/8)}
        local field_meta = storage.wm_cr_fields_meta[ pos_f.x .. ":" .. pos_f.y ]
        local field = storage.wm_creep_fields[ pos_f.x .. ":" .. pos_f.y ]
        mbot.entity.surface.set_tiles({{
            name = field[mbot.tileOid].hidden_tile or "landfill",
            position = mbot.tile
        }})
        mbot.entity.surface.pollute(mbot.entity.position, 8, mbot.entity.name)
        if field[mbot.tileOid].name == "kr-creep" then
            mbot.bio1 = mbot.bio1 + 1
        else
            mbot.bio2 = mbot.bio2 + 1
        end
        game.get_surface("nauvis").play_sound{path = "kr-collect-creep", position = mbot.entity.position}
        if mbot.tileOid == #field then
            field[mbot.tileOid] = nil
        else
            field[mbot.tileOid] = {}
        end
        mbot.tile = nil
        mbot.tileOid = nil
        field_meta.size_now = field_meta.size_now - 1
        if field_meta.size_now == 0 then
            --game.print("The field will be nullified !")
            fields_func.delete(pos_f)
            next_t = find_free_tick(e_tick + 90) -- taking a big rest after extracting last creep tile in the field
            action_ticks[next_t].bot = r
            mbot.next_tick = next_t
            mbot.activity = bot_actions.search_field
            mbot.entity.commandable.set_command({type = defines.command.wander, radius = 10, distraction = defines.distraction.none})
        else
            next_t = find_free_tick(e_tick + 45) -- taking a small rest after extraction activity
            action_ticks[next_t].bot = r
            mbot.next_tick = next_t
            mbot.activity = bot_actions.idle
        end
        mbot.ochre = mbot.ochre - 1
        bot_func.consume_fuel_mining(r)
        if mbot.fuel < 15000 or mbot.ochre == 0 then
            action_ticks[next_t].bot = nil
            mbot.activity = bot_actions.home
            mbot.entity.commandable.set_command({
                type = defines.command.go_to_location,
                destination = mbot.pos_found_tiles,
                radius = 1.2,
                distraction = defines.distraction.none
            })
            next_t = find_free_tick(e_tick + 2400) -- 40 seconds timeout to reach original deploy position
            --game.get_player("garrotte").create_local_flying_text{text = "I need to re-supply. My fuel: " .. mbot.fuel .. " My ochre: " .. mbot.ochre, position = mbot.entity.position, time_to_live = 150}
            action_ticks[next_t].bot = r
            mbot.next_tick = next_t
        end

        -- SEARCHING FIELDS
    elseif mbot.activity == bot_actions.search_field then
        if not mbot.searching_field then
            mbot.searching_field = {n = 1, final = false}
        end
        local res = bot_func.search_zones(r)
        if mbot.activity == bot_actions.home then
            mbot.entity.commandable.set_command({
                type = defines.command.go_to_location,
                destination = mbot.pos_found_tiles,
                radius = 1.2,
                distraction = defines.distraction.none
            })
            next_t = find_free_tick(e_tick + 2400) -- 40 seconds timeout to reach original deploy position
            game.get_player("garrotte").create_local_flying_text{text = "No more creep around. Going back to deploy position", position = mbot.entity.position, time_to_live = 150}
        elseif res then
            fields_func.create(res)
            fields_func.search_creep(res)
            next_t = find_free_tick(e_tick + 40)
        else
            next_t = find_free_tick(e_tick + 20)
        end
        bot_func.consume_fuel_basic(r, e_tick)
        if mbot.fuel < 15000 then
            mbot.activity = bot_actions.home
            mbot.entity.commandable.set_command({
                type = defines.command.go_to_location,
                destination = mbot.pos_found_tiles,
                radius = 1.2,
                distraction = defines.distraction.none
            })
            next_t = find_free_tick(e_tick + 2400)
        end
        action_ticks[next_t].bot = r
        mbot.next_tick = next_t

        -- NEW CREEP TARGETS, IDLE
    elseif mbot.activity == bot_actions.idle then
        bot_func.consume_fuel_basic(r, e_tick)
        if mbot.fuel < 15000 then
            mbot.activity = bot_actions.home
            mbot.entity.commandable.set_command({
                type = defines.command.go_to_location,
                destination = mbot.pos_found_tiles,
                radius = 1.2,
                distraction = defines.distraction.none
            })
            next_t = find_free_tick(e_tick + 2400)
        elseif not mbot.field or not mbot.field[1] then
            mbot.activity = bot_actions.search_field
            next_t = find_free_tick(e_tick + 60)
        else
            local sort_tiles = {}
            local my_pos = mbot.entity.position
            for k=1, #mbot.field do
                local found_tiles = storage.wm_creep_fields[mbot.field[k].x .. ":" .. mbot.field[k].y]
                for i=1,#found_tiles do
                    if found_tiles[i] and found_tiles[i].x and (not found_tiles[i].hunter) then
                        local dx = my_pos.x - (found_tiles[i].x + 0.5)
                        local dy = my_pos.y - (found_tiles[i].y + 0.5)
                        table.insert(sort_tiles, {
                            distance = (dx * dx) + (dy * dy),
                            oid = i,
                            field = mbot.field[k].x .. ":" .. mbot.field[k].y
                        })
                    end
                end
            end
            table.sort(sort_tiles, function (i1, i2) return i1.distance < i2.distance end )
            if sort_tiles[1] then
                local selected_tile = {
                    x = storage.wm_creep_fields[sort_tiles[1].field][sort_tiles[1].oid].x,
                    y = storage.wm_creep_fields[sort_tiles[1].field][sort_tiles[1].oid].y
                }
                mbot.tileOid = sort_tiles[1].oid
                storage.wm_creep_fields[sort_tiles[1].field][sort_tiles[1].oid].hunter = r
                mbot.tile = selected_tile
                if (my_pos.x - (selected_tile.x + 0.5))^2 > 1.1^2 or (my_pos.y - (selected_tile.y + 0.5))^2 > 1.1^2 then
                    mbot.activity = bot_actions.running
                    mbot.entity.commandable.set_command({
                        type = defines.command.go_to_location,
                        destination = {x = selected_tile.x + 0.5, y = selected_tile.y + 0.5},
                        radius = 0.9,
                        distraction = defines.distraction.none
                    })
                    next_t = find_free_tick(e_tick + 1200) -- 20 seconds timeout to reach the selected tile
                else
                    mbot.activity = bot_actions.mining
                    next_t = find_free_tick(e_tick + 119) -- mining lock
                    mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
                    --mbot.entity.direction = defines.direction.north -- need to calculate direction here
                end
            else
                -- no free creep
                --game.get_player("garrotte").create_local_flying_text{text = "All tiles are locked", position = my_pos, time_to_live = 180}
                mbot.entity.commandable.set_command({type = defines.command.wander, radius = 3, distraction = defines.distraction.none})
                fields_func.unlink_fields(r)
                mbot.activity = bot_actions.search_field
                next_t = find_free_tick(e_tick + 60)
            end
        end
        action_ticks[next_t].bot = r
        mbot.next_tick = next_t

    -- RUNNING TOOK TOO LONG
    elseif mbot.activity == bot_actions.running or mbot.activity == bot_actions.home then -- Creep is too far or difficult to reach! I need some rest.
        mining_bots.confusion(r, e_tick)
    end
end

function mining_bots.confusion(r, e_tick)
    local mbot = storage.wm_creep_miners[r]
    if not mbot or not mbot.entity or not mbot.entity.valid then return end
    if mbot.next_tick then
        storage.dissention[mbot.next_tick].bot = nil
        mbot.next_tick = nil
    end
    if not mbot.entity or not mbot.entity.valid then
        game.print("A registered bot was suddenly found dead/removed! Number = " .. r)
        fields_func.unlock_tiles(r)
        fields_func.unlink_fields(r)
        storage.wm_creep_miners[r] = nil
        storage.wm_creep_miners_count = storage.wm_creep_miners_count - 1
        return true
    end
    bot_func.consume_fuel_basic(r, e_tick)
    local next_t
    
    if mbot.activity == bot_actions.home then
        if mbot.entity.commandable.command.type ~= defines.command.wander then
            game.get_player("garrotte").create_local_flying_text{text = "I'm lost! My command is " .. mbot.entity.commandable.command.type, position = mbot.entity.position, time_to_live = 120}
            mbot.entity.commandable.set_command({type = defines.command.wander, radius = 10, distraction = defines.distraction.none})
            next_t = find_free_tick(e_tick + 180)
        else
            mbot.entity.commandable.set_command({
                type = defines.command.go_to_location,
                destination = mbot.pos_found_tiles,
                radius = 1.2,
                distraction = defines.distraction.none
            })
            next_t = find_free_tick(e_tick + 2400) -- 40 more seconds timeout to reach original deploy position :-)
        end
    else
        fields_func.unlock_tiles(r)
        next_t = find_free_tick(e_tick + 180)
        mbot.tile = nil
        mbot.tileOid = nil
        mbot.activity = bot_actions.idle
        if mbot.entity.commandable.command.type ~= defines.command.wander then
            game.get_player("garrotte").create_local_flying_text{text = "I'm lost! My command is " .. mbot.entity.commandable.command.type, position = mbot.entity.position, time_to_live = 120}
            mbot.entity.commandable.set_command({type = defines.command.wander, radius = 7, distraction = defines.distraction.none})
        else
            mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
        end
    end
    storage.dissention[next_t].bot = r
    mbot.next_tick = next_t
end

function mining_bots.arrival(r, e_tick)
    local mbot = storage.wm_creep_miners[r]
    if not mbot or not mbot.entity or not mbot.entity.valid then return end
    if mbot.next_tick then
        storage.dissention[mbot.next_tick].bot = nil
        mbot.next_tick = nil
    end
    if not mbot.entity or not mbot.entity.valid then
        game.print("A registered bot was suddenly found dead/removed! Number = " .. r)
        fields_func.unlock_tiles(r)
        fields_func.unlink_fields(r)
        storage.wm_creep_miners[r] = nil
        storage.wm_creep_miners_count = storage.wm_creep_miners_count - 1
        return true
    end
    --game.print("Droid has arrived to destination. Number = " .. r)
    bot_func.consume_fuel_basic(r, e_tick, 20)
    if mbot.activity == bot_actions.home then
        mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
        game.get_player("garrotte").create_local_flying_text{text = "I'm done. Pick me up! My fuel: " .. mbot.fuel .. " My ochre: " .. mbot.ochre, position = mbot.entity.position, time_to_live = 220}
        -- no more actions. Droid will be sleeping forever from now on.
    elseif mbot.fuel < 15000 then
        mbot.activity = bot_actions.home
        if mbot.tileOid then
            storage.wm_creep_fields[math.floor((mbot.tile.x)/8) .. ":" .. math.floor((mbot.tile.y)/8)][mbot.tileOid].hunter = nil
            mbot.tileOid = nil
        end
        mbot.entity.commandable.set_command({
            type = defines.command.go_to_location,
            destination = mbot.pos_found_tiles,
            radius = 1.2,
            distraction = defines.distraction.none
        })
        game.get_player("garrotte").create_local_flying_text{text = "I can't dig, have to return, because my fuel: " .. mbot.fuel, position = mbot.entity.position, time_to_live = 150}
        local next_t = find_free_tick(e_tick + 2400)
        storage.dissention[next_t].bot = r
        mbot.next_tick = next_t
    else
        mbot.activity = bot_actions.mining
        local next_t = find_free_tick(e_tick + 119) -- mining lock
        --mbot.entity.direction = defines.direction.north -- need to calculate direction here
        storage.dissention[next_t].bot = r
        mbot.next_tick = next_t
        mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
    end
end

return mining_bots