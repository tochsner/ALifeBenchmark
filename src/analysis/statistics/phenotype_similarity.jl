import Statistics
using Base.Threads
using Memoize

@memoize function get_phenotype_similarity(genotype_1, genotype_2, rel_tolerance, min_samples, max_samples; test_identical = false)
    if genotype_1 == genotype_2 && test_identical == false return 0.0 end

    similarity = estimate(rel_tolerance, min_samples, max_samples) do
	    snapshot = sample_snapshot_id() |> get_snapshot
        sample = get_organisms(snapshot) |> rand
        sample_id = get_id(snapshot, sample)

        sample_similaritiy = (get_fitness(snapshot, sample_id, genotype_1) - get_fitness(snapshot, sample_id, genotype_2))^2            

        return sample_similaritiy
    end

    return similarity
end
