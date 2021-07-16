using Serialization

function get_trials()
    unique([String(split(t, "_")[1]) for t in readdir(LOGGER_FOLDER) if isfile(LOGGER_FOLDER * t)])
end

function get_snapshot(snapshot_id)
    for filename in readdir(SNAPSHOTS_FOLDER)
        _, file_snapshot_id = split(filename, "_")
        if file_snapshot_id != snapshot_id continue end

        snapshot = deserialize(SNAPSHOTS_FOLDER * filename)
        return deepcopy(snapshot)
    end
end

function get_snapshot_ids()
    snapshot_ids = []

    for filename in readdir(SNAPSHOTS_FOLDER)
        _, snapshot_id = split(filename, "_")
        push!(snapshot_ids, string(snapshot_id))
    end

    return unique(snapshot_ids)
end

function get_snapshot_ids(trial_id::String)
    snapshot_ids = []

    for filename in readdir(SNAPSHOTS_FOLDER)
        current_trial_id, snapshot_id = split(filename, "_")
        
        if current_trial_id == trial_id
            push!(snapshot_ids, string(snapshot_id))
        end
    end

    return snapshot_ids
end

function save_offspring_log()
    offspring_parents = Dict()

    for trial_id in get_trials()
        @info trial_id
        i = 0
        
        for file in readdir(LOGGER_FOLDER)
            current_trial_id, _ = split(file, "_")
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

        serialize(CALCULATED_FOLDER * "parent_offspring_ocurrances", offspring_parents)
    end
end
