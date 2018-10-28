local packets = require('packets')
local server = require('shared.server')
local structs = require('structs')
local math = require('math')

local data = server.new(structs.struct({
    index           = {structs.uint16},
    id              = {structs.uint32},
    name            = {structs.string(0x10)},
    owner_index     = {structs.uint16},
    owner_id        = {structs.uint32},
    hp              = {structs.uint16},
    hp_max          = {structs.uint16},
    hp_percent      = {structs.uint16},
    mp              = {structs.uint16},
    mp_max          = {structs.uint16},
    mp_percent      = {structs.uint16},
    tp              = {structs.uint32},
    target_id       = {structs.uint32},
    active          = {structs.bool}
}))

packets.incoming:register_init({
    [{0x037}] = function(p) -- While this packet is mostly player data, it does occassionally update the pet index when no other pet related packet is sent. For example, when moving into zones where the pet is supressed, such as cities and towns, this packet will set the pet index to 0.
        data.index = p.pet_index
        if p.pet_index and p.pet_index ~= 0 then
            data.active = true
        else
            data.active = false
        end
    end,
    [{0x067}] = function(p)
        if p.type == 4 then
            data.index = p.pet_index
            data.id = p.pet_id
            data.owner_index = p.owner_index
            data.hp_percent = p.current_hp_percent
            data.mp_percent = p.current_mp_percent
            data.tp = p.pet_tp
            if p.pet_index and p.pet_index ~= 0 then
                data.active = true
            else
                data.active = false
            end
        end
    end,
    [{0x068}] = function(p)
        if p.type == 4 then
            data.owner_index = p.owner_index
            data.owner_id = p.owner_id
            data.index = p.pet_index
            data.hp_percent = p.current_hp_percent
            data.mp_percent = p.current_mp_percent
            data.tp = p.pet_tp
            data.target_id = p.target_id
            data.name = p.pet_name
            if p.pet_index and p.pet_index ~= 0 then
                data.active = true
            else
                data.active = false
            end
        end
    end,
    [{0x044,0x12}] = function(p)
        if p.pet_name and p.pet_name ~= '' then
            data.name = p.pet_name
        end
        if p.hp_max ~= 0 then
            data.hp = p.hp
            data.hp_max = p.hp_max
            data.hp_percent = math.floor(100 * p.hp / p.hp_max)
        end
        if p.mp_max ~= 0 then
            data.mp = p.mp
            data.mp_max = p.mp_max
            data.mp_percent = math.floor(100 * p.mp / p.mp_max)
        end
    end
})
