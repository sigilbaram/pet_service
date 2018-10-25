local packets = require('packets')
local server = require('shared.server')
local structs = require('structs')

local data = server.new(structs.struct({
    index           = {structs.entity_index},
    id              = {structs.entity},
    name            = {structs.string(0x10)},
    owner_index     = {structs.entity_index},
    owner_id        = {structs.entity},
    hp              = {structs.uint16},
    hp_max          = {structs.uint16},
    hp_percent      = {structs.uint16},
    mp              = {structs.uint16},
    mp_max          = {structs.uint16},
    mp_percent      = {structs.uint16},
    tp              = {structs.uint32},
    target_id       = {structs.entity},
    active          = {structs.bool}
}))

packets.incoming:register_init({
    [{0x067}] = function(p)
        if p.type == 4 then
            data.index = p.pet_index
            data.id = p.pet_id
            data.owner_index = p.owner_index
            data.hp_percent = p.current_hp_percent
            data.mp_percent = p.current_mp_percent
            data.tp = p.pet_tp
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
        end
    end,
    [{0x044, 0x12}] = function(p)
        data.name = p.pet_name
        data.hp = p.hp
        data.hp_max = p.hp_max
        data.hp_percent = math.floor(100*hp/hp_max)
        data.mp = p.mp
        data.mp_max = p.mp_max
        data.hp_percent = math.floor(100*mp/mp_max)
    end
})
