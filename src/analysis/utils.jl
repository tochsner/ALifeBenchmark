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

function _normalize_distribution!(distribution)
    total = sum(values(distribution))

    for key in keys(distribution)
        distribution[key] /= total
    end
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