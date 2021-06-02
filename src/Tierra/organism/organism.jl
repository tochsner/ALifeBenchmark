using DataStructures: CircularBuffer

mutable struct TierrianOrganism
    a::UInt16
    b::UInt16
    c::UInt16
    d::UInt16
    
    stack::CircularBuffer{UInt16}

    ip::UInt16

    error_flag::Bool

    start_address::UInt16
    length::UInt16

    has_daughter::Bool
    daughter_address::UInt16
    daughter_length::UInt16

    function TierrianOrganism(start_address::UInt16, length::UInt16)
        new(0, 0, 0, 0, CircularBuffer{UInt16}(10), start_address, false, start_address, length, false, 0, 0)
    end
end

function _address_within(organism, address) 
    mod(address - organism.start_address, organism.length) + organism.start_address
end