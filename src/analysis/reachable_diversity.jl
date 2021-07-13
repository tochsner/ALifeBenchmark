using Statistics: mean

struct ReachableDiversityLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    child_genotypes::Vector{Tuple}

    function ReachableDiversityLogger(snapshot)
        new(get_organism_ids(snapshot), [])
    end
end

function get_reachable_diversity(data::CollectedData, snapshot_id::String, rel_tolerance, min_samples, max_samples)
    snapshot = get_snapshot(data, snapshot_id)

    reachable_diversity = estimate(rel_tolerance, min_samples, max_samples, print_progress = true) do
        logger = ReachableDiversityLogger(snapshot)
        simulate_snapshot!(should_terminate, snapshot, logger)
        
        while length(logger.child_genotypes) < 2
            logger = ReachableDiversityLogger(snapshot)
            simulate_snapshot!(should_terminate, snapshot, logger)
        end
        
        phenotype_similarities = []
        num_samples_per_run = 2
        
        for _ in 1:num_samples_per_run
            (_, genotype_1) = rand(logger.child_genotypes)
            (_, genotype_2) = rand(logger.child_genotypes)
            
            snapshot_to_test = get_snapshot(data, sample_snapshot_id(data))
            sample_to_test = get_id(snapshot_to_test, rand(get_organisms(snapshot_to_test)))
            
            phenotype_similarity = (get_fitness(snapshot_to_test, sample_to_test, genotype_1) - get_fitness(snapshot_to_test, sample_to_test, genotype_2))^2            
            
            push!(phenotype_similarities, phenotype_similarity)
        end

        return phenotype_similarities
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
