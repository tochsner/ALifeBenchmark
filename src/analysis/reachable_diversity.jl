using Statistics: mean

struct ReachableDiversityLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    child_genotypes::Vector{Tuple}

    function ReachableDiversityLogger(snapshot)
        new(get_organism_ids(snapshot), [])
    end
end

function get_reachable_diversity(data::CollectedData, num_results::Integer, rel_tolerance, min_samples, max_samples)
    results = []
    
    for snapshot_id in sample_snapshot_ids(data, num_results)
        push!(results, (snapshot_id, get_reachable_diversity(data, snapshot_id, rel_tolerance, min_samples, max_samples)))
        save_calculated(data)
    end

    return results
end

function get_reachable_diversity(data::CollectedData, snapshot_id::String, rel_tolerance, min_samples, max_samples)
    snapshot = get_snapshot(data, snapshot_id)

    reachable_diversity = estimate(rel_tolerance, min_samples, max_samples, print_progress = true) do
        logger = ReachableDiversityLogger(snapshot)
        run_until(snapshot, should_terminate, logger)
        
        while length(logger.child_genotypes) < 2
            logger = ReachableDiversityLogger(snapshot)
            run_until(snapshot, should_terminate, logger)
        end

        println(length(logger.child_genotypes))
        
        sum_phenotype_similarities = 0
        num_samples_per_run = 10

        for _ in 1:num_samples_per_run
            (genotype_1_id, genotype_1) = rand(logger.child_genotypes)
            (genotype_2_id, genotype_2) = rand(logger.child_genotypes)

            sum_phenotype_similarities += get_phenotype_similarity(data, genotype_1_id, genotype_2_id, genotype_1, genotype_2, rel_tolerance = 0.01)
        end

        return sum_phenotype_similarities / num_samples_per_run
    end

    return reachable_diversity
end

should_terminate(logger::ReachableDiversityLogger, snapshot) = length(logger.original_organisms_alive) == 0

function log_step(::ReachableDiversityLogger, model) end
function save_log(::ReachableDiversityLogger) end

function log_birth(logger::ReachableDiversityLogger, model, child, parent=nothing)
    child_genotype_id = get_genotype_id(model, child)
    parent_genotype_id = get_genotype_id(model, parent)

    if child_genotype_id != parent_genotype_id
        push!(logger.child_genotypes, (get_genotype_id(model, child), get_genotype(model, child)))
    end
end

function log_death(logger::ReachableDiversityLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
    end
end
