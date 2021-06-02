function allocate_daughter(model::TierraModel, organism::TierrianOrganism)
    if organism.has_daughter
        organism.error_flag = true
        return
    end

    daughter_length = organism.c
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
    add_organism!(model, daughter)

    organism.has_daughter = false
end
