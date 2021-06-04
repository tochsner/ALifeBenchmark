using DataStructures: Deque

mutable struct TierraModel <: ALifeModel
    next_key::UInt64

    organism_keys::Vector{UInt64}
    organisms::Dict{UInt64, TierrianOrganism}

    slice_index::UInt16
    
    memory::Vector{UInt8}
    memory_size::UInt32
    free_blocks::Vector{FreeMemoryBlock}
    used_memory::UInt32

    reaper_queue::Vector{UInt64}

    function TierraModel(ancestor_program::Vector{TierrianInstruction})
        TierraModel(convert_instructions(ancestor_program))
    end

    function TierraModel(ancestor_program::Vector{UInt8})
        @assert 0 < length(ancestor_program) 
        
        memory_size = typemax(UInt16) + 1
        memory = zeros(UInt8, memory_size)
        
        ancestor_length = convert(UInt16, length(ancestor_program))
        ancestor_key = 1
        ancestor = TierrianOrganism(UInt16(0), ancestor_length) 
        ancestor.key = ancestor_key
        ancestor.hash = bytes2hex(sha256(ancestor_program))
        
        memory[1:ancestor_length] = ancestor_program
        remaining_memory_size = convert(UInt32, memory_size - ancestor_length)
        free_block = FreeMemoryBlock(ancestor_length, remaining_memory_size)

        return new(2, [ancestor_key], Dict(ancestor_key => ancestor), UInt16(1), 
                    memory, memory_size, [free_block], ancestor_length, [ancestor_key])
    end
end

function add_organism!(model::TierraModel, program::Vector{TierrianInstruction})
    add_organism!(model, convert_instructions(program))
end

function add_organism!(model::TierraModel, program::Vector{UInt8})
    length = convert(UInt16, Base.length(program))
    start_address = allocate_free_memory!(model, length)

    if start_address == -1
        return
    end

    new_organism = TierrianOrganism(start_address, length)
    
    add_organism!(model, new_organism)

    write_memory(model, new_organism, new_organism.start_address, program)
    set_hash!(new_organism, model)
end

function add_organism!(model::TierraModel, organism::TierrianOrganism)
    key = model.next_key

    organism.key = key
    model.organisms[key] = organism
    push!(model.organism_keys, key)
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
    deleteat!(model.organism_keys, indexin([key], model.organism_keys))

    if remove_from_reaper_queue
        delete!(model.reaper_queue, key)
    end
end

function set_hash!(organism::TierrianOrganism, model::TierraModel)
    program = read_memory(model, organism.start_address, organism.length)
    organism.hash = bytes2hex(sha256(program))
end