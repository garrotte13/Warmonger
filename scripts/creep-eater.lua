local util = require("scripts.util")

local circle_rendering = require("scripts.miner-circle-rendering")
local corrosion = require("scripts.corrosion")

local constants = require("scripts.constants")

local creep_eater = {}

function creep_eater.add_action_tick (action_ticks, minerId, next_tick)
    while action_ticks[next_tick] and action_ticks[next_tick].active_miner do
        next_tick = next_tick + 1
    end
    if action_ticks[next_tick] then action_ticks[next_tick].active_miner = minerId
    else
        action_ticks[next_tick] = { active_miner = minerId }
    end
    global.creep_miners[minerId].next_tick = next_tick
end

function creep_eater.find_chest(miner)
    local chests = miner.entity.surface.find_entities_filtered{
        position = miner.entity.position,
        radius = 4.25,
        type = {"container","logistic-container"},
        force = "player"
       }
    if chests and chests[1] then
        table.sort(chests, function (i1, i2) return ((i1.position.x - miner.entity.position.x)*2 + (i1.position.y - miner.entity.position.y)*2) < ((i2.position.x - miner.entity.position.x)*2 + (i2.position.y - miner.entity.position.y)*2) end )
        --table.sort(chests, function (i1, i2) return i1.distance < i2.distance end )
    else return false end
    for i = 1,#chests do
        if chests[i].valid and chests[i].get_inventory(defines.inventory.chest) and chests[i].get_inventory(defines.inventory.chest).valid
         and chests[i].get_inventory(defines.inventory.chest).get_insertable_count("biomass") > game.item_prototypes["biomass"].stack_size
          and chests[i].get_inventory(defines.inventory.chest).get_insertable_count("wm-bio-remains") > game.item_prototypes["wm-bio-remains"].stack_size
        then
            miner.chest = chests[i]
            return true
        end
    end
    return false
end

local fuel_items

function creep_eater.refuel(entity, chest_given)
   if not global.creep_miner_refuel then
        return false
   end
   local chest
   if chest_given then chest = chest_given end
   if not fuel_items then
    fuel_items = {}
    for _, item in pairs (game.item_prototypes) do
        if item.fuel_value > 0 and item.fuel_category == "chemical" then
            table.insert(fuel_items, {name = item.name, count = 1})
        end
    end
    table.sort(fuel_items, function(a, b) return game.item_prototypes[a.name].stack_size > game.item_prototypes[b.name].stack_size end)
    table.sort(fuel_items, function(a, b) return game.item_prototypes[a.name].fuel_emissions_multiplier < game.item_prototypes[b.name].fuel_emissions_multiplier end)
   end

   local inv
   local removed = 0
   local fuel_inv = entity.get_inventory(defines.inventory.fuel)
   if chest and chest.valid then
       inv = chest.get_inventory(defines.inventory.chest)
       for _, item in pairs (fuel_items) do
           local count =  math.min(math.ceil(game.item_prototypes[item.name].stack_size/4), math.ceil((inv.get_item_count(item.name))/2))
           if count > 0 then
               removed = inv.remove({name = item.name, count = count})
               if removed > 0 then
                   fuel_inv.insert({name = item.name, count = removed})
               end
           end
           if removed > 0 then
             return true
           end
       end
   end
   -- no fuel in chest. Ok then let's try to take fuel from last player accessed this miner if that player is nearby
       local last_user = entity.last_user
       if last_user and last_user.character then
           local character = last_user.character
           if character and last_user.character.get_main_inventory()
            and ((character.position.x - entity.position.x)^2 + (character.position.y - entity.position.y)^2) <= constants.burner_miner_range^2 then
               inv = last_user.character.get_main_inventory()
               for _, item in pairs (fuel_items) do
                   local count =  math.min(math.ceil(game.item_prototypes[item.name].stack_size/4), math.ceil((inv.get_item_count(item.name))/2))
                   if count > 0 and fuel_inv then
                       removed = inv.remove({name = item.name, count = count})
                       if removed > 0 then
                           fuel_inv.insert({name = item.name, count = removed})
                       end
                   end
                   if removed > 0 then return true end
               end
           end
       end
       return false
end

function creep_eater.process(action_ticks, id, t)

    local miner = global.creep_miners[id]
    if not miner then return true end
    if not miner.entity or not miner.entity.valid then -- miner is dead
        global.creep_miners[id] = nil
        global.creep_miners_count = global.creep_miners_count - 1
        return true
    end
    local surface = miner.entity.surface
    local miner_range = constants.miner_range(miner.entity.name)+1
    if miner.stage == 0 then -- building creep tiles array
        if miner.ready_tiles == 0 then
            game.print("False start! Miner isn't ready to excavate creep. Let it consume energy and prepare!")
        end

        if miner.entity.burner and miner.entity.burner.valid
         and miner.entity.get_inventory(defines.inventory.fuel)
          and (miner.entity.get_inventory(defines.inventory.fuel).is_empty()) then
            if not creep_eater.refuel(miner.entity, miner.chest) then
                --miner.stage = 60
                --miner.deactivation_tick = game.ticks_played
                --if not miner.entity.burner.remaining_burning_fuel or miner.entity.burner.remaining_burning_fuel == 0 then return end
            end
        end
        miner.entity.active = true
        miner.cr_tiles = {}
        miner.cr_tiles = surface.find_tiles_filtered({ -- Tiles array
            position = miner.entity.position,
            radius = miner_range,
            name = {"fk-creep", "kr-creep"}
            -- collision_mask={"ground-tile"}
        })
        if miner.cr_tiles and miner.cr_tiles[1] then
            miner.stage = 1
            return false
            -- creep_eater.add_action_tick(action_ticks, id, t + 1)
        else
            --game.print("Creep miner with Id: " .. id .. " has no creep in radius. Turning off...")
            miner.entity.active = false
            if global.corrosion.creepminer_hints then
                surface.create_entity{name = "true_creep_protected", position = miner.entity.position, text = "No creep in range.", time_to_live = 200}
            end
            --miner.deactivation_tick = game.ticks_played
            --miner.stage = 50
            miner.stage = 0
            creep_eater.add_action_tick(action_ticks, id, t + 7201)
            return true
        end

    elseif miner.stage == 1 then --Fill sorting array

        miner.corroded_help = false
        miner.sort_tiles = {}
        for i = 1,#miner.cr_tiles do
            local dx = miner.entity.position.x - miner.cr_tiles[i].position.x
            local dy = miner.entity.position.y - miner.cr_tiles[i].position.y
            table.insert(miner.sort_tiles, {
                distance = 3000 + (dx * dx) + (dy * dy),
                oid = i,
                protected = false
            })
        end
        miner.stage = 2
        return false
        -- creep_eater.add_action_tick(action_ticks, id, t + 1)

    elseif miner.stage == 2 then -- We have creep tiles to collect

        miner.enemies = surface.find_entities_filtered{
         position = miner.entity.position,
         radius = miner_range + 2 + constants.creep_max_range + game.forces.enemy.evolution_factor*15,
         type = {"unit-spawner", "turret"},
         force = "enemy"
        }
        miner.stage = 5
        -- creep_eater.add_action_tick(action_ticks, id, t + 1)
        return false

    elseif miner.stage == 5 then -- Filtering out protected tiles

        local tiles_free = #miner.cr_tiles
        local distance_protect = ( constants.creep_max_range + math.ceil(game.forces.enemy.evolution_factor*10) ) ^ 2
        local distance
        for k=1,#miner.enemies do
            if miner.enemies[k] and miner.enemies[k].valid then
                for i=1,#miner.cr_tiles do
                    if (not miner.sort_tiles[i].protected) then
                        distance = (miner.enemies[k].position.x - miner.cr_tiles[i].position.x)^2 + (miner.enemies[k].position.y - miner.cr_tiles[i].position.y)^2
                        if distance <= distance_protect then
                            miner.sort_tiles[i].protected = true
                            if miner.sort_tiles[i].oid ~= i then game.print("Oops !!") end
                            tiles_free = tiles_free - 1
                        else
                            if (not miner.sort_tiles[i].nearest_enemy) or (distance < miner.sort_tiles[i].nearest_enemy) then
                                miner.sort_tiles[i].nearest_enemy = distance
                            end
                        end
                    end
                end
            end
        end
        if tiles_free < 0 then game.print("WTF! Free tiles number is negative (".. tiles_free.. ") for miner Index: ".. id)
        elseif tiles_free == 0 then
            --game.print("All reachable creep is protected! Miner index: ".. id)
            if global.corrosion.creepminer_hints then
                surface.create_entity{name = "true_creep_protected", position = miner.entity.position, text = "All reachable creep is protected by enemies"}
            end
            miner.entity.active = false
            miner.stage = 0
            creep_eater.add_action_tick(action_ticks, id, t + 181)
            return true

        elseif tiles_free <= miner.ready_tiles then -- No need to sort or prioritize anything
            if global.corrosion.enabled then miner.corroded_help = true end
            miner.stage = 30
            -- creep_eater.add_action_tick(action_ticks, id, t + 1)
            return false
        elseif global.corrosion.enabled then
            miner.stage = 10
            -- creep_eater.add_action_tick(action_ticks, id, t + 1)
            return false
        else
            miner.stage = 11
            -- creep_eater.add_action_tick(action_ticks, id, t + 1)
            return false
        end

    elseif miner.stage == 10 then -- Priority for corroding free tiles

        local d = miner_range * miner_range
        local k = miner.ready_tiles
        local corroded
        for _, corrodedM in pairs(global.corrosion.affected) do
            corroded = corrodedM.e
            if corroded.valid and k > 0 and corroded.surface == surface
             and (corroded.position.x - miner.entity.position.x)^2 + (corroded.position.y - miner.entity.position.y)^2 <= (d+0.5) then
                local building_area = util.box_ceiling(corroded.selection_box)
                local building_sec_area = corroded.secondary_selection_box
                if building_sec_area then
                    building_sec_area = util.box_ceiling(building_sec_area)
                end
                for i=1,#miner.cr_tiles do
                    if (not miner.sort_tiles[i].protected) and miner.sort_tiles[i].distance > 2999
                     and ( util.contains_point(building_area,miner.cr_tiles[i].position, false)
                      or building_sec_area and ( util.contains_point(building_sec_area,miner.cr_tiles[i].position, false) ) ) then
                        miner.sort_tiles[i].distance = miner.sort_tiles[i].distance - 3000
                        k = k - 1
                        --if miner.sort_tiles[i].oid ~= i then game.print("Oops !!") end
                        miner.corroded_help = true
                        if k == 0 then break end
                    end
                end
            end
        end
        miner.stage = 11
        --creep_eater.add_action_tick(action_ticks, id, t + 1)
        return false

    elseif miner.stage == 11 then -- Sorting not protected tiles
     if not global.prio_creep_mine then global.prio_creep_mine = {} end
     if not miner.prio_box then miner.prio_box = {} end
     if not miner.corroded_help then
        local k = miner.ready_tiles
      for _, player in pairs(miner.entity.force.players) do

       local sel_area = global.prio_creep_mine[player.index]
       if sel_area and k>0 then
        if not miner.prio_box[player.index] then
            local h_height = math.abs(sel_area.right_bottom.y - sel_area.left_top.y) / 2
            local h_width = math.abs(sel_area.right_bottom.x - sel_area.left_top.x) / 2
            local area_centre = {x = sel_area.left_top.x + h_width, y = sel_area.left_top.y + h_height}
            local add_to_rad = math.sqrt( h_height^2 + h_width^2 ) + 1
            if math.sqrt((miner.x - area_centre.x)^2 + (miner.y - area_centre.y)^2) <= ( miner_range + add_to_rad ) then
                miner.prio_box[player.index] = 1
            else
                miner.prio_box[player.index] = 2
            end
        end
        if miner.prio_box[player.index] == 1 then
            local found_box = false
           -- local s = 0
            for i=1,#miner.cr_tiles do
                if util.contains_point(sel_area,miner.cr_tiles[i].position, false) then
                    found_box = true
                    if (not miner.sort_tiles[i].protected) and miner.sort_tiles[i].distance > 1999 then
                        miner.sort_tiles[i].distance = miner.sort_tiles[i].distance - 1000
                        --s = s + 1
                        k = k - 1
                        if k == 0 then break end
                    end
                end
            end
            --if s > 0 then game.print("Number of prioritized tiles selected: ".. s) end
            if not found_box then
                miner.prio_box[player.index] = 2
            end
        end
       end
      end
     end
        table.sort(miner.sort_tiles, function (i1, i2) return i1.distance < i2.distance end )
        miner.stage = 30
        --creep_eater.add_action_tick(action_ticks, id, t + 1)
        return false

    elseif miner.stage == 30 then -- Removing creep

        local creep1_cap = 0
        local creep2_cap = 0
        local creep3_cap = 0
        local chest
        if miner.chest and miner.chest.valid and miner.chest.get_inventory(defines.inventory.chest) and miner.chest.get_inventory(defines.inventory.chest).valid then
            chest = miner.chest
            if chest.get_inventory(defines.inventory.chest).get_insertable_count("biomass") == 0 then
                chest = nil
                miner.chest = nil
            end
        end
        if not chest then
            if creep_eater.find_chest(miner) then chest = miner.chest end
        end
        if chest then
            creep1_cap = chest.get_inventory(defines.inventory.chest).get_insertable_count("biomass")
            creep2_cap = chest.get_inventory(defines.inventory.chest).get_insertable_count("wm-bio-remains")
            if creep1_cap >= game.item_prototypes["biomass"].stack_size and creep2_cap >= game.item_prototypes["wm-bio-remains"].stack_size then
    -- if your chest has exactly two free filtered slots, one dedicated for each biomass type, then you won't gather bio-remnants. Sorry, pal!
                creep2_cap = creep2_cap - game.item_prototypes["wm-bio-remains"].stack_size
            end
        end
       if miner.entity.burner and miner.entity.burner.valid and global.creep_miner_refuel then
            local f_inv = miner.entity.get_inventory(defines.inventory.fuel)
            if f_inv and f_inv.valid and f_inv.get_insertable_count("wm-bio-remains") > 0 then
                creep3_cap = 1000 + f_inv.get_insertable_count("wm-bio-remains")
            end
            if f_inv and f_inv.is_empty() then
               if not creep_eater.refuel(miner.entity, miner.chest) then creep2_cap = 0 end -- if no fuel, then gather all bioremains in burner
            end
       end
        local tiles = {}
        local i = 1
        local k = 0
        local bio = 0
        local bio2 = 0
        local fire_distance = ( constants.creep_max_range + 1 + math.ceil(game.forces.enemy.evolution_factor*15) ) ^ 2
        while i<=#miner.cr_tiles and miner.ready_tiles>#tiles do
            if (not miner.sort_tiles[i].protected) then
                k = miner.sort_tiles[i].oid
                if miner.cr_tiles[k].name == "kr-creep" and creep1_cap > 0 then
                    bio = bio + 1
                    creep1_cap = creep1_cap - 1
                    table.insert(tiles, {name = miner.cr_tiles[k].hidden_tile or "landfill", position = miner.cr_tiles[k].position})
                    if #miner.enemies > 0 and miner.sort_tiles[i].nearest_enemy
                     and miner.sort_tiles[i].nearest_enemy < fire_distance and math.random(1,5) > 1 then -- creep excavation touches enemy building
                        k = math.random(1, #miner.enemies)
                        if miner.enemies[k] and miner.enemies[k].valid then
                            local applied_test_dmg = miner.enemies[k].damage(0.5, "player", "fire", miner.entity) -- teasing enemies
                        end
                    end
                elseif miner.cr_tiles[k].name == "fk-creep" then
                    if math.random(1,10) < 4 and (creep2_cap > 0 or creep3_cap > 1000) then
                        bio2 = bio2 + 1
                        if creep2_cap > 0 then creep2_cap = creep2_cap - 1 else creep3_cap = creep3_cap - 1 end
                    end
                    table.insert(tiles, {name = miner.cr_tiles[k].hidden_tile or "landfill", position = miner.cr_tiles[k].position})
                end
            end
            i = i + 1
        end
        i = #miner.cr_tiles
        --game.print("Tiles collected: ".. #tiles .. ". Tiles in range: " .. #miner.cr_tiles .. ". Sorted tiles: ".. #miner.sort_tiles .. ". Biomass tiles: ".. bio)
        if #tiles > 0 then
            surface.play_sound{path = "kr-collect-creep", position = miner.entity.position}
            miner.ready_tiles = miner.ready_tiles - #tiles
            if chest and chest.valid and bio > 0 then
                local lost_biomass = bio - chest.insert({name="biomass", count=bio})
                if lost_biomass > 0 then game.print(lost_biomass .. " raw biomass was lost by creep miner during extraction !") end
            end
            if bio2 > 0 then
                local lost_biomass2 = 0
                if chest and chest.valid then lost_biomass2 = bio2 - chest.insert({name="wm-bio-remains", count=bio2}) else lost_biomass2 = bio2 end
                if lost_biomass2 > 0 and creep3_cap > 999 and miner.entity.burner.valid then
                    lost_biomass2 = lost_biomass2 - miner.entity.get_inventory(defines.inventory.fuel).insert({name="wm-bio-remains", count=lost_biomass2})
                end
                if lost_biomass2 > 0 then game.print(lost_biomass2 .. " of bio remnants were lost by creep miner during extraction !") end
            end
            surface.set_tiles(tiles)
        end
        miner.cr_tiles = {}
        miner.enemies = nil
        miner.sort_tiles = {}
        if #tiles == 0 then
            --game.print("There are creep tiles, but we can't collect them (nowhere to store biomass or all creep type-2 is protected)! Miner index: ".. id)
            if global.corrosion.creepminer_hints then
                surface.create_entity{name = "true_creep_protected", position = miner.entity.position, text = "No chest found to store biomass of excavated biter creep"}
            end
            --miner.ready_tiles = math.floor((miner.ready_tiles) / 2)
            miner.entity.active = false
            --miner.deactivation_tick = game.ticks_played
            miner.stage = 0
            creep_eater.add_action_tick(action_ticks, id, t + 181)
            return true
        else
            if #tiles == i then -- time to go into stage 50, because we gathered all creep available
                miner.entity.active = false
                if global.corrosion.creepminer_hints then
                    surface.create_entity{name = "true_creep_protected", position = miner.entity.position, text = "All creep in range has been collected.", time_to_live = 250}
                end
                --miner.deactivation_tick = game.ticks_played
            end
            if miner.corroded_help then
                miner.stage = 45
                for j=1,#tiles do
                    miner.cr_tiles[j]= {position = tiles[j].position}
                end
                -- creep_eater.add_action_tick(action_ticks, id, t + 1)
                return false
            else
                if miner.entity.active then
                    if miner.ready_tiles > 0 then creep_eater.add_action_tick(action_ticks, id, t + 1) else miner.next_tick = 0 end
                else
                    creep_eater.add_action_tick(action_ticks, id, t + 7201)
                end
                miner.stage = 0
                return true
            end
        end

    elseif miner.stage == 45 then

        if miner.cr_tiles then corrosion.update_tiles(surface, miner.cr_tiles) end
        miner.cr_tiles = {}
        if miner.entity.active then
            if miner.ready_tiles > 0 then creep_eater.add_action_tick(action_ticks, id, t + 1) else miner.next_tick = 0 end
        else
            creep_eater.add_action_tick(action_ticks, id, t + 7201)
        end
        miner.stage = 0
        return true

    elseif miner.stage == 60 then -- re-fuelling cycle for passive miners only!

        if miner.entity.burner and miner.entity.burner.valid and miner.entity.get_inventory(defines.inventory.fuel)
         and (miner.entity.get_inventory(defines.inventory.fuel).is_empty()) then
            --if (game.ticks_played - miner.deactivation_tick) > 600 then
                if ( not creep_eater.refuel(miner.entity, miner.chest) ) and global.creep_miner_refuel then
                    miner.deactivation_tick = game.ticks_played
                    creep_eater.add_action_tick(action_ticks, id, t + 601)
                    --if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
                else
                -- auto-refuelling turned off or we re-fuelled successfully. If auto-refuelling will be turned on later, player must feed miner manually once
                    miner.stage = 0
                    miner.next_tick = 0
                end
            --else
              --  if id < global.creep_miners_last then global.creep_miners_id = id + 1 else global.creep_miners_id = 1 end
            --end
        else
            miner.stage = 0
            miner.next_tick = 0
            return true
        end

    end
end

function creep_eater.add (entity, t)
    local surface = entity.surface
    local x = entity.position.x
    local y = entity.position.y
    local health_ = entity.health
    local position = entity.position
    local force = entity.force
    local last_user = entity.last_user
    if not last_user then
        game.print("We have a problem! Radar was built by no player!")
    end

        entity.backer_name = ""
        corrosion.engaging(entity, t)

    local r = 0
    for ids_num = 1, global.creep_miners_last do
        if not global.creep_miners[ids_num] then r = ids_num break end
    end
    if r == 0 then game.print ("Last member of creep_miners was incorrectly claimed!") end
    -- local p_coeff = game.map_settings.pollution.ageing
    -- game.print("Pollution absorption coefficient: " .. p_coeff)
    global.creep_miners[r] = {
    stage = 0,
    ready_tiles = 0,
    x = x,
    y = y,
    deactivation_tick = 0,
    killed = false,
    entity = entity,
    chest = nil,
    cr_tiles = {},
    sort_tiles = {},
    enemies = {},
    enemies_found = 0,
    truecreep = false,
    fakecreep = false,
    corroded_help = false,
    prio_box = {},
    next_tick = 0
    }
    circle_rendering.add_circle(entity, last_user)
    if entity.name == "creep-miner0-radar" then
        global.creep_miners[r].stage = 60
        creep_eater.add_action_tick(global.dissention, r, t + 1)
    end
    global.creep_radars[entity.position.x .. ":" .. entity.position.y] = r
    if r == global.creep_miners_last then global.creep_miners_last = global.creep_miners_last + 1 end
    global.creep_miners_count = global.creep_miners_count + 1
    --game.print("Installed creep miner with the name: " .. entity.name .. " located at x:" .. entity.position.x .. " y:" .. entity.position.y .. " Miner index:" .. r)
    --game.print("Total amount of installed creep miners: " .. global.creep_miners_count)
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
        --game.print("Index number of miner pending for removal is:" .. r)
        --game.print("Delete pending creep miner with Id: " .. r .. " located at x:" .. entit.position.x .. " y:" .. entit.position.y)
        global.creep_radars[entit.position.x .. ":" .. entit.position.y] = nil
        circle_rendering.remove_circle(entit)
        local nex_t = global.creep_miners[r].next_tick
        if nex_t and nex_t > 0 then global.dissention[nex_t].active_miner = nil end
        global.creep_miners[r] = nil

    else
        game.print("WTF?! No creep miner found for destroying!")
        game.print("Total amount of installed creep miners: " .. global.creep_miners_count)
    end

end

function creep_eater.scanned (radar, t)
    local id = 0
    -- game.print(" Hello! A sector has been scanned. Lets check what we got here...")
    if radar.valid then id = global.creep_radars[radar.position.x .. ":" .. radar.position.y]  else return end
    if not id then game.print ("Creep miner located at ".. radar.position.x .. ":" .. radar.position.y .. " has been lost") return end
    local r_tiles = global.creep_miners[id].ready_tiles
    if r_tiles < 40 then
        global.creep_miners[id].ready_tiles = r_tiles + 7
    end
    local nex_t = global.creep_miners[id].next_tick
    if global.creep_miners[id].stage == 60 then -- I stop waiting for fuel and go to work, freeing next refuel tick
        if nex_t and nex_t > 0 then global.dissention[nex_t].active_miner = nil end
        creep_eater.add_action_tick(global.dissention, id, t + 1)
        global.creep_miners[id].stage = 0
    elseif global.creep_miners[id].stage == 0 then -- wake up and go to work now
        if nex_t and nex_t > 0 then global.dissention[nex_t].active_miner = nil end
        creep_eater.add_action_tick(global.dissention, id, t + 1)
    end
    --game.print("Creep miner with Id: " .. id .. "got ready tiles: " .. global.creep_miners[id].ready_tiles)
end



function creep_eater.init()
    global.creep_miners = {}
    global.prio_creep_mine = {}
    global.creep_miners_count = 0
    global.creep_miners_last = 1
    global.creep_miners_id = 1
    global.creep_radars = {}
    global.creep_miner_refuel = settings.global["wm-CreepMinerFueling"].value
    global.creep_miners_queue = {}
    global.creep_miners_lastq = 0
end

return creep_eater