local creep_fields = {}

local wm_processed_types = {
    system = 1,
    controller = 2,
    early_bot = 3,
    mid_bot = 4,
   big_bot = 5
}

function creep_fields.create(f_pos)
    storage.wm_cr_fields_meta[f_pos.x .. ":" .. f_pos.y] = {
        size_now = 0,
        bots = {},
        mod_time = 0
    }
    storage.wm_creep_fields[f_pos.x .. ":" .. f_pos.y] = {}
end

function creep_fields.search_creep(f_pos)
    local surface = game.get_surface("nauvis")
    local creep_tiles = {}
    local found_tiles = {}
    storage.wm_cr_fields_meta[f_pos.x .. ":" .. f_pos.y].mod_time = game.tick
    creep_tiles = surface.find_tiles_filtered({
        area = {{8*f_pos.x, 8*f_pos.y}, {(8*f_pos.x)+8, (8*f_pos.y)+8}},
        name = {"fk-creep", "kr-creep"}
    })
    if creep_tiles and creep_tiles[1] then
        for i = 1, #creep_tiles do
             table.insert(found_tiles,{
                x = creep_tiles[i].position.x,
                y = creep_tiles[i].position.y,
                name = creep_tiles[i].name,
                hidden_tile = creep_tiles[i].hidden_tile,
                hunter = nil
            })
        end
        storage.wm_creep_fields[f_pos.x .. ":" .. f_pos.y] = found_tiles
        storage.wm_cr_fields_meta[f_pos.x .. ":" .. f_pos.y].size_now = #creep_tiles
        return true
    else
        return nil
    end
end

function creep_fields.delete(f_pos)
    local crbots = storage.wm_creep_miners
    local field = storage.wm_cr_fields_meta[f_pos.x .. ":" .. f_pos.y]
    storage.wm_creep_fields[f_pos.x .. ":" .. f_pos.y] = nil
    --field.mod_time = game.tick
    for i = 1, #field.bots do
        if crbots[field.bots[i]].field then
            for k = 1, #crbots[field.bots[i]].field do
                if crbots[field.bots[i]].field[k].x == f_pos.x and crbots[field.bots[i]].field[k].y == f_pos.y then
                    table.remove(crbots[field.bots[i]].field, k)
                    break
                end
            end
        end
    end
    field.bots = {}
end

function creep_fields.unlink_fields(r) --bot data existence is pre-checked
    local mbot = storage.wm_creep_miners[r]
    if mbot.field then
        for k = 1, #mbot.field do
            local ff = storage.wm_cr_fields_meta[mbot.field[k].x .. ":" .. mbot.field[k].y]
            if ff and ff.bots then
                for i = 1, #ff.bots do
                    if ff.bots[i] == r then
                        table.remove(ff.bots, i)
                        -- ff.mod_time = e_tick Unlinking is not a trace of the field activity
                        break
                    end
                end
            end
        end
    mbot.field = {}
    end
end

function controller_release_trip(controller, unit_number)
    local trip = controller.active_trips[unit_number]
    if not trip then return end
    for i = 1, #trip.tiles do
        local t = trip.tiles[i]
        local tiles = storage.wm_creep_fields[t.field_key]
        if tiles and tiles[t.oid] then
            local entry = tiles[t.oid]
            if entry.hunter == unit_number then
                entry.hunter = nil
            end
        end
    end
    controller.active_trips[unit_number] = nil
end

function creep_fields.unlock_tiles(r) --bot data existence is pre-checked
    local mbot = storage.wm_creep_miners[r]
    local controller = mbot.controller_id and storage.wm_creep_miners[mbot.controller_id]
    if controller and controller.type == wm_processed_types.controller then
        controller_release_trip(controller, r)
    end
    if mbot.tileOid then
        storage.wm_creep_fields[mbot.field_key][mbot.tileOid].hunter = nil
    end
    --mbot.tileOid = nil
end

return creep_fields