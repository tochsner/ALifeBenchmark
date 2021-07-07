get_organism_ids(snapshot) = get_id.(get_organisms(snapshot))
get_id(snapshot, organisms::Vector) = get_id.(snapshot, organisms)

function get_fitness(snapshot, abstracted_organism_to_replace::Organism, new_genotype)    
    get_fitness(snapshot, abstracted_organism_to_replace.id, new_genotype)
end
function get_fitness(snapshot, key_to_replace::UInt64, new_genotype)   
    new_organism = simulate_organism!(snapshot, key_to_replace, new_genotype)
    fitness = get_fitness(snapshot, new_organism)
    
    return fitness
end
function get_fitness(snapshot, organism)
    num_daughters = length(get_daughters(snapshot, organism))
    age = get_age(snapshot, organism)
    fitness = num_daughters / age
    
    return age == 0 ? 0 : fitness
end

function simulate_organism!(snapshot, abstracted_organism_to_replace::Organism, new_genotype)
    simulate_organism!(snapshot, abstracted_organism_to_replace.id, new_genotype)
end
function simulate_organism!(snapshot, key_to_replace::UInt64, new_genotype)
    snapshot = deepcopy(snapshot)

    new_organism = replace_organism!(snapshot, key_to_replace, new_genotype)

    # run simulation until death of the new organism

    run_until!(snapshot) do snapshot
        !(new_organism in get_organisms(snapshot))
    end

    return new_organism
end

function run_n_timesteps!(snapshot, n_timesteps)
    executed_timesteps = 0

    run_until!(snapshot) do _
        executed_timesteps += 1
        return executed_timesteps == n_timesteps
    end
end

"""
To implement by each model:

get_time(snapshot)
get_organisms(snapshot)

get_logger(snapshot)
set_logger!(snapshot)

get_id(snapshot, organism)

get_genotype_id(snapshot, organism)
get_genotype_id(genotype)
get_genotype(snapshot, organism)
get_parent_genotype_id(snapshot, organism)

get_position(snapshot, organism)
get_environment(snapshot, organism)

get_time_birth(snapshot, organism)
get_time_death(snapshot, organism)
get_age(snapshot, organism)

get_daughters(snapshot, organism)

get_abstracted_organism(snapshot, organism, parent_id)

replace_organism!(snapshot, key_to_replace, new_genotype)
run_until!(predicate, snapshot)
"""