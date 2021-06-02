using DataStructures: Deque

mutable struct TierraModel <: ALifeModel
    next_key::UInt64

    organism_keys::Vector{UInt64}
    organisms::Dict{UInt64, TierrianOrganism}

    slice_index::UInt16
    
    memory::Array{UInt8}
    memory_size::UInt32
    free_blocks::Vector{FreeMemoryBlock}
    used_memory::UInt32

    reaper_queue::Deque{UInt64}

    function TierraModel(ancestor_program::Vector{TierrianInstruction})
        TierraModel(convert_instructions(ancestor_program))
    end

    function TierraModel(ancestor_program::Vector{UInt8})
        @assert 0 < length(ancestor_program) 

        ancestor_length = convert(UInt16, length(ancestor_program))
        ancestor = TierrianOrganism(UInt16(0), ancestor_length)        

        memory_size = typemax(UInt16) + 1
        memory = zeros(UInt8, memory_size)

        memory[1:ancestor_length] = ancestor_program

        remaining_memory_size = convert(UInt32, memory_size - ancestor_length)
        free_block = FreeMemoryBlock(ancestor_length, remaining_memory_size)

        reaper_queue = Deque{UInt64}()
        push!(reaper_queue, 1)

        return new(2, [1], Dict(1 => ancestor), UInt16(1), memory, memory_size, [free_block], ancestor_length, reaper_queue)
    end
end

function add_organism!(model::TierraModel, organism::TierrianOrganism)
    key = model.next_key

    model.organisms[key] = organism
    pushfirst!(model.organism_keys, key)
    push!(model.reaper_queue, key)

    model.next_key += 1
end

function remove_organism!(model::TierraModel, key; remove_from_reaper_queue = true)
    organism_to_be_removed = model.organisms[key]
    
    clear_memory!(model, organism_to_be_removed.start_address, organism_to_be_removed.length)
    if organism_to_be_removed.has_daughter
        clear_memory!(model, organism_to_be_removed.daughter_address, organism_to_be_removed.daughter_length)
    end
    
    delete!(model.organisms, key)
    deleteat!(model.organism_keys, findall(x -> x == key, model.organism_keys))

    if remove_from_reaper_queue
        delete!(model.reaper_queue, key)
    end
end