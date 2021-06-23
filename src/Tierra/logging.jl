save_model_summary(model::TierraModel) = save_model_summary(model, "final")

function save_model_summary(model::TierraModel, prefix)
    counter = Dict{String, Integer}()

    for key in model.organism_keys
        organism = model.organisms[key]

        if haskey(counter, organism.hash)
            counter[organism.hash] += 1
        else
            counter[organism.hash] = 1
        end
    end

    open(LOG_FILE * string(prefix), "w+") do io

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
