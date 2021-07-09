using Statistics: mean

struct ReachableFitnessLogger <: Logger
    original_organisms_alive::Vector{UInt64}
    direct_children_alive::Vector{UInt64}
    direct_grandchildren_alive::Vector{UInt64}
    
    parents::Dict
    children::Vector

    function ReachableFitnessLogger(snapshot)
        new(get_organism_ids(snapshot), [], [], Dict(), [])
    end
end

function get_reachable_fitness(data::CollectedData, num_results::Integer, rel_tolerance, min_samples, max_samples)
    results = []
    
    for snapshot_id in sample_snapshot_ids(data, num_results)
        push!(results, (snapshot_id, get_reachable_fitness(data, snapshot_id, rel_tolerance, min_samples, max_samples)))        
    end

    return results
end

function get_reachable_fitness(data::CollectedData, snapshot_id::String, rel_tolerance, min_samples, max_samples)
    snapshot = get_snapshot(data, snapshot_id)

    reachable_fitness = estimate(rel_tolerance, min_samples, max_samples) do
        is_beneficial = []
        
        while true
            logger = ReachableFitnessLogger(snapshot)
            simulate_snapshot!(should_terminate, snapshot, logger)
            
            if length(logger.children) == 0 continue end

            is_beneficial = []        

            for child in logger.children
                parent = logger.parents[child]
                
                fitness_child = get_fitness(snapshot, child)
                fitness_parent = get_fitness(snapshot, parent)
                
                push!(is_beneficial, fitness_parent < fitness_child ? 1 : 0)
            end

            if length(is_beneficial) == 0 continue end
            break
        end

        if 5 < length(is_beneficial)
            return rand(is_beneficial, 5)
        else
            return is_beneficial
        end
    end

    return reachable_fitness
end

function should_terminate(logger::ReachableFitnessLogger, snapshot)    
    isempty(logger.original_organisms_alive) && 
    isempty(logger.direct_children_alive) && 
    isempty(logger.direct_grandchildren_alive)
end

function log_step(::ReachableFitnessLogger, model) end
function save_log(::ReachableFitnessLogger) end

function log_birth(logger::ReachableFitnessLogger, model, child, parent=nothing)
    child_genotype = get_genotype_id(model, child)
    parent_genotype = get_genotype_id(model, parent)

    if child_genotype == parent_genotype return end

    child_id = get_id(model, child)
    parent_id = get_id(model, parent)

    if parent_id in logger.original_organisms_alive
        push!(logger.direct_children_alive, child_id)
        push!(logger.children, child)
        logger.parents[child] = parent
    elseif parent_id in logger.direct_children_alive
        push!(logger.direct_grandchildren_alive, child_id)
    end
end

function log_death(logger::ReachableFitnessLogger, model, organism)
    id = get_id(model, organism)

    if id in logger.original_organisms_alive
        delete!(logger.original_organisms_alive, id)
    elseif id in logger.direct_children_alive
        delete!(logger.direct_children_alive, id)
    elseif id in logger.direct_grandchildren_alive
        delete!(logger.direct_grandchildren_alive, id)
    end
end
