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

function get_neutrality(snapshot, epsilon, phenotype_cache)
    genotype_distribution = get_genotype_distribution(snapshot)

    total_eps_neutrality = 0
    total_weights = 0

    for genotype_1 in keys(genotype_distribution)
        for genotype_2 in keys(genotype_distribution)
            weight = genotype_distribution[genotype_1] * genotype_distribution[genotype_2]

            if genotype_1 == genotype_2
                total_eps_neutrality += 0
                total_weights += weight

            elseif haskey(phenotype_cache, (genotype_1, genotype_2))
                if phenotype_cache[(genotype_1, genotype_2)] >= epsilon
                    total_eps_neutrality += 0
                else
                    total_eps_neutrality += weight * Levenshtein()(genotype_1, genotype_2)
                end
                total_weights += weight
            end
        end
    end
    
    population_neutrality = total_eps_neutrality / total_weights

    return population_neutrality
end


function get_neutrality_null_model(snapshot, epsilon, phenotype_cache)
    genotype_distribution = get_genotype_distribution(snapshot)

    total_eps_neutrality = 0
    total_weights = 0

    phenotype_similarities = []

    for genotype_1 in keys(genotype_distribution)
        for genotype_2 in keys(genotype_distribution)
            if genotype_1 != genotype_2 && haskey(phenotype_cache, (genotype_1, genotype_2))
                push!(phenotype_similarities, phenotype_cache[(genotype_1, genotype_2)])
            end
        end
    end

    for genotype_1 in keys(genotype_distribution)
        for genotype_2 in keys(genotype_distribution)
            weight = genotype_distribution[genotype_1] * genotype_distribution[genotype_2]

            if genotype_1 == genotype_2
                total_eps_neutrality += 0
                total_weights += weight

            elseif haskey(phenotype_cache, (genotype_1, genotype_2))
                if rand(phenotype_similarities) >= epsilon
                    total_eps_neutrality += 0
                else
                    total_eps_neutrality += weight * Levenshtein()(genotype_1, genotype_2)
                end
                total_weights += weight
            end
        end
    end
    
    population_neutrality = total_eps_neutrality / total_weights

    return population_neutrality
end