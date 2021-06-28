struct ReachableFitnessLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    direct_children_alive::Vector{UInt64}
    
    children::Vector{UInt64}
    parent_of::Dict{UInt64, UInt64}
    fitness::Dict{UInt64, Float64}

    function ReachableFitnessLogger(snapshot)
        new(get_organism_ids(snapshot), [], [], Dict(), Dict())
    end
end

function get_reachable_fitness(data::CollectedData, num_results::Integer)
    results = []
    
    for snapshot_id in sample_snapshot_ids(data, num_results)
        push!(results, (snapshot_id, get_reachable_fitness(data, snapshot_id)))        
    end

    return results
end

function get_reachable_fitness(data::CollectedData, snapshot_id::String)
    snapshot = get_snapshot(data, snapshot_id)

    logger = ReachableFitnessLogger(snapshot)
    run_until(snapshot, should_terminate, logger)
    
    num_beneficial = 0

    for child in logger.children
        parent = logger.parent_of[child]
        
        fitness_child = logger.fitness[child]
        fitness_parent = logger.fitness[parent]

        if fitness_parent < fitness_child
            num_beneficial += 1
        end        
    end

    println(get_time(snapshot), " ", num_beneficial / length(logger.children))

    return num_beneficial / length(logger.children)
end


function should_terminate(logger::ReachableFitnessLogger, snapshot) 
    length(logger.original_organisms_alive) + length(logger.direct_children_alive) == 0
end

function log_step(::ReachableFitnessLogger, model) end
function save_log(::ReachableFitnessLogger) end

function log_birth(logger::ReachableFitnessLogger, model, child, parent=nothing)
    child_id = get_id(model, child)
    parent_id = get_id(model, parent)

    if parent_id in logger.original_organisms_alive
        push!(logger.direct_children_alive, child_id)
        push!(logger.children, child_id)
        logger.parent_of[child_id] = parent_id
    end
end

function log_death(logger::ReachableFitnessLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
        logger.fitness[id] = get_fitness(model, organism)
    elseif id in logger.direct_children_alive
        delete!(logger.direct_children_alive, id)
        logger.fitness[id] = get_fitness(model, organism)
    end
end
