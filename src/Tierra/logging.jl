function log_model(model::TierraModel)
    counter = Dict{String, Integer}()

    for key in model.organism_keys
        organism = model.organisms[key]

        if haskey(counter, organism.hash)
            counter[organism.hash] += 1
        else
            counter[organism.hash] = 1
        end
    end

    open(LOG_FILE, "w+") do io

        for (hash, num) in counter
            write(io, hash * ": \t " * string(num) * "\n")
        end

        for key in model.organism_keys        
            organism = model.organisms[key]
            Base.show(io, organism, model)
            write(io, "\n")
        end

    end
end