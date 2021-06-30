function get_adaption_of_snapshot(data::CollectedData, snapshot_id, test_snapshot_id, rel_tolerance, min_samples, max_samples)
    snapshot = get_snapshot(data, snapshot_id)    
    all_organisms = get_organisms(snapshot)

    adaption_per_genotype = Dict()

    adaption = estimate(rel_tolerance, min_samples, max_samples) do
        organism = rand(all_organisms)
        genotype_id = get_genotype_id(snapshot, organism)

        if haskey(adaption_per_genotype, genotype_id) == false
            genotype_adaption = get_adaption_of_genotype(data, genotype_id, test_snapshot_id, rel_tolerance, min_samples, max_samples)
            adaption_per_genotype[genotype_id] = genotype_adaption 
        end
        
        return adaption_per_genotype[genotype_id]
    end

    return adaption
end

function get_adaption_of_genotype(data::CollectedData, genotype_id, snapshot_id, rel_tolerance, min_samples, max_samples)
    genotype = get_genotype(data, genotype_id)
    snapshot = get_snapshot(data, snapshot_id)
    all_organisms = get_organisms(snapshot)

    adaption = estimate(rel_tolerance, min_samples, max_samples) do
        fitness_of_replaced = 0
        fitness_of_genotype = 0
        
        while fitness_of_replaced == 0
            organism_to_replace = rand(all_organisms)
            id_to_replace = get_id(snapshot, organism_to_replace)
            genotype_to_replace = get_genotype(snapshot, organism_to_replace)  

            fitness_of_genotype = get_fitness(snapshot, id_to_replace, genotype)
            fitness_of_replaced = get_fitness(snapshot, id_to_replace, genotype_to_replace)
        end

        adaption = fitness_of_genotype / fitness_of_replaced

        return adaption
    end

    return adaption
end