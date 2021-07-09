function allocate_daughter(model::TierraModel, organism::TierrianOrganism)
    if organism.has_daughter
        organism.error_flag = true
        return
    end

    daughter_length = organism.c

    if (daughter_length == 0 || 
        daughter_length < MIN_DAUGHTER_SIZE ||
        organism.length * MAX_DAUGHTER_GROWTH < daughter_length)
        
        organism.error_flag = true
        return
    end

    alloc_start = allocate_free_memory!(model, daughter_length)

    if alloc_start == -1 # no memory found
        organism.error_flag = true
        return
    end

    organism.has_daughter = true
    organism.daughter_address = alloc_start
    organism.daughter_length = daughter_length
    organism.a = alloc_start
end

function divide(model::TierraModel, organism::TierrianOrganism)
    if !organism.has_daughter
        organism.error_flag = true
        return
    end

    daughter = TierrianOrganism(organism.daughter_address, organism.daughter_length)
    new_key = add_organism!(model, daughter)

    if new_key === nothing
        organism.error_flag = true
        organism.has_daughter = false
        return
    end

    daughter.parent_hash = organism.hash
    set_hash!(daughter, model)

    log_birth(model.logger, model, daughter, organism)

    organism.has_daughter = false
    push!(organism.daughters, organism)
end
