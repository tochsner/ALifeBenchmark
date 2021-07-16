import Statistics
using Base.Threads

function get_phenotype_similarity(genotype_1, genotype_2, rel_tolerance, min_samples, max_samples)
    if genotype_1 == genotype_2 return 0.0 end

    similarity = estimate(rel_tolerance, min_samples, max_samples) do
        NUM_PARALLEL = 16

	    snapshots = [sample_snapshot_id() |> get_snapshot for _ in 1:NUM_PARALLEL]        
	    samples = [get_id(s, get_organisms(s) |> rand) for s in snapshots]
        sample_similarities = zeros(NUM_PARALLEL)
        
        @threads for t in 1:NUM_PARALLEL
            sample = samples[t]
            snapshot = snapshots[t]
            sample_similarities[t] = (get_fitness(snapshot, sample, genotype_1) - get_fitness(snapshot, sample, genotype_2))^2            
        end

        return sample_similarities
    end

    return similarity
end
