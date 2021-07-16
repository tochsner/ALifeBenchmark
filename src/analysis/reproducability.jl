function is_reproducing(genotype, cutoff_reproductiblity, certainty)
    max_samples = log(1 - certainty) / log(1 - cutoff_reproductiblity)

    for _ in 1:max_samples
        snapshot_to_test = sample_snapshot_id() |> get_snapshot

        if is_reproducing(genotype, snapshot_to_test)
            return true
        end
    end

    return false
end

function is_reproducing(genotype, snapshot)
    organism_to_replace = get_organisms(snapshot) |> rand
    id_to_replace = get_id(snapshot, organism_to_replace)

    fitness = get_fitness(snapshot, id_to_replace, genotype)

    return 0 < fitness
end