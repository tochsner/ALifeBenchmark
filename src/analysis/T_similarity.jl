using OptimalTransport: wasserstein
using Distributions: Categorical
using StringDistances: Levenshtein

function get_T_similarity(snapshot_1, snapshot_2, T)
    distribution_1 = get_genotype_distribution(snapshot_1, T)
    distribution_2 = get_genotype_distribution(snapshot_2, T)

    T_similarity = _wasserstein(distribution_1, distribution_2, Levenshtein())

    return T_similarity
end

function get_genotype_distribution(snapshot, T)
    run_n_timesteps!(snapshot, T)
    return get_genotype_distribution(snapshot)        
end