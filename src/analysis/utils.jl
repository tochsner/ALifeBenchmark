function get_genotype_distribution(snapshot)
    get_distribution([get_genotype(snapshot, organism) for organism in get_organisms(snapshot)])
end

function get_distribution(values)
    distribution = Dict()

    for value in values
        if haskey(distribution, value)
            distribution[value] += 1
        else
            distribution[value] = 1
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
    all_genotypes = union(keys(distribution_1), keys(distribution_2))
    all_genotypes = [id for id in all_genotypes]
    
    distribution_1 = Categorical([haskey(distribution_1, id) ? distribution_1[id] : 0 for id in all_genotypes])
    distribution_2 = Categorical([haskey(distribution_2, id) ? distribution_2[id] : 0 for id in all_genotypes])

    _metric = (x, y) -> metric(all_genotypes[x], all_genotypes[y])

    wasserstein_distance = wasserstein(distribution_1, distribution_2, metric=_metric)

    return wasserstein_distance
end

function weighted_rand(sequence, weights::Vector{Float64})
    sequence[findfirst(cumsum(weights) .> rand())]
end
