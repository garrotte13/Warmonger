local area = require("__flib__.area")
local math = require("__flib__.math")
local circle_rendering = require("scripts.miner-circle-rendering")
local corrosion = require("scripts.corrosion")

local constants = require("scripts.constants")
--local util = require("scripts.util")

local creep_eater = {}



function creep_eater.process()
    if global.creep_miners_count == 0 then return end
    local id = global.creep_miners_id
    local not_found_id = true
    for ids_num = 1, global.creep_miners_last do
        if global.creep_miners[id] and global.creep_miners[id].killed
        then
            global.creep_miners[id] = nil
            global.creep_miners_count = global.creep_miners_count - 1
            game.print ("Finished deleting miner with index: ".. id)
        end
        if global.creep_miners[id]
            and global.creep_miners[id].entity
                and global.creep_miners[id].entity.valid
         --       and global.creep_miners[id].entity.energy > constants.creep_mining_energy
        then
            if global.creep_miners[id].entity.burner
                and global.creep_miners[id].entity.burner.valid
                    and global.creep_miners[id].entity.get_inventory(defines.inventory.fuel)
                        and (global.creep_miners[id].entity.get_inventory(defines.inventory.fuel).is_empty()) then
                local entity = global.creep_miners[id].entity
                local last_user = entity.last_user
                game.print("Time to add some fuel")
                if last_user.character then
                    local character = last_user.character
                    if character and last_user.character.get_main_inventory() and ((character.position.x - entity.position.x)^2 + (character.position.y - entity.position.y)^2) <= constants.burner_miner_range^2 then
                        local fuel_items = {}
                        for _, item in pairs (game.item_prototypes) do
                            if item.fuel_value > 0 and item.fuel_category == "chemical" then
                                table.insert(fuel_items, {name = item.name, count = 1})
                            end
                        end
                        --  table.sort(fuel_items, function(a, b) return a.fuel_top_speed_multiplier > b.fuel_top_speed_multiplier end)
                        local inv = last_user.character.get_main_inventory()
        
                        for _, item in pairs (fuel_items) do
                            local removed = 0
                            local count =  math.min(math.ceil(game.item_prototypes[item.name].stack_size/4), math.ceil((inv.get_item_count(item.name))/2))
                            local fuel_inv = entity.get_inventory(defines.inventory.fuel)
                            if count > 0 and fuel_inv then
                                removed = inv.remove({name = item.name, count = count})
                                if removed > 0 then
                                    fuel_inv.insert({name = item.name, count = removed})
                                end
                            end
                            if removed > 0 then
                              break
                            end
                        end
                    end
                end
            end
            if global.creep_miners[id].ready_tiles > 0 then
                not_found_id = false
                break
            else if id < global.creep_miners_last then id = id + 1 else id = 1 end end

        else
            if id < global.creep_miners_last then id = id + 1 else id = 1 end
        end
    end
    if not_found_id then return end
    global.creep_miners_id = id
    local miner = global.creep_miners[id]
    local surface = miner.entity.surface
    local miner_range = constants.miner_range(miner.entity.name)
    
    if miner.stage == 0 then -- building creep tiles array

        miner.cr_tiles = {}
        miner.cr_tiles = surface.find_tiles_filtered({ -- Tiles array
            position = miner.entity.position,
            radius = miner_range,
            name = {"fk-creep", "kr-creep"}
            -- collision_mask={"ground-tile"}
        })
        if miner.cr_tiles and miner.cr_tiles[1] then miner.stage = 1
        else
            --game.print("Creep miner with Id: " .. id .. " has no creep in radius. Turning off...")
            miner.entity.active = false
            miner.deactivation_tick = game.ticks_played
            miner.stage = 50
            -- if miner.ready_tiles > 5 then miner.ready_tiles = 5 end
            -- miner.ready_tiles = 0
            if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
        end

    elseif miner.stage == 1 then --Fill sorting array

        miner.corroded_help = false
        local true_cr_found = false
        local fake_cr_found = false
        miner.sort_tiles = {}
        for i = 1,#miner.cr_tiles do
                local dx = miner.entity.position.x - miner.cr_tiles[i].position.x
                local dy = miner.entity.position.y - miner.cr_tiles[i].position.y
                table.insert(miner.sort_tiles, {
                    distance = 3000 + (dx * dx) + (dy * dy),
                    oid = i,
                    protected = false
                })
                if miner.cr_tiles[i].name == "kr-creep" then true_cr_found = true else fake_cr_found = true end
        end
        miner.truecreep = true_cr_found
        miner.fakecreep = fake_cr_found
        if fake_cr_found then
             miner.stage = 2
        else
            miner.stage = 3
        end

    elseif miner.stage == 2 then -- We have fake creep tiles to collect

        miner.enemies = surface.find_entities_filtered{
         position = miner.entity.position,
         radius = miner_range + constants.creep_max_range + math.ceil(game.forces.enemy.evolution_factor*20),
         type = {"unit-spawner", "turret"},
         force = "enemy"
        }

        if miner.truecreep then
            if miner.enemies and miner.enemies[1] then
                miner.stage = 5
                miner.enemies_found = 1
            else miner.stage = 3 end
        else miner.stage = 5 end

    elseif miner.stage == 3 then -- We have true creep tiles to collect

        miner.enemies_found = surface.count_entities_filtered{
            position = miner.entity.position,
            radius = 65,
            type =  {"unit-spawner", "turret", "unit"},
            force = "enemy"
        }
        if (not miner.fakecreep) and miner.enemies_found > 0 then -- all creep tiles are protected
            game.print("All true creep is protected! While no fake creep is available. Miner index: ".. id)
            if miner.ready_tiles > 5 then miner.ready_tiles = 5 + math.floor((miner.ready_tiles - 5) / 2) end
            miner.stage = 0
            if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
        else miner.stage = 5 end

    elseif miner.stage == 40 then
        if miner.ready_tiles > 5 then miner.ready_tiles = 5 + math.floor((miner.ready_tiles - 5) / 2) end
        miner.stage = 0
        if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end

    elseif miner.stage == 5 then -- Filtering out protected tiles

        local tiles_free = #miner.cr_tiles
        if miner.fakecreep then
            local distance_protect = constants.creep_max_range + math.ceil(game.forces.enemy.evolution_factor*20)
            distance_protect = distance_protect ^ 2
            for k=1,#miner.enemies do
              if miner.enemies[k] and miner.enemies[k].valid then
                for i=1,#miner.cr_tiles do
                    if miner.cr_tiles[i].name == "fk-creep" and (not miner.sort_tiles[i].protected) then
                        if (((miner.enemies[k].position.x - miner.cr_tiles[i].position.x)^2) + ((miner.enemies[k].position.y - miner.cr_tiles[i].position.y)^2)) <= distance_protect then
                            miner.sort_tiles[i].protected = true
                            if miner.sort_tiles[i].oid ~= i then game.print("Oops !!") end
                            tiles_free = tiles_free - 1
                        end
                    end
                end
              end
            end
            
        end
        if miner.truecreep and miner.enemies_found > 0 then
            for i=1,#miner.cr_tiles do
                if miner.cr_tiles[i].name == "kr-creep" then
                    miner.sort_tiles[i].protected = true
                    if miner.sort_tiles[i].oid ~= i then game.print("Oops !!") end
                    tiles_free = tiles_free - 1
                end
            end
        end
        if tiles_free < 0 then game.print("WTF! Free tiles number is negative (".. tiles_free.. ") for miner Index: ".. id)
        elseif tiles_free == 0 then
            --game.print("All reachable creep is protected! Miner index: ".. id)
            if miner.ready_tiles > 5 then miner.ready_tiles = 5 + math.floor((miner.ready_tiles - 5) / 2) end
            miner.stage = 0
            if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
        elseif tiles_free <= miner.ready_tiles then -- No need to sort or prioritize anything
            if global.corrosion.enabled then miner.corroded_help = true end
            miner.stage = 30
        elseif global.corrosion.enabled then miner.stage = 10 else miner.stage = 11 end

    elseif miner.stage == 10 then -- Priority for corroding free tiles

        local d = miner_range * miner_range
        for _, corroded in pairs(global.corrosion.affected) do
            if corroded.valid and corroded.surface == surface and ( ((corroded.position.x - miner.entity.position.x))^2+((corroded.position.y - miner.entity.position.y))^2 <= (d+0.5)  ) then
                local building_area = corroded.selection_box
                area.ceil(building_area)
                for i=1,#miner.cr_tiles do
                    if (not miner.sort_tiles[i].protected) and miner.sort_tiles[i].distance > 2999 and area.contains_position(building_area,miner.cr_tiles[i].position) then
                        miner.sort_tiles[i].distance = miner.sort_tiles[i].distance - 3000
                        if miner.sort_tiles[i].oid ~= i then game.print("Oops !!") end
                        miner.corroded_help = true
                    end
                end
            end
        end
        miner.stage = 11

    elseif miner.stage == 11 then -- Sorting not protected tiles

        table.sort(miner.sort_tiles, function (i1, i2) return i1.distance < i2.distance end )
        miner.stage = 30

    elseif miner.stage == 30 then -- Removing creep

        local tiles = {}
        local i = 1
        local k = 0
        local bio = 0
        while i<=#miner.cr_tiles and miner.ready_tiles>#tiles do
            if (not miner.sort_tiles[i].protected) then
                k = miner.sort_tiles[i].oid
                if miner.cr_tiles[k].name == "kr-creep" then bio = bio + 1 end
                table.insert(tiles, {name = miner.cr_tiles[k].hidden_tile or "landfill", position = miner.cr_tiles[k].position})
            end
            i = i + 1
        end
        if #tiles > 0 then
            surface.pollute(miner.entity.position, constants.pollution_miner * #tiles)
            surface.play_sound{path = "kr-collect-creep", position = miner.entity.position}
            miner.ready_tiles = miner.ready_tiles - #tiles
            if miner.chest.valid and bio > 0 then
                local lost_biomass = bio - miner.chest.insert({name="biomass", count=bio})
                if lost_biomass > 0 then game.print(lost_biomass .. " raw biomass was lost by creep miner during extraction !") end
            end
            surface.set_tiles(tiles)
        else
            --game.print("No tiles to collect, but there are tiles! Miner index: ".. id)
            if miner.ready_tiles > 5 then miner.ready_tiles = 5 + math.floor((miner.ready_tiles - 5) / 2) end
        end
        miner.cr_tiles = {}
        miner.enemies = nil
        miner.enemies_found = 0
        miner.fakecreep = false
        miner.truecreep = false
        miner.sort_tiles = {}
        if miner.corroded_help and #tiles > 0 then
            miner.stage = 45
            for j=1,#tiles do
                miner.cr_tiles[j]= {position = tiles[j].position}
            end
        else
            miner.stage = 0
            if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
        end

    elseif miner.stage == 45 then

        if miner.cr_tiles then corrosion.update_tiles(surface, miner.cr_tiles) end
        miner.stage = 0
        miner.cr_tiles = {}
        if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end

    elseif miner.stage == 50 then

        if (game.ticks_played - miner.deactivation_tick) > 10800 then
            miner.entity.active = true
            miner.stage = 0
        else
            if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
        end


    end

end

function creep_eater.add (entity)
    local surface = entity.surface
    local x = entity.position.x
    local y = entity.position.y
    local health_ = entity.health
    local chest
    local position = entity.position
    local force = entity.force
    local last_user= entity.last_user
    if not last_user then
        game.print("We have a problem! Radar was built by no player!")
    end
    local chest_name = "creep-miner1-chest"
    local radar_name = "creep-miner1-radar"
    if entity.name == "creep-miner0-overlay" or entity.name == "creep-miner0-radar" then
        chest_name = "creep-miner0-chest"
        radar_name = "creep-miner0-radar"
    end

    if entity.name == "creep-miner1-overlay" or entity.name == "creep-miner0-overlay" then
    -- if entity.name == "creep-miner1-overlay" then
        entity.destroy()
        chest = surface.create_entity({
            name = chest_name,
            position = position,
            raise_built = false,
            player = last_user,
            force = force
        })
        entity = surface.create_entity({
            name = radar_name,
            position = position,
            player = last_user,
            raise_built = false,
            force = force
        })
        entity.destructible = false
        entity.backer_name = ""
        chest.health = health_
        corrosion.engaging(chest)
    end
    -- game.print("Chest health must be: " .. health_)

    --if entity.name == "stone-furnace" or "creep-miner0-overlay" then
    --    chest = entity
    --end

    local r = 0
    for ids_num = 1, global.creep_miners_last do
        if not global.creep_miners[ids_num] then r = ids_num break end
    end
    if r == 0 then game.print ("Last member of creep_miners was incorrectly claimed!") end
    global.creep_miners[r] = {
    stage = 0,
    ready_tiles = 0,
    x = chest.position.x,
    y = chest.position.y,
    deactivation_tick = 0,
    killed = false,
    entity = entity,
    chest = chest,
    cr_tiles = {},
    sort_tiles = {},
    enemies = {},
    enemies_found = 0,
    truecreep = false,
    fakecreep = false,
    corroded_help = false
    }
    circle_rendering.add_circle(entity, last_user)
    if r == global.creep_miners_last then global.creep_miners_last = global.creep_miners_last + 1 end
    global.creep_miners_count = global.creep_miners_count + 1
    global.creep_radars[entity.position.x .. ":" .. entity.position.y] = r
    game.print("Installed creep miner with the name: " .. entity.name .. " located at x:" .. entity.position.x .. " y:" .. entity.position.y .. " Miner index:" .. r)
    game.print("Its chest is positioned at x: " .. chest.position.x .. " y:" .. chest.position.y)
    game.print("Total amount of installed creep miners: " .. global.creep_miners_count)
end

function creep_eater.remove (entit, died)
    local r = 0
    for i=1, global.creep_miners_last do
        if global.creep_miners[i]
--        and global.creep_miners[i].entity
--        and global.creep_miners[i].entity.valid
        and (global.creep_miners[i].x == entit.position.x) and (global.creep_miners[i].y == entit.position.y) then
            r = i
            break
        end
    end
    if r>0 then

        local removing = global.creep_miners[r].entity
        local last_user
        if removing.burner and removing.last_user then
            last_user = removing.last_user.character
        end
        game.print("Index number of miner pending for removal is:" .. r)
        game.print("Delete pending creep miner with the name: " .. removing.name .. " located at x:" .. removing.position.x .. " y:" .. removing.position.y)
        global.creep_radars[removing.position.x .. ":" .. removing.position.y] = nil
        circle_rendering.remove_circle(removing)
        global.creep_miners[r].killed = true
        if died then
            removing.destroy()
        else
            if last_user and (not removing.mine({inventory = last_user.get_main_inventory(), force = true, raise_destroyed = false, ignore_minable = true})) then
                game.print("Radar doesn't want to be mined!" .. r)
            end
        end
    else
        game.print("WTF?! No creep miner found for destroying!")
        game.print("Total amount of installed creep miners: " .. global.creep_miners_count)
    end

end

function creep_eater.scanned (radar)
    local id = 0
    -- game.print(" Hello! A sector has been scanned. Lets check what we got here...")
    if radar.valid then id = global.creep_radars[radar.position.x .. ":" .. radar.position.y]  else return end
    --m = radar.position.x .. ":" .. radar.position.y
    --local id = global.creep_radars[m]
    if not id then game.print ("Creep miner located at ".. radar.position.x .. ":" .. radar.position.y .. "has been lost") return end
    global.creep_miners[id].ready_tiles = global.creep_miners[id].ready_tiles + 7
    --game.print("Creep miner with Id: " .. id .. "got ready tiles: " .. global.creep_miners[id].ready_tiles)
end



function creep_eater.init()
    global.creep_miners = {}
    global.creep_miners_count = 0
    global.creep_miners_last = 1
    global.creep_miners_id = 1
    global.locked_creep = {}
    global.creep_radars = {}
end

return creep_eater