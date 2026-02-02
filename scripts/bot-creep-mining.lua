local mining_bots = {}
local fields_func = require("fields_logic")
local bot_func = require("bot_logic")

local direction_vectors = {
    [defines.direction.north]          = { 0, -1 },
    [defines.direction.northnortheast] = { 1, -2 },
    [defines.direction.northeast]      = { 1, -1 },
    [defines.direction.eastnortheast]  = { 2, -1 },
    [defines.direction.east]           = { 1,  0 },
    [defines.direction.eastsoutheast]  = { 2,  1 },
    [defines.direction.southeast]      = { 1,  1 },
    [defines.direction.southsoutheast] = { 1,  2 },
    [defines.direction.south]          = { 0,  1 },
    [defines.direction.southsouthwest] = {-1,  2 },
    [defines.direction.southwest]      = {-1,  1 },
    [defines.direction.westsouthwest]  = {-2,  1 },
    [defines.direction.west]           = {-1,  0 },
    [defines.direction.westnorthwest]  = {-2, -1 },
    [defines.direction.northwest]      = {-1, -1 },
    [defines.direction.northnorthwest] = {-1, -2 },
  }
local function posititionsToDirect(subj, target)
    --local deg = math.deg(math.atan2(target.y - subj.y, target.x - subj.x))
    --local direction = (deg + 90) / 22.5
    local direction = defines.direction.south
    --if direction < 0 then
      --direction = direction + 16
    --end
    --direction = math.floor(direction + 0.5)
    return direction
end

local bot_actions = bot_func.bot_actions


local function find_free_tick(e_tick)
    local action_ticks = storage.dissention
    while action_ticks[e_tick] and action_ticks[e_tick].bot do e_tick = e_tick + 1 end
    if not action_ticks[e_tick] then
        action_ticks[e_tick] = {bot = 0, tree = nil}
    end
return e_tick
end

local function SendHome(r, e_tick)
    local mbot = storage.wm_creep_miners[r]
    mbot.activity = bot_actions.home
    fields_func.unlock_tiles(r)
    mbot.tile = nil
    mbot.tileOid = nil
    mbot.extile = nil
    fields_func.unlink_fields(r)
    mbot.entity.commandable.set_command({
        type = defines.command.go_to_location,
        destination = mbot.pos_found_tiles,
        radius = 2.1,
        distraction = defines.distraction.none
    })
    local next_t = find_free_tick(e_tick + 300)
    mbot.running_long = 2100
    storage.dissention[next_t].bot = r
    mbot.next_tick = next_t
end

function mining_bots.Show_Selected(e)
    local player = game.players[e.player_index]
    local entity = player.selected
    if entity and entity.valid and entity.name == "wm-droid-1" and entity.unit_number and entity.force == player.force then
        local mbot = storage.wm_creep_miners[entity.unit_number]
        --player.create_local_flying_text{text = "Fuel: " .. mbot.fuel .. " Ochre: " .. mbot.ochre, position = entity.position, time_to_live = 120}
        local value = mbot.fuel/48000
        local red = math.min(2-value*2, 1)
        local green = math.min(value*2, 1)
        rendering.draw_rectangle{color = {0,0,0}, 
        left_top = {entity = entity, offset = {-1-0.03, 1-0.03}},
        right_bottom = {entity = entity, offset = { 1+0.03,	1.2+0.03}},
        players = {player},
        surface = entity.surface,
        time_to_live = 120,
        }
        rendering.draw_rectangle{color = {0,0,0}, 
        left_top = {entity = entity, offset = {1+2/32, 1.05}},
        right_bottom = {entity = entity, offset = {1+3/32, 1.15}},
        players = {player},
        surface = entity.surface,
        time_to_live = 120,
        }
        rendering.draw_rectangle{color = {red,green, 0}, filled = true,
        left_top = {entity = entity, offset = {-1, 1.0}},
        right_bottom = {entity = entity, offset = {-1 + 2*1*value, 1.2}},
        players = {player},
        surface = entity.surface,
        time_to_live = 120,
        }
        value = mbot.ochre/25
        red = math.min(2-value*2, 1)
        green = math.min(value*2, 1)
        rendering.draw_rectangle{color = {0,0,0}, 
        left_top = {entity = entity, offset = {-1-0.03, 0.7-0.03}},
        right_bottom = {entity = entity, offset = { 1+0.03,	0.9+0.03}},
        players = {player},
        surface = entity.surface,
        time_to_live = 120,
        }
        rendering.draw_rectangle{color = {0,0,0}, 
        left_top = {entity = entity, offset = {1+2/32, 0.65}},
        right_bottom = {entity = entity, offset = {1+3/32, 0.85}},
        players = {player},
        surface = entity.surface,
        time_to_live = 120,
        }
        rendering.draw_rectangle{color = {red,green, 0}, filled = true,
        left_top = {entity = entity, offset = {-1, 0.7}},
        right_bottom = {entity = entity, offset = {-1 + 2*1*value, 0.9}},
        players = {player},
        surface = entity.surface,
        time_to_live = 120,
        }
    end
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
        mbots[r] = {
            tile = nil,
            extile = nil,
            entity = entity,
            fuel = 0,
            fuel_name = nil,
            running_long = 0,
            ochre = 0,
            bio1 = 0,
            bio2 = 0,
            tileOid = nil,
            pos_found_tiles = entity.position,
            field = {},
            searching_field = nil,
            activity = bot_actions.refueling,        
            t_activity = e_tick,
            next_tick = nil
        }
        return
    end

    local next_t = find_free_tick(e_tick + 90) -- give the newborn a second to look around
    mbots[r] = {
        tile = nil, -- the target creep tile pos selected by bot
        extile = nil,
        entity = entity,
        fuel = fuel, -- 12x4MJ 12 units of coal or 4 units of solid fuel. 80% efficiency means 15 coal or 5 solid is needed.
        fuel_name = fuel_item,
        ochre = ochre, -- 5 units, where every 2 units are made of 2 iron and 3 stone + water
        bio1 = 0,
        bio2 = 0,
        running_long = 0,
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

function mining_bots.create_system(e_tick)
    local next_t = find_free_tick(e_tick + 60)
    local mbots = storage.wm_creep_miners
    mbots[0] = {
        activity = bot_actions.system,
        next_tick = next_t
    }
    storage.dissention[next_t].bot = 0
    storage.wm_creep_miners_count = storage.wm_creep_miners_count + 1
end

function mining_bots.process(r, e_tick)
    local action_ticks = storage.dissention
    if not storage.wm_creep_miners[r] then
        game.print("Asked to process not registered bot with the number = " .. r)
        return true
    end
    local mbot = storage.wm_creep_miners[r]
    if r > 0 and (not mbot.entity or not mbot.entity.valid) then
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
        mbot.extile = nil
        mbot.entity.surface.set_tiles({{
            name = field[mbot.tileOid].hidden_tile or "landfill",
            position = mbot.tile
        }})
        mbot.entity.surface.pollute(mbot.entity.position, 2.3, mbot.entity.name)
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
        if field_meta.size_now == 0 then fields_func.delete(pos_f) end
        mbot.ochre = mbot.ochre - 1
        bot_func.consume_fuel_mining(r)
        mbot.t_activity = e_tick
        if mbot.fuel < 8000 or mbot.ochre == 0 then
            SendHome(r, e_tick)
        else
            next_t = find_free_tick(e_tick + 40) -- taking a small rest after extraction activity
            mbot.activity = bot_actions.idle
            action_ticks[next_t].bot = r
            mbot.next_tick = next_t
        end

        -- SEARCHING FIELDS
    elseif mbot.activity == bot_actions.search_field then
        if not bot_func.consume_fuel_basic(r, e_tick) then return end
        if mbot.fuel < 8000 then
            SendHome(r, e_tick)
        else
            if not mbot.searching_field then
                mbot.searching_field = {n = 1, final = false}
            end
            local res = bot_func.search_zones_near(r)
            if mbot.activity == bot_actions.home then
                SendHome(r, e_tick)
                game.get_player("garrotte").create_local_flying_text{text = "No more creep around. Going home", position = mbot.entity.position, time_to_live = 150}
                return
            elseif res then
                fields_func.create(res)
                fields_func.search_creep(res)
                next_t = find_free_tick(e_tick + 40)
            else
                next_t = find_free_tick(e_tick + 20)
            end
            action_ticks[next_t].bot = r
            mbot.next_tick = next_t
        end


        -- NEW CREEP TARGETS, IDLE
    elseif mbot.activity == bot_actions.idle then
        if not bot_func.consume_fuel_basic(r, e_tick) then return end
        if mbot.fuel < 8000 then
            SendHome(r, e_tick)
            return
        elseif not mbot.field or not mbot.field[1] then
            mbot.activity = bot_actions.search_field
            next_t = find_free_tick(e_tick + 40)
        elseif mbot.searching_field.n < 3 then
            local res = bot_func.search_zones_near(r)
            if res then
                fields_func.create(res)
                fields_func.search_creep(res)
                next_t = find_free_tick(e_tick + 40)
            else
                if mbot.searching_field.n < 9 then mbot.searching_field.n = mbot.searching_field.n + 1 end
                next_t = find_free_tick(e_tick + 10)
            end
        else
            local sort_tiles = {}
            local my_pos = mbot.entity.position
            for k=1, #mbot.field do
                local found_tiles = storage.wm_creep_fields[mbot.field[k].x .. ":" .. mbot.field[k].y]
                for i=1,#found_tiles do
                    if found_tiles[i] and found_tiles[i].x and (not found_tiles[i].hunter) then
                        local tile_unreachable
                        if mbot.extile and mbot.extile[1] then
                            for j=1,#mbot.extile do
                                if found_tiles[i].x == mbot.extile[j].x and found_tiles[i].y == mbot.extile[j].y then
                                    tile_unreachable = true
                                    break
                                end
                            end
                        end
                        local ddistance = (my_pos.x - (found_tiles[i].x + 0.5))^2 + (my_pos.y - (found_tiles[i].y + 0.5))^2
                        if (not tile_unreachable) or (ddistance <= 1.65^2) then
                            table.insert(sort_tiles, {
                                distance = ddistance,
                                oid = i,
                                field = mbot.field[k].x .. ":" .. mbot.field[k].y
                            })
                        end
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
                if sort_tiles[1].distance > 1.65^2 then
                    mbot.activity = bot_actions.running
                    mbot.entity.commandable.set_command({
                        type = defines.command.go_to_location,
                        destination = {x = selected_tile.x + 0.5, y = selected_tile.y + 0.5},
                        radius = 0.99,
                        distraction = defines.distraction.none
                    })
                    next_t = find_free_tick(e_tick + 120)
                    mbot.running_long = 1080
                else
                    mbot.activity = bot_actions.mining
                    next_t = find_free_tick(e_tick + 119) -- mining lock
                    mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
                    mbot.entity.direction = posititionsToDirect(my_pos, {x = selected_tile.x + 0.5, y = selected_tile.y + 0.5})
                    --mbot.entity.direction = defines.direction.north -- need to calculate direction here
                end
                if mbot.searching_field.n < 9 then
                    mbot.searching_field.n = 2
                end
            else
                -- no free creep
                --game.get_player("garrotte").create_local_flying_text{text = "All tiles are locked", position = my_pos, time_to_live = 180}
                mbot.entity.commandable.set_command({type = defines.command.wander, radius = 3, distraction = defines.distraction.none})
                --fields_func.unlink_fields(r)
                mbot.activity = bot_actions.search_field
                next_t = find_free_tick(e_tick + 40)
            end
        end
        action_ticks[next_t].bot = r
        mbot.next_tick = next_t

    -- CHECK RUNNING
    elseif mbot.activity == bot_actions.running or mbot.activity == bot_actions.home then
        if bot_func.consume_fuel_basic(r, e_tick) then
            if mbot.fuel < 8000 and mbot.activity == bot_actions.running then
                SendHome(r, e_tick)
                return
            end
            if mbot.running_long > 12 then
                next_t = find_free_tick(e_tick + math.min(300, mbot.running_long))
                mbot.running_long = mbot.running_long - (next_t - e_tick)
                action_ticks[next_t].bot = r
                mbot.next_tick = next_t
            else
                mining_bots.confusion(r, e_tick, true)
            end
        else
            -- out of fuel already!
        end

    elseif mbot.activity == bot_actions.system then
        local fields_to_update = storage.wm_updating_fields
        local fields = storage.wm_creep_fields
        local fields_meta = storage.wm_cr_fields_meta
        for i, f in pairs(fields_to_update) do
            if fields[i] then
                if fields_meta[i].bots and fields_meta[i].bots[1] then
                    -- don't do anything for now
                else
                    fields[i] = nil
                    fields_meta[i] = nil
                    fields_to_update[i] = nil
                end
            else
                fields_to_update[i] = nil
            end
        end
        next_t = find_free_tick(e_tick + 30)
        action_ticks[next_t].bot = r
        mbot.next_tick = next_t

        --[[temp code, kill me
        if storage.wm_creep_miners_count == 1 then
            --game.print("cleaning")
            for i, f in pairs(fields_meta) do
                fields[i] = nil
                fields_meta[i] = nil
            end
        end
        -- end of temp code]]
    end
end

function mining_bots.confusion(r, e_tick, checked)
    local mbot = storage.wm_creep_miners[r]
    if not checked then
        if not mbot then return end
        if mbot.next_tick then
            if (not storage.dissention[mbot.next_tick]) or (not storage.dissention[mbot.next_tick].bot) then
                game.print("A registered bot has no proper time restrictions! Number = " .. r)
            else
                storage.dissention[mbot.next_tick].bot = nil
                mbot.next_tick = nil
            end
        else
            if mbot.entity then
                game.get_player("garrotte").create_local_flying_text{text = "Aaah! My ass hurts!", position = mbot.entity.position, time_to_live = 120}
            else
                --game.print("Aaah! Bot is destroyed, but still confused!")
            end
        end
        if not mbot.entity or not mbot.entity.valid then
            game.print("A registered bot was suddenly found dead/removed! Number = " .. r)
            fields_func.unlock_tiles(r)
            fields_func.unlink_fields(r)
            storage.wm_creep_miners[r] = nil
            storage.wm_creep_miners_count = storage.wm_creep_miners_count - 1
            return true
        end
        if not bot_func.consume_fuel_basic(r, e_tick, 5) then return end
    end
    local next_t
    if mbot.activity == bot_actions.home then
        if (not mbot.entity.commandable.command) or mbot.entity.commandable.command.type ~= defines.command.wander then
            game.get_player("garrotte").create_local_flying_text{text = "I've lost my way home!", position = mbot.entity.position, time_to_live = 120}
            mbot.entity.commandable.set_command({type = defines.command.wander, radius = 10, distraction = defines.distraction.none})
            next_t = find_free_tick(e_tick + 180)
        else
            mbot.entity.commandable.set_command({
                type = defines.command.go_to_location,
                destination = mbot.pos_found_tiles,
                radius = 2.1,
                distraction = defines.distraction.none
            })
            next_t = find_free_tick(e_tick + 300) -- 40 more seconds timeout to reach original deploy position :-)
            mbot.running_long = 2100
        end
    else
        fields_func.unlock_tiles(r)
        if not mbot.extile then mbot.extile = {} end
        table.insert(mbot.extile, mbot.tile)
        mbot.tile = nil
        mbot.tileOid = nil
        next_t = find_free_tick(e_tick + 150)
        mbot.activity = bot_actions.idle
        if (not mbot.entity.commandable.command) or mbot.entity.commandable.command.type ~= defines.command.wander then
            game.get_player("garrotte").create_local_flying_text{text = "I can't get to my target tile!", position = mbot.entity.position, time_to_live = 120}
            mbot.entity.commandable.set_command({type = defines.command.wander, radius = 9, distraction = defines.distraction.none})
        else
            mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
            game.get_player("garrotte").create_local_flying_text{text = "I'm riding in circles to my target tile!", position = mbot.entity.position, time_to_live = 120}
        end
    end
    storage.dissention[next_t].bot = r
    mbot.next_tick = next_t
end

function mining_bots.arrival(r, e_tick)
    local mbot = storage.wm_creep_miners[r]
    if not mbot then return end
    if mbot.next_tick then
        if (not storage.dissention[mbot.next_tick]) or (not storage.dissention[mbot.next_tick].bot) then
            game.print("A registered bot has no proper time restrictions! Number = " .. r)
        else
            storage.dissention[mbot.next_tick].bot = nil
            mbot.next_tick = nil
        end
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
    mbot.extile = nil
    if not bot_func.consume_fuel_basic(r, e_tick, 5) then return end
    if mbot.activity == bot_actions.home then
        mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
        game.get_player("garrotte").create_local_flying_text{text = "I'm at home. Pick me up!", position = mbot.entity.position, time_to_live = 220}
        -- no more actions. Droid will be sleeping forever from now on.
        mbot.activity = bot_actions.depot
        mbot.entity.active = false
    elseif mbot.fuel < 7000 then
        SendHome(r, e_tick)
        game.get_player("garrotte").create_local_flying_text{text = "I can't dig, have to return, because my fuel: " .. mbot.fuel, position = mbot.entity.position, time_to_live = 150}
    else
        local next_t
        mbot.entity.commandable.set_command({type = defines.command.stop, distraction = defines.distraction.none})
        local diff_x = ( mbot.entity.position.x - (mbot.tile.x + 0.5) ) ^ 2
        local diff_y = ( mbot.entity.position.y - (mbot.tile.y + 0.5) ) ^ 2
        if ( diff_x + diff_y ) > 2.35^2 then -- let's try to look around once more
            fields_func.unlock_tiles(r)
            next_t = find_free_tick(e_tick + 20)
            mbot.tile = nil
            mbot.tileOid = nil
            mbot.activity = bot_actions.idle
        else
            mbot.activity = bot_actions.mining
            next_t = find_free_tick(e_tick + 119) -- mining lock
        --mbot.entity.direction = defines.direction.north -- need to calculate direction here
        end
        storage.dissention[next_t].bot = r
        mbot.next_tick = next_t
    end
end

return mining_bots