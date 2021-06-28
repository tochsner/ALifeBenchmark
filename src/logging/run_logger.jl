import Serialization

mutable struct RunLogger <: Logger
    trial_id
    logged_organisms    

    RunLogger(trial_id) = new(string(trial_id), Dict())
end

function log_step(logger::RunLogger, model)
    if LOG_PROBABILITY < rand() return end

    snapshot_id = string(time_ns())
    create_snapshot(logger, snapshot_id, model)

    current_organisms = get_organisms(model)
    
    for organism in current_organisms
        id = get_id(model, organism)
        logger.logged_organisms[id].snapshot_id = snapshot_id
        save_genotype(model, organism)
    end
end

function save_log(logger::RunLogger)    
    Serialization.serialize(LOGGER_FOLDER * logger.trial_id, logger)
end

function log_birth(logger::RunLogger, model, child, parent=nothing)    
    time = get_time(model)
    
    if parent === nothing
        parent_id = 0
    else
        parent_id = get_id(model, parent)        
    end

    abstracted_organism = get_abstracted_organism(model, child, parent_id)
    abstracted_organism.time_birth = time

    logger.logged_organisms[abstracted_organism.id] = abstracted_organism
end

function log_death(logger::RunLogger, model, organism)
    time = get_time(model)
    organism_id = get_id(model, organism)

    if haskey(logger.logged_organisms, organism_id)
        logger.logged_organisms[organism_id].time_death = time
    end
end

function create_snapshot(logger, snapshot_id, model)
    path = SNAPSHOTS_FOLDER * logger.trial_id * "_" * string(snapshot_id)

    logged_organisms_temp = logger.logged_organisms
    logger.logged_organisms = []

    Serialization.serialize(path, model)

    logger.logged_organisms = logged_organisms_temp
end

function save_genotype(model, organism)
    genotype_id = get_genotype_id(model, organism)
    path = GENOTYPE_FOLDER * string(genotype_id)

    if isfile(path) return end
    
    genotype = get_genotype(model, organism)
    Serialization.serialize(path, genotype)
end
