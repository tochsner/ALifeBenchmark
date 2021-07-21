struct EvolutionaryPotentialLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    
    children::Vector{UInt64}
    parent_genotype::Dict{UInt64, Any}
    snapshots::Dict{UInt64, Any}

    function EvolutionaryPotentialLogger(snapshot)
        new(get_organism_ids(snapshot), [], Dict(), Dict())
    end
end

function get_evolutionary_potential(snapshot, T::Integer, rel_tolerance, min_samples, max_samples)
    T_similarity = estimate(rel_tolerance, min_samples, max_samples) do
        logger = EvolutionaryPotentialLogger(snapshot)
        simulate_snapshot!(should_terminate, snapshot, logger)
        
        while length(logger.children) == 0
            logger = EvolutionaryPotentialLogger(snapshot)
            simulate_snapshot!(should_terminate, snapshot, logger)
        end

        T_similarities = []
    
        for child_id in logger.children
            parent_genotype = logger.parent_genotype[child_id]
    
            snapshot_with_mutation = deepcopy(logger.snapshots[child_id])
            snapshot_without_mutation = deepcopy(snapshot_with_mutation)
            replace_organism!(snapshot_without_mutation, child_id, parent_genotype)

            T_similarity = get_T_similarity(snapshot_with_mutation, snapshot_without_mutation, T)
    
            push!(T_similarities, T_similarity)
        end

        return T_similarities
    end

    return T_similarity
end

should_terminate(logger::EvolutionaryPotentialLogger, snapshot) = length(logger.original_organisms_alive) == 0

function log_step(::EvolutionaryPotentialLogger, model) end
function save_log(::EvolutionaryPotentialLogger) end

function log_birth(logger::EvolutionaryPotentialLogger, model, child, parents=nothing)
    if parents === nothing return end

    parent = rand(parents)

    child_id = get_id(model, child)
    parent_id = get_id(model, parent)

    child_genotype = get_genotype(model, child)
    parent_genotype = get_genotype(model, parent)

    if child_genotype == parent_genotype return end

    if parent_id in logger.original_organisms_alive
        push!(logger.children, child_id)
        logger.parent_genotype[child_id] = parent_genotype
        logger.snapshots[child_id] = deepcopy(model)
    end
end

function log_death(logger::EvolutionaryPotentialLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
    end
end
