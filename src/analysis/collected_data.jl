using Serialization

struct PhenotypeSimilarity
    similarity::Float64
    precision::Float64
end

struct CollectedData
    logged_organisms::Vector{Organism}
    snapshots::Dict{String, Any}
    genotypes::Dict{String, Any}
    trial_ids::Vector{String}

    phenotype_similarities::Dict{Tuple{String, String}, PhenotypeSimilarity}

    CollectedData() = new([], Dict(), Dict(), [], Dict())
end

function load_collected_data()
    data = CollectedData()

    for trial_id in get_trials()
        push!(data.trial_ids, trial_id)
        add_logged_organisms(data, trial_id)
        println("Loaded ", trial_id, " (Total ", length(data.logged_organisms), " organisms logged)")
    end

    if isfile(CALCULATED_FOLDER * "phenotype_similarites")
        merge!(data.phenotype_similarities, deserialize(CALCULATED_FOLDER * "phenotype_similarites"))
    end

    return data
end

function get_trials()
    [t for t in readdir(LOGGER_FOLDER) if occursin("compact", t) == false]
end

function add_logged_organisms(data::CollectedData, trial_id)
    if isfile(LOGGER_FOLDER * trial_id * "compact")
        logger = deserialize(LOGGER_FOLDER * trial_id * "compact")
    else
        logger = deserialize(LOGGER_FOLDER * trial_id)
        logger.logged_organisms = [o for o in values(logger.logged_organisms) if o.snapshot_id != "-1"]
        serialize(LOGGER_FOLDER * trial_id * "compact", logger)
    end

    append!(data.logged_organisms, logger.logged_organisms)
end

function get_genotype(data::CollectedData, genotype_id)
    if haskey(data.genotypes, genotype_id) 
        return data.genotypes[genotype_id]
    end
        
    genotype = deserialize(GENOTYPE_FOLDER * genotype_id)
    data.genotypes[genotype_id] = genotype

    return genotype
end

function get_snapshot(data::CollectedData, snapshot_id; cache = true)
    if haskey(data.snapshots, snapshot_id)
        return data.snapshots[snapshot_id]
    end

    for trial_id in data.trial_ids
        filename = trial_id * "_" * string(snapshot_id)

        if isfile(SNAPSHOTS_FOLDER * filename)
            snapshot = deserialize(SNAPSHOTS_FOLDER * filename)
            clean_snapshot!(snapshot)

            if cache
                data.snapshots[snapshot_id] = snapshot
            end

            return snapshot
        end
    end
end

function get_snapshot_ids(data::CollectedData)
    snapshot_ids = []

    for filename in readdir(SNAPSHOTS_FOLDER)
        trial_id, snapshot_id = split(filename, "_")
        
        if trial_id in data.trial_ids
            push!(snapshot_ids, string(snapshot_id))
        end
    end

    return snapshot_ids
end

function get_snapshot_ids(data::CollectedData, trial_id::String)
    snapshot_ids = []

    for filename in readdir(SNAPSHOTS_FOLDER)
        current_trial_id, snapshot_id = split(filename, "_")
        
        if current_trial_id == trial_id
            push!(snapshot_ids, string(snapshot_id))
        end
    end

    return snapshot_ids
end

function save_calculated(data::CollectedData)
    serialize(CALCULATED_FOLDER * "phenotype_similarites", data.phenotype_similarities)
end