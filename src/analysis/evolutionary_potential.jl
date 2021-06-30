struct EvolutionaryPotentialLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    
    children::Vector{UInt64}
    parent_genotype::Dict{UInt64, Any}
    snapshots::Dict{UInt64, Any}

    function EvolutionaryPotentialLogger(snapshot)
        new(get_organism_ids(snapshot), [], Dict(), Dict())
    end
end

function get_evolutionary_potential(data::CollectedData, num_results::Integer, T::Integer)
    results = []
    
    for snapshot_id in sample_snapshot_ids(data, num_results)
        push!(results, (snapshot_id, get_evolutionary_potential(data, snapshot_id, T)))        
    end

    return results
end

function get_evolutionary_potential(data::CollectedData, snapshot_id::String, T::Integer)
    snapshot = get_snapshot(data, snapshot_id)

    logger = EvolutionaryPotentialLogger(snapshot)
    run_until(snapshot, should_terminate, logger)

    T_similarities = []
    
    for child_id in logger.children
        parent_genotype = logger.parent_genotype[child_id]

        snapshot_with_mutation = deepcopy(logger.snapshots[child_id])
        snapshot_without_mutation = deepcopy(snapshot_with_mutation)
        replace_organism!(snapshot_without_mutation, child_id, parent_genotype)

        T_similarity = get_T_similarity(snapshot_with_mutation, snapshot_without_mutation, T)

        push!(T_similarities, T_similarity)

        println(T_similarity)
    end

    return mean(T_similarities)
end

should_terminate(logger::EvolutionaryPotentialLogger, snapshot) = length(logger.original_organisms_alive) == 0

function log_step(::EvolutionaryPotentialLogger, model) end
function save_log(::EvolutionaryPotentialLogger) end

function log_birth(logger::EvolutionaryPotentialLogger, model, child, parent=nothing)
    child_id = get_id(model, child)
    parent_id = get_id(model, parent)

    child_genotype_id = get_genotype_id(model, child)
    parent_genotype_id = get_genotype_id(model, parent)

    if child_genotype_id == parent_genotype_id return end

    if parent_id in logger.original_organisms_alive
        push!(logger.children, child_id)
        logger.parent_genotype[child_id] = get_genotype(model, parent)
        logger.snapshots[child_id] = deepcopy(model)
    end
end

function log_death(logger::EvolutionaryPotentialLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
    end
end
