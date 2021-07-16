function get_adaption_of_snapshot(snapshot, reference_snapshot, rel_tolerance, min_samples, max_samples)
    all_organisms = get_organisms(snapshot)
    all_reference_organisms = get_organisms(reference_snapshot)

    adaption = estimate(rel_tolerance, min_samples, max_samples) do
        while true
            organism = rand(all_organisms)
            reference_organism = rand(all_reference_organisms)
            reference_id = get_id(reference_snapshot, reference_organism)

            genotype = get_genotype(snapshot, organism)
            reference_genotype = get_genotype(reference_snapshot, reference_organism)
            
            reference_fitness = get_fitness(reference_snapshot, reference_id, reference_genotype)
            fitness = get_fitness(reference_snapshot, reference_id, genotype)

            if reference_fitness == 0 continue end

            return fitness / reference_fitness
        end
    end

    return adaption
end