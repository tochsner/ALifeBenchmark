struct ReachableDiversityLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    child_genotypes::Vector{Tuple}

    function ReachableDiversityLogger(snapshot)
        new(get_organism_ids(snapshot), [])
    end
end

function get_reachable_diversity(data::CollectedData, num_results::Integer, rel_tolerance = 0.005)
    results = []
    
    for snapshot_id in sample_snapshot_ids(data, num_results)
        push!(results, (snapshot_id, get_reachable_diversity(data, snapshot_id, rel_tolerance)))
        save_calculated(data)
    end

    return results
end

function get_reachable_diversity(data::CollectedData, snapshot_id::String, rel_tolerance = 0.005)
    children = collect_child_genotypes(data, snapshot_id)
    return get_reachable_diversity(data, children, rel_tolerance)
end

function get_reachable_diversity(data::CollectedData, children::Vector, rel_tolerance = 0.005, min_samples = 1, max_samples = 500)
    num_children = length(children)

    index_pairs = [(i, j) for i in 1:num_children for j in 1:num_children]
    shuffle!(index_pairs)

    reachable_diversity = 0
    num_samples = 0
    rel_change = 2*rel_tolerance

    for (index_1, index_2) in index_pairs
        if (min_samples <= num_samples && rel_change < rel_tolerance) || max_samples <= num_samples
            break
        end

        genotype_1_id, genotype_1 = children[index_1]
        genotype_2_id, genotype_2 = children[index_2]
        
        if genotype_1_id == genotype_2_id
            continue
        end

        old_diversity = reachable_diversity
        phenotype_similarity = get_phenotype_similarity(data, genotype_1_id, genotype_2_id, genotype_1, genotype_2, rel_tolerance = 0.01)
        reachable_diversity = (reachable_diversity*num_samples + phenotype_similarity) / (num_samples + 1)

        rel_change = abs(old_diversity - reachable_diversity) / max(EPS, old_diversity)
        num_samples += 1

        println(num_samples, " ", rel_change, " ", reachable_diversity)
    end

    return reachable_diversity
end

function collect_child_genotypes(data::CollectedData, snapshot_id)
    snapshot = get_snapshot(data, snapshot_id)

    logger = ReachableDiversityLogger(snapshot)
    run_until(snapshot, should_terminate, logger)
    
    return logger.child_genotypes
end

should_terminate(logger::ReachableDiversityLogger, snapshot) = length(logger.original_organisms_alive) == 0

function log_step(::ReachableDiversityLogger, model) end
function save_log(::ReachableDiversityLogger) end

function log_birth(logger::ReachableDiversityLogger, model, child, parent=nothing)
    push!(logger.child_genotypes, (get_genotype_id(model, child), get_genotype(model, child)))
end

function log_death(logger::ReachableDiversityLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
    end
end
