struct SimulationExpection <: Exception
    message::String
end

get_organism_ids(snapshot) = [get_id(snapshot, o) for o in get_organisms(snapshot)]
get_ids(snapshot, organisms::Vector) = [get_id(snapshot, o) for o in organisms]

function get_fitness(snapshot, abstracted_organism_to_replace::Organism, new_genotype)    
    get_fitness(snapshot, abstracted_organism_to_replace.id, new_genotype)
end
function get_fitness(snapshot, key_to_replace::UInt64, new_genotype)   
    new_organism = simulate_organism!(snapshot, key_to_replace, new_genotype)
    fitness = get_fitness(snapshot, new_organism)
    
    return fitness
end
function get_fitness(snapshot, organism)
    num_reproducing_daughters = length([
        d for d in get_daughters(snapshot, organism) 
        if get_genotype(snapshot, organism) == get_genotype(snapshot, d) || !isempty(get_daughters(snapshot, d))
    ])
    age = get_age(snapshot, organism)
    fitness = num_reproducing_daughters / age

    return age == 0 ? 0 : fitness
end

function simulate_snapshot!(termination_predicate, snapshot, logger = DoNothingLogger())
    snapshot = deepcopy(snapshot)
    set_logger!(snapshot, logger)
    run_until!(termination_predicate, snapshot)
    return snapshot
end

function simulate_organism!(snapshot, abstracted_organism_to_replace::Organism, new_genotype)
    simulate_organism!(snapshot, abstracted_organism_to_replace.id, new_genotype)
end
function simulate_organism!(snapshot, key_to_replace::UInt64, new_genotype)
    snapshot = deepcopy(snapshot)

    new_organism = replace_organism!(snapshot, key_to_replace, new_genotype)

    # run simulation until death of the new organism and its (non-identical) children
    # (we assume that identical children are able to reproduce themselves)

    run_until!(snapshot) do snapshot
        living_organisms = get_organisms(snapshot)

        return !(new_organism in living_organisms) &&
                all([
                    get_genotype(snapshot, new_organism) == get_genotype(snapshot, d) || 
                    !(d in get_organisms(snapshot)) 
                    
                    for d in get_daughters(snapshot, new_organism)
                ])
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

get_genotype(snapshot, organism)
get_parent_genotype(snapshot, organism)

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
