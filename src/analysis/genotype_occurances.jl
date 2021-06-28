function get_most_frequent_genotypes(data::CollectedData, top_k)
    occurances = Dict{String, Int64}()

    for organism in data.logged_organisms
        if haskey(occurances, organism.genotype_id)
            occurances[organism.genotype_id] += 1
        else
            occurances[organism.genotype_id] = 1
        end
    end

    most_frequent_k = sort(collect(occurances), by = x -> x[2], rev = true)[1:top_k]

    for (k, v) in most_frequent_k
        println(k, ": ", v)
    end

    return most_frequent_k
end