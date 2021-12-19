local area = require("__flib__.area")
local math = require("__flib__.math")
local misc = require("__flib__.misc")
local corrosion = require("scripts.corrosion")

local constants = require("scripts.constants")
local util = require("scripts.util")

local creep_eater = {}

--[[
function create_creep_footprint ()

Let's use Connect-48 to build footprint (radius of 3 around each tile is a part of the same footprint), but work only with kr-creep.

Footprint can be
created
expanded
cut
deleted - when?
merged - when a new nest is built between two footprints.
split? (hm, don't think so)


end
--]]

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
                and not global.creep_miners[id].entity.is_crafting()    -- need to check value for cases: not enough fuel, ... something else
        then
            not_found_id = false
            break
        else
            if id < global.creep_miners_last then id = id + 1 else id = 1 end
        end
    end
    if not_found_id then return end
    global.creep_miners_id = id
    local miner = global.creep_miners[id]
    local miner_range = constants.electric_miner_range
    if miner.entity.name == "creep-processor0" then miner_range = constants.burner_miner_range end

    if miner.stage == 0 then
-- building "creep tiles in range" array

        global.creep_miners[id].cr_tiles = miner.entity.surface.find_tiles_filtered({ -- Lua tiles array
            position = miner.entity.position,
            radius = miner_range,
            name = {"fk-creep", "kr-creep"},
            collision_mask={"ground-tile"}
        })
        if global.creep_miners[id].cr_tiles then miner.stage = 1 end
    elseif miner.stage == 1 then
--finding priority tiles to get creep from

        miner.stage = 2
    elseif miner.stage == 2 then
--checking enemies protection

        --miner.entity.surface.play_sound{path = "kr-collect-creep", position = miner.entity.position}
        miner.stage = 3
    elseif miner.stage == 3 then
--selecting tile to eat and locking it

       -- Temporary for tests. Replace it ASAP!
       local tile = nil
        for ti=1,#miner.cr_tiles do
            local t = miner.entity.surface.get_tile(miner.cr_tiles[ti].position)
            if t.name == "kr-creep" or t.name == "fk-creep" then tile = t break end
        end
        if tile and (tile.name == "kr-creep" or tile.name == "fk-creep") then
            global.locked_creep[id] = tile
            miner.stage = 4
        else
            miner.stage = 0 --someone has purged this tile already while miner was preparing, so it was a waste of time&energy
        end
--        miner.cr_tiles = nil
    elseif miner.stage == 4 then
--removing creep tile, inserting extracted biomass and checking for freed affected entities

        miner.entity.surface.play_sound{path = "kr-collect-creep", position = global.locked_creep[id].position}
        local clean_tile = { name = global.locked_creep[id].hidden_tile or "landfill", position = global.locked_creep[id].position }
        local tiles = {}
        tiles[1] = clean_tile
        if global.locked_creep[id].name == "kr-creep" then
            local lost_biomass = 20 - miner.entity.insert({name="extracted-creep", count=20})
            if lost_biomass > 0 then game.print(lost_biomass .. " raw biomass was lost by creep miner during extraction !") end
        end
        miner.entity.surface.set_tiles(tiles)
        corrosion.update_tile(miner.entity.surface, global.locked_creep[id].position)
        global.locked_creep[id] = nil
        miner.stage = 0
    end

    if global.creep_miners_id < global.creep_miners_last then global.creep_miners_id = global.creep_miners_id + 1 else global.creep_miners_id = 1 end
end

function creep_eater.add (entity)
    global.creep_miners[global.creep_miners_last] = {
    stage = 0,
    x = entity.position.x,
    y = entity.position.y,
    killed = false,
    entity = entity,
    cr_tiles = {}
    }
    --global.locked_creep[global.creep_miners_last] = {"landfill", entity.position}
    global.creep_miners_last = global.creep_miners_last + 1
    global.creep_miners_count = global.creep_miners_count + 1
    game.print("Installed creep miner with the name: " .. entity.name .. " located at x:" .. entity.position.x .. " y:" .. entity.position.y)
    game.print("Total amount of installed creep miners: " .. global.creep_miners_count)
end

function creep_eater.remove (entit)
    local r = 0
    for i=1, global.creep_miners_last do
        if global.creep_miners[i]
--        and global.creep_miners[i].entity
--        and global.creep_miners[i].entity.valid
        and (global.creep_miners[i].x == entit.position.x) and (global.creep_miners[i].y == entit.position.y) then
            r = i
            game.print("Value of found r is:" .. r)
            break
        end
    end
    if r>0 then

        local removing = global.creep_miners[r].entity
        game.print("Index number of miner pending for removal is:" .. r)
        game.print("Delete pending creep miner with the name: " .. removing.name .. " located at x:" .. removing.position.x .. " y:" .. removing.position.y)
        if global.locked_creep[r] then global.locked_creep[r] = nil end
        global.creep_miners[r].killed = true
    else
        game.print("WTF?! No creep miner found for destroying!")
        game.print("Total amount of installed creep miners: " .. global.creep_miners_count)
    end

end

function creep_eater.init()
    global.creep_miners = {}
    global.creep_miners_count = 0
    global.creep_miners_last = 1
    global.creep_miners_id = 1
    global.locked_creep = {}
end

return creep_eater