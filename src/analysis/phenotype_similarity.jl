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
	    snapshots = [get_snapshot(data, sample_snapshot_id(data)) for _ in 1:10]        
	    samples = [get_id(s, rand(get_organisms(s))) for s in snapshots]
        sample_similarities = zeros(10)
        
        @threads for t in 1:10
            sample = samples[t]
            snapshot = snapshots[t]
            sample_similarities[t] = (get_fitness(snapshot, sample, genotype_1) - get_fitness(snapshot, sample, genotype_2))^2            
        end

        return sample_similarities
    end

    data.phenotype_similarities[(genotype_id_1, genotype_id_2)] = PhenotypeSimilarity(similarity, rel_tolerance)

    return similarity
end
