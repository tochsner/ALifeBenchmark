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
    
    lock::ReentrantLock

    CollectedData() = new([], Dict(), Dict(), [], Dict(), ReentrantLock())
end

function load_collected_data(; load_logged_organisms = true)
    data = CollectedData()

    for trial_id in get_trials()
        push!(data.trial_ids, trial_id)

        if load_logged_organisms
            add_logged_organisms(data, trial_id)
        end

        println("Loaded ", trial_id, " (Total ", length(data.logged_organisms), " organisms logged)")
    end

    if isfile(CALCULATED_FOLDER * "phenotype_similarites")
        merge!(data.phenotype_similarities, deserialize(CALCULATED_FOLDER * "phenotype_similarites"))
    end

    return data
end

function get_trials()
    unique([String(split(t, "_")[1]) for t in readdir(LOGGER_FOLDER) if occursin("compact", t) == false && isfile(LOGGER_FOLDER * t)])
end

function add_logged_organisms(data::CollectedData, trial_id)
    if isfile(LOGGER_FOLDER * trial_id * "compact")
        logged_organisms = deserialize(LOGGER_FOLDER * trial_id * "compact")
        append!(data.logged_organisms, [l for l in logged_organisms if l.snapshot_id != "-1"])
    else
        logged_organisms = []

        for file in readdir(LOGGER_FOLDER)
            if isfile(LOGGER_FOLDER * file) == false continue end
            if occursin("compact", file) continue end
            if isfile(LOGGER_FOLDER * file * "c") continue end
            
            current_trial_id = split(file, "_")[1]
            if current_trial_id != trial_id continue end
    
            logger = deserialize(LOGGER_FOLDER * file)
            append!(logged_organisms, [l for l in values(logger.logged_organisms_alive) if l.snapshot_id != "-1"])
        end

        println(LOGGER_FOLDER * trial_id * "compact")
        serialize(LOGGER_FOLDER * trial_id * "compact", logged_organisms)

        append!(data.logged_organisms, logged_organisms)
    end
end

function get_genotype(data::CollectedData, genotype_id)
    lock(data.lock) do
        if haskey(data.genotypes, genotype_id) 
            return data.genotypes[genotype_id]
        end
            
        genotype = deserialize(GENOTYPE_FOLDER * genotype_id)
        data.genotypes[genotype_id] = genotype
        
        return genotype
    end
end

function get_snapshot(data::CollectedData, snapshot_id; cache = true)
    lock(data.lock) do
        if haskey(data.snapshots, snapshot_id)
            return data.snapshots[snapshot_id]
        end

        for trial_id in data.trial_ids
            filename = trial_id * "_" * string(snapshot_id)

            if isfile(SNAPSHOTS_FOLDER * filename)
                snapshot = deserialize(SNAPSHOTS_FOLDER * filename)
                set_logger!(snapshot, DoNothingLogger())

                if cache
                    data.snapshots[snapshot_id] = snapshot
                end

                return snapshot
            end
        end
    end
end

function get_snapshot_ids(data::CollectedData)
    snapshot_ids = []

    for filename in readdir(SNAPSHOTS_FOLDER)
        trial_id, snapshot_id = split(filename, "_")
	
	if trial_id == "4739122895933101" continue end       
 
        if trial_id in data.trial_ids
            push!(snapshot_ids, string(snapshot_id))
        end
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
    all_genotypes = Set()
    offspring_parents = Dict()

    for trial_id in data.trial_ids
        @info trial_id
        organism_genotypes = Dict()
        i = 0        
        
        for file in readdir(LOGGER_FOLDER)
            if isfile(LOGGER_FOLDER * file) == false continue end
            if occursin("compact", file) continue end
            if occursin("c", file) continue end
            
            current_trial_id = split(file, "_")[1]
            if current_trial_id != trial_id continue end
    
            try
                logger = deserialize(LOGGER_FOLDER * file)
                
                for (_, organism) in logger.logged_organisms_dead
                    push!(all_genotypes, organism.genotype_id)
                    organism_genotypes[organism.id] = organism.genotype_id

                    if haskey(organism_genotypes, organism.parent_id) == false
                        continue
                    end

                    parent_genotype_id = organism_genotypes[organism.parent_id]

                    key = (parent_genotype_id, organism.genotype_id)

                    if haskey(offspring_parents, key)
                        offspring_parents[key] += 1
                    else
                        offspring_parents[key] = 1
                    end
                end
                i += 1
                l = length(all_genotypes)

                @info "$i \t $l \t $file"
            catch exp
                @info exp                
            end
        end

        serialize(CALCULATED_FOLDER * "all_genotypes", all_genotypes)
        serialize(CALCULATED_FOLDER * "offspring_parents", offspring_parents)
    end
end
