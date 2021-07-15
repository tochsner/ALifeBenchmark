import Serialization

mutable struct RunLogger <: Logger
    trial_id
    logged_organisms_alive    
    logged_organisms_dead

    RunLogger(trial_id) = new(string(trial_id), Dict(), Dict())
end

function log_step(logger::RunLogger, model)
    time = get_time(model)
    if time % LOG_FREQUENCY != 0 return end

    snapshot_id = string(time_ns())
    
    current_organisms = get_organisms(model)
    
    for organism in current_organisms
        id = get_id(model, organism)
        
        if haskey(logger.logged_organisms_alive, id)
            logger.logged_organisms_alive[id].snapshot_id = snapshot_id
        end
    end
    
    save_snapshot(model, snapshot_id)
    save_log(logger, snapshot_id)
end

function log_birth(logger::RunLogger, model, child, parents = nothing)    
    time = get_time(model)
    
    if parents === nothing return end
        
    parent_ids = [get_id(model, parent) for parent in parents]        
    parent_genotypes = [get_genotype(model, parent) for parent in parents]        

    abstracted_organism = get_abstracted_organism(model, child, parent_ids, parent_genotypes)
    abstracted_organism.time_birth = time

    logger.logged_organisms_alive[abstracted_organism.id] = abstracted_organism
end

function log_death(logger::RunLogger, model, organism)
    time = get_time(model)
    organism_id = get_id(model, organism)

    if haskey(logger.logged_organisms_alive, organism_id) == false return end

    logged_organism = logger.logged_organisms_alive[organism_id]
    logged_organism.time_death = time

    delete!(logger.logged_organisms_alive, organism_id)
    logger.logged_organisms_dead[organism_id] = logged_organism
end

function save_snapshot(model, snapshot_id)
    logger = get_logger(model)
    path = SNAPSHOTS_FOLDER * logger.trial_id * "_" * string(snapshot_id)

    set_logger!(model, DoNothingLogger())
    Serialization.serialize(path, model)
    set_logger!(model, logger)
end

function save_log(logger::RunLogger, snapshot_id)    
    path = LOGGER_FOLDER * logger.trial_id * "_" * snapshot_id
    Serialization.serialize(path, logger.logged_organisms_dead)
    logger.logged_organisms_dead = Dict()
end
