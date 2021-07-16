import Random

sample_snapshot_id() = sample_snapshot_ids(1) |> first
sample_snapshot_ids(num_samples) = rand(get_snapshot_ids(), num_samples)

function sample_daughters(snapshot, organism_to_replace::Organism, genotype, num_samples)
    daughters = []

    while length(daughters) < num_samples
        append!(daughters, get_daughters(snapshot, organism_to_replace, genotype))
    end

    return daughters[1:num_samples]
end

function sample_fitness_values(snapshot, organism_to_replace::Organism, genotype, num_samples)
    [get_fitness(snapshot, organism_to_replace, genotype) for _ in 1:num_samples]
end