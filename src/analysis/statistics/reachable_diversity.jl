using Statistics: mean

struct ReachableDiversityLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    child_genotypes::Vector

    function ReachableDiversityLogger(snapshot)
        new(get_organism_ids(snapshot), [])
    end
end

function get_reachable_diversity(snapshot, rel_tolerance, min_samples, max_samples)
    reachable_diversity = estimate(rel_tolerance, min_samples, max_samples) do
        logger = ReachableDiversityLogger(snapshot)
        simulate_snapshot!(should_terminate, snapshot, logger)
        
        while length(logger.child_genotypes) < 2
            logger = ReachableDiversityLogger(snapshot)
            simulate_snapshot!(should_terminate, snapshot, logger)
        end
        
        phenotype_similarities = []
        num_samples_per_run = 5
        
        for _ in 1:num_samples_per_run
            genotype_1 = rand(logger.child_genotypes)
            genotype_2 = rand(logger.child_genotypes)
            
            snapshot_to_test = sample_snapshot_id() |> get_snapshot
            sample_id_to_replace = get_id(snapshot_to_test, get_organisms(snapshot_to_test) |> rand)
            
            phenotype_similarity = (get_fitness(snapshot_to_test, sample_id_to_replace, genotype_1) - get_fitness(snapshot_to_test, sample_id_to_replace, genotype_2))^2            
            
            push!(phenotype_similarities, phenotype_similarity)
        end

        return phenotype_similarities
    end

    return reachable_diversity
end

should_terminate(logger::ReachableDiversityLogger, snapshot) = length(logger.original_organisms_alive) == 0

function log_step(::ReachableDiversityLogger, model) end
function save_log(::ReachableDiversityLogger) end

function log_birth(logger::ReachableDiversityLogger, model, child, parents=nothing)
    if parents === nothing return end

    child_genotype = get_genotype(model, child)
    parent_genotype = get_genotype(model, rand(parents))

    if child_genotype == parent_genotype return end

    push!(logger.child_genotypes, child_genotype)
end

function log_death(logger::ReachableDiversityLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
    end
end
