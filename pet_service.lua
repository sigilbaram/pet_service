local math = require('math')
local packets = require('packets')
local server = require('shared.server')
local string = require('string')
local structs = require('structs')

local data = server.new(structs.struct({
    index           = {structs.uint16},
    id              = {structs.uint32},
    name            = {structs.string(0x10)},
    owner_index     = {structs.uint16},
    owner_id        = {structs.uint32},
    hp_percent      = {structs.uint16},
    mp_percent      = {structs.uint16},
    tp              = {structs.uint32},
    target_id       = {structs.uint32},
    active          = {structs.bool},
    automaton       = {structs.struct({
        head                = {structs.uint16},
        frame               = {structs.uint16},
        attachments         = {structs.uint16[0x0C]},
        available_heads     = {structs.bool[32]},
        available_frames    = {structs.bool[32]},
        available_attach    = {structs.bool[256]},
        name                = {structs.string(0x10)},
        hp                  = {structs.uint16},
        hp_max              = {structs.uint16},
        mp                  = {structs.uint16},
        mp_max              = {structs.uint16},
        melee               = {structs.uint16},
        melee_max           = {structs.uint16},
        ranged              = {structs.uint16},
        ranged_max          = {structs.uint16},
        magic               = {structs.uint16},
        magic_max           = {structs.uint16},
        str                 = {structs.uint16},
        str_max             = {structs.uint16},
        dex                 = {structs.uint16},
        dex_max             = {structs.uint16},
        vit                 = {structs.uint16},
        vit_max             = {structs.uint16},
        agi                 = {structs.uint16},
        agi_max             = {structs.uint16},
        int                 = {structs.uint16},
        int_max             = {structs.uint16},
        mnd                 = {structs.uint16},
        mnd_max             = {structs.uint16},
        chr                 = {structs.uint16},
        chr_max             = {structs.uint16}
    })}
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
        data.automaton.head             = p.automaton_head
        data.automaton.frame            = p.automaton_frame
        for i=0,11 do
            data.automaton.attachments[i] = p.attachments[i]
        end
        for i=0,3 do
            data.automaton.available_heads[i]  = p.available_heads:byte(i+1)
        end
        for i=0,3 do
            data.automaton.available_frames[i] = p.available_bodies:byte(i+1)
        end
        for i=0,31 do
            data.automaton.available_attach[i] = p.available_attach:byte(i+1)
        end
        data.automaton.hp               = p.hp
        data.automaton.hp_max           = p.hp_max
        data.automaton.mp               = p.mp
        data.automaton.mp_max           = p.mp_max
        data.automaton.melee            = p.melee
        data.automaton.melee_max        = p.melee_max
        data.automaton.ranged           = p.ranged
        data.automaton.ranged_max       = p.ranged_max
        data.automaton.magic            = p.magic
        data.automaton.magic_max        = p.magic_max
        data.automaton.str              = p.str
        data.automaton.str_max          = p.str_max
        data.automaton.dex              = p.dex
        data.automaton.dex_max          = p.dex_max
        data.automaton.vit              = p.vit
        data.automaton.vit_max          = p.vit_max
        data.automaton.agi              = p.agi
        data.automaton.agi_max          = p.agi_max
        data.automaton.int              = p.int
        data.automaton.int_max          = p.int_max
        data.automaton.mnd              = p.mnd
        data.automaton.mnd_max          = p.mnd_max
        data.automaton.chr              = p.chr
        data.automaton.chr_max          = p.chr_max

        if p.pet_name and p.pet_name ~= '' then
            data.name = p.pet_name
        end
        if p.hp_max ~= 0 then
            data.hp_percent = math.floor(100 * p.hp / p.hp_max)
        end
        if p.mp_max ~= 0 then
            data.mp_percent = math.floor(100 * p.mp / p.mp_max)
        end
    end
})
