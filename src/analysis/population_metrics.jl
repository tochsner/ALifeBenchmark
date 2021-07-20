function get_genotype_diversity(snapshot, distance_metric, rel_tolerance, min_samples, max_samples)
    all_organisms = get_organisms(snapshot)
    
    genotype_diversity = estimate(rel_tolerance, min_samples, max_samples) do
        sample_organism_1 = rand(all_organisms)
        sample_organism_2 = rand(all_organisms)
        
        sample_genotype_1 = get_genotype(snapshot, sample_organism_1)
        sample_genotype_2 = get_genotype(snapshot, sample_organism_2)

        genotype_distance = distance_metric(sample_genotype_1, sample_genotype_2)

        return genotype_distance
    end

    return genotype_diversity
end

function get_phenotype_diversity(snapshot, rel_tolerance, min_samples, max_samples)
    all_organisms = get_organisms(snapshot)
    
    genotype_diversity = estimate(rel_tolerance, min_samples, max_samples) do
        sample_organism_1 = rand(all_organisms)
        sample_organism_2 = rand(all_organisms)
        
        sample_genotype_1 = get_genotype(snapshot, sample_organism_1)
        sample_genotype_2 = get_genotype(snapshot, sample_organism_2)

        genotype_distance = get_phenotype_similarity(sample_genotype_1, sample_genotype_2, tolerance, min_samples, max_samples)

        return genotype_distance
    end

    return genotype_diversity
end