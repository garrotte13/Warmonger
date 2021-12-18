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
--    local id = global.creep_miners_id
--    if global.creep_miners[id]. then return end
        
--    end
end

function creep_eater.add (entity)
    global.creep_miners_count = global.creep_miners_count + 1
    local n = global.creep_miners_count
    global.creep_miners[n] = {
    stage = 0,
    entity = entity
    }
    local t_area = entity.selection_box
    area.ceil(t_area)
    --game.print("Installed creep miner with the name: " .. entity.name .. " located at top left x:" .. t_area.left_top.x .. " y:" .. t_area.left_top.y .. ", bottom right x:" .. t_area.right_bottom.x .. " y:" .. t_area.right_bottom.y)
    game.print("Installed creep miner with the name: " .. entity.name .. " located at x:" .. entity.position.x .. " y:" .. entity.position.y)

end

function creep_eater.remove (entit)
    local r = 0
    for i=1, global.creep_miners_count do
        if global.creep_miners[i] and (global.creep_miners[i].entity.position.x == entit.position.x) and (global.creep_miners[i].entity.position.y == entit.position.y) then
            r = i
            game.print("Value of found r is:" .. r)
            break
        end
    end
    if r>0 then

        local removing = global.creep_miners[r].entity
        global.creep_miners_count = global.creep_miners_count - 1
--        local t_area = removing.selection_box
--        area.ceil(t_area)
        game.print("Value of deleted r is:" .. r)
        game.print("Removing creep miner with the name: " .. removing.name .. " located at x:" .. removing.position.x .. " y:" .. removing.position.y)
        table.remove(global.creep_miners, r)
    else
        game.print("WTF?! No creep miner found for destroying!")
    end

end

function creep_eater.init()
    global.creep_miners = {}
    global.creep_miners_count = 0
    global.creep_miners_id = 1
end

return creep_eater