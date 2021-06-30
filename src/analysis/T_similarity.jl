using OptimalTransport: wasserstein
using Distributions: Categorical
using StringDistances: Levenshtein

function get_T_similarity(snapshot_1, snapshot_2, T, abs_tolerance, min_samples, max_samples)
    distribution_1 = get_genotype_distribution(snapshot_1, T, abs_tolerance, min_samples, max_samples)
    distribution_2 = get_genotype_distribution(snapshot_2, T, abs_tolerance, min_samples, max_samples)

    T_similarity = _wasserstein(distribution_1, distribution_2, Levenshtein())

    return T_similarity
end

function get_genotype_distribution(snapshot, T, abs_tolerance, min_samples, max_samples)
    distribution = Dict()

    distribution = estimate(merge_distribution, _kullback_leibler, Dict([] => 1), abs_tolerance, min_samples, max_samples, print_progress = false) do
        @time resulting_snapshot = run_n_timesteps(snapshot, T)
        
        sample_distribution = get_genotype_distribution(resulting_snapshot)        

        return sample_distribution
    end

    return distribution
end

function get_genotype_distribution(snapshot)
    distribution = Dict()

    for organism in get_organisms(snapshot)
        genotype = get_genotype(snapshot, organism)

        if haskey(distribution, genotype)
            distribution[genotype] += 1
        else
            distribution[genotype] = 1
        end
    end

    _normalize_distribution!(distribution)

    return distribution
end

function merge_distribution(sample_distribution, distribution, num_previous_samples)
    merged_distribution = Dict()

    for (key, value) in distribution
        merged_distribution[key] = value*num_previous_samples /  (num_previous_samples + 1)
    end
   
    for (key, value) in sample_distribution
        if haskey(merged_distribution, key)
            merged_distribution[key] += value / (num_previous_samples + 1)
        else
            merged_distribution[key] = value / (num_previous_samples + 1)
        end
    end

    _normalize_distribution!(merged_distribution)

    return merged_distribution
end

function _normalize_distribution!(distribution)
    total = sum(values(distribution))

    for key in keys(distribution)
        distribution[key] /= total
    end
end

function _kullback_leibler(distribution_1, distribution_2)
    KL = 0
    
    for x in keys(distribution_1)
        p_1 = distribution_1[x]
        
        if haskey(distribution_2, x)
            p_2 = distribution_2[x]
        else
            p_2 = 0
        end

        KL += p_1 * (log(p_1 + EPS) - log(p_2 + EPS))
    end

    return KL
end

function _wasserstein(distribution_1, distribution_2, metric)
    all_genotype_ids = union(keys(distribution_1), keys(distribution_2))
    all_genotype_ids = [id for id in all_genotype_ids]
    
    distribution_1 = Categorical([haskey(distribution_1, id) ? distribution_1[id] : 0 for id in all_genotype_ids])
    distribution_2 = Categorical([haskey(distribution_2, id) ? distribution_2[id] : 0 for id in all_genotype_ids])

    _metric = (x, y) -> metric(all_genotype_ids[x], all_genotype_ids[y])

    wasserstein_distance = wasserstein(distribution_1, distribution_2, metric=_metric)

    return wasserstein_distance
end