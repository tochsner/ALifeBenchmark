using Serialization

struct PhenotypeSimilarity
    similarity::Float64
    precision::Float64
end

struct CollectedData
    trial_ids::Vector{String}

    snapshots::Dict{String, Any}
    phenotype_similarities::Dict{Tuple{String, String}, PhenotypeSimilarity}
    
    lock::ReentrantLock

    CollectedData() = new([], [], Dict(), Dict(), ReentrantLock())
end

function load_collected_data()
    data = CollectedData()

    for trial_id in get_trials()
        push!(data.trial_ids, trial_id)
    end

    if isfile(CALCULATED_FOLDER * "phenotype_similarites")
        merge!(data.phenotype_similarities, deserialize(CALCULATED_FOLDER * "phenotype_similarites"))
    end

    return data
end

function get_trials()
    unique([String(split(t, "_")[1]) for t in readdir(LOGGER_FOLDER) if isfile(LOGGER_FOLDER * t)])
end

function get_snapshot(data::CollectedData, snapshot_id)
    lock(data.lock) do
        if haskey(data.snapshots, snapshot_id)
            return deepcopy(data.snapshots[snapshot_id])
        end

        for filename in readdir(SNAPSHOTS_FOLDER)
            _, file_snapshot_id = split(filename, "_")

            if file_snapshot_id != snapshot_id continue end

            snapshot = deserialize(SNAPSHOTS_FOLDER * filename)
            data.snapshots[snapshot_id] = snapshot

            return deepcopy(snapshot)
        end
    end
end

function get_snapshot_ids(data::CollectedData)
    snapshot_ids = []

    for filename in readdir(SNAPSHOTS_FOLDER)
        _, snapshot_id = split(filename, "_")
        push!(snapshot_ids, string(snapshot_id))
    end

    return snapshot_ids
end

function get_snapshot_ids(_::CollectedData, trial_id::String)
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

function save_offspring_log(data::CollectedData)
    offspring_parents = Dict()

    for trial_id in data.trial_ids
        @info trial_id
        i = 0 
        
        for file in readdir(LOGGER_FOLDER)
            current_trial_id = split(file, "_")[1]
            if current_trial_id != trial_id continue end
    
            logged_organisms = deserialize(LOGGER_FOLDER * file)
            
            for (_, organism) in logged_organisms
                for parent_genotype in organism.parent_genotypes
                    key = (parent_genotype, organism.genotype)

                    if haskey(offspring_parents, key)
                        offspring_parents[key] += 1
                    else
                        offspring_parents[key] = 1
                    end
                end
            end

            i += 1

            @info "$i \t $file"
        end

        serialize(CALCULATED_FOLDER * "offspring_parents", offspring_parents)
    end
end
