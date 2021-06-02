import Base.Threads.@threads

function execute_slice!(model::TierraModel; slice_size = SLICE_SIZE)
    model.slice_index = mod(model.slice_index, length(model.organism_keys)) + 1
    
    organism = model.organisms[model.organism_keys[model.slice_index]]
    
    for _ in 1:slice_size
        _perform_instruction!(model, organism)
    end    

    _run_reaper!(model)
end

function _perform_instruction!(model::TierraModel, organism::TierrianOrganism)
    instruction_address = _address_within(organism, organism.ip)
    organism.ip = _address_within(organism, organism.ip + one(UInt16))

    instruction_int = read_memory(model, instruction_address)
    instruction = convert_instruction(instruction_int)

    apply!(instruction, organism, model)
end

function _run_reaper!(model::TierraModel)
    if MAX_MEMORY_CAPACITY <= model.used_memory / model.memory_size
        while MAX_MEMORY_CAPACITY <= model.used_memory / model.memory_size
            remove_organism!(model, pop!(model.reaper_queue), remove_from_reaper_queue = false)
        end
    end
end
