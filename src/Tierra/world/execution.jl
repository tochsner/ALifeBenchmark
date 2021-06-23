import Base.Threads.@threads

function execute_slice!(model::TierraModel; slice_size = SLICE_SIZE)
    model.slice_index = mod(model.slice_index, length(model.organism_keys)) + 1

    organism = model.organisms[model.organism_keys[model.slice_index]]

    for _ in 1:slice_size
        _perform_instruction!(model, organism)
    end

    _run_reaper!(model)
    if MUTATE
        _apply_cosmic_rays!(model)
    end
end

function _perform_instruction!(model::TierraModel, organism::TierrianOrganism)
    model.time += 1

    instruction_address = _address_within(organism, organism.ip)
    organism.ip = _address_within(organism, organism.ip + one(UInt16))

    instruction_int = read_memory(model, instruction_address)
    instruction = convert_instruction(instruction_int)

    apply!(instruction, organism, model)

    if organism.error_flag # push organism forward in reaper queue
        reaper_queue_index = first(indexin([organism.key], model.reaper_queue))

        if  1 < reaper_queue_index
            model.reaper_queue[reaper_queue_index - 1], model.reaper_queue[reaper_queue_index] =
                model.reaper_queue[reaper_queue_index], model.reaper_queue[reaper_queue_index - 1]
        end

        organism.error_flag = false
    end
end

function _run_reaper!(model::TierraModel)
    if MAX_MEMORY_CAPACITY <= model.used_memory / model.memory_size
        while MAX_MEMORY_CAPACITY <= model.used_memory / model.memory_size
            remove_organism!(model, popfirst!(model.reaper_queue), remove_from_reaper_queue = false)
        end
    end
end

function _apply_cosmic_rays!(model::TierraModel)
    if rand() < COSMIC_RAYS_PROBABILITY * model.memory_size
        index_to_change = rand(1:model.memory_size)
        model.memory[index_to_change] = get_mutated_instruction(model.memory[index_to_change])
    end
end
