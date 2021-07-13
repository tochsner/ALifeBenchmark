function is_reproducing(data, genotype_id, cutoff_reproductiblity, certainty)
    max_samples = log(1 - certainty) / log(1 - cutoff_reproductiblity)

    println(max_samples)

    for i in 1:max_samples
        snapshot_id_to_test = sample_snapshot_id(data)

        if is_reproducing(data, genotype_id, snapshot_id_to_test)
            return true
        end

        println(i)
    end

    return false
end

function is_reproducing(data, genotype_id, snapshot_id)
    genotype = get_genotype(data, genotype_id)

    snapshot = get_snapshot(data, snapshot_id)
    organism_to_replace = rand(get_organisms(snapshot))
    key_to_replace = get_id(snapshot, organism_to_replace)

    fitness = get_fitness(snapshot, key_to_replace, genotype)

    return 0 < fitness
end