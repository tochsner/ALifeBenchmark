import Random

function sample_organism(data::CollectedData)    
    rand(data.logged_organisms)
end


function sample_snapshot_id(data::CollectedData)    
    first(sample_snapshot_ids(data, 1))
end
function sample_snapshot_ids(data::CollectedData, num_samples)    
    all_snaphot_ids = get_snapshot_ids(data)
    rand(all_snaphot_ids, num_samples)
end

            

function sample_organisms(data::CollectedData, num_samples)    
    rand(data.logged_organisms, num_samples)
end

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