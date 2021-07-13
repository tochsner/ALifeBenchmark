import Statistics
using Base.Threads

function get_phenotype_similarity(data::CollectedData, genotype_id_1::String, genotype_id_2::String, rel_tolerance, min_samples, max_samples)
    genotype_1 = get_genotype(data, genotype_id_1)
    genotype_2 = get_genotype(data, genotype_id_2)

    get_phenotype_similarity(data, genotype_id_1, genotype_id_2, genotype_1, genotype_2, rel_tolerance, min_samples, max_samples)
end

function get_phenotype_similarity(data::CollectedData, genotype_id_1::String, genotype_id_2::String, genotype_1, genotype_2, rel_tolerance, min_samples, max_samples)
    if genotype_id_1 == genotype_id_2 return 0.0 end

    if haskey(data.phenotype_similarities, (genotype_id_1, genotype_id_2)) && 
        data.phenotype_similarities[(genotype_id_1, genotype_id_2)].precision <= rel_tolerance
        
        return data.phenotype_similarities[(genotype_id_1, genotype_id_2)].similarity
    end
 
    if haskey(data.phenotype_similarities, (genotype_id_2, genotype_id_1)) && 
        data.phenotype_similarities[(genotype_id_2, genotype_id_1)].precision <= rel_tolerance
    
        return data.phenotype_similarities[(genotype_id_2, genotype_id_1)].similarity
    end

    similarity = estimate(rel_tolerance, min_samples, max_samples) do
        snapshot_to_test = get_snapshot(data, sample_snapshot_id(data))
        sample_to_test = get_id(snapshot_to_test, rand(get_organisms(snapshot_to_test)))
        
        phenotype_similarity =  (get_fitness(snapshot_to_test, sample_to_test, genotype_1) - get_fitness(snapshot_to_test, sample_to_test, genotype_2))^2

        return phenotype_similarity
    end
    
    data.phenotype_similarities[(genotype_id_1, genotype_id_2)] = PhenotypeSimilarity(similarity, rel_tolerance)

    return similarity
end
