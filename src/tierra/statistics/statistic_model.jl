struct TierrianPosition <: Position
    start::UInt16
    length::UInt16
end

struct TierrianEnvironment <: Environment end

get_time(tierrian_model::TierraModel) = tierrian_model.time
get_organisms(tierrian_model::TierraModel) = [o for o in values(tierrian_model.organisms)]
get_organism_ids(tierrian_model::TierraModel) = [o.key for o in values(tierrian_model.organisms)]

function get_id(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.key
end
function get_genotype_id(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.hash
end
function get_genotype(tierrian_model::TierraModel, tierrian_organism::TierrianOrganism)
    read_memory(tierrian_model, tierrian_organism.start_address, tierrian_organism.length)
end
function get_parent_genotype(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.parent_hash
end
function get_position(::TierraModel, tierrian_organism::TierrianOrganism)
    TierrianPosition(tierrian_organism.start_address, tierrian_organism.length)
end
function get_environment(::TierraModel, tierrian_organism::TierrianOrganism)
    TierrianEnvironment()
end
function get_time_birth(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.time_birth
end
function get_time_death(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.time_birth + tierrian_organism.age
end
function get_fitness(::TierraModel, tierrian_organism::TierrianOrganism)
    num_daughters = length(tierrian_organism.daughters)
    age = tierrian_organism.age
    fitness = num_daughters / age

    return fitness
end

function clean_snapshot!(model::TierraModel)
    model.logger = DoNothingLogger()
end

function get_abstracted_organism(model::TierraModel, model_organism::TierrianOrganism, parent_id)
    return Organism{TierrianPosition, TierrianEnvironment}(
                    get_id(model, model_organism),
                    get_genotype_id(model, model_organism),
                    parent_id,
                    get_position(model, model_organism),
                    get_environment(model, model_organism),
                    get_time_birth(model, model_organism),
                    get_time_death(model, model_organism),
                    -1
    )
end

function get_daughters(model::TierraModel, abstracted_organism_to_replace::Organism, new_program::Vector{UInt8})    
    new_organism = run_simulation(model, abstracted_organism_to_replace, new_program)

    daughters = [get_abstracted_organism(model, daughter, new_key) for daughter in new_organism.daughters]
    
    return daughters
end

function get_fitness(model::TierraModel, abstracted_organism_to_replace::Organism, new_program::Vector{UInt8})    
    get_fitness(model, abstracted_organism_to_replace.id, new_program)
end

function get_fitness(model::TierraModel, key_to_replace::UInt64, new_program::Vector{UInt8})    
    new_organism = run_simulation(model, key_to_replace, new_program)

    fitness = get_fitness(model, new_organism)

    return fitness
end

function replace_organism!(model::TierraModel, key::UInt64, new_program::Vector{UInt8})    
    # remove old organism first

    remove_organism!(model, key)

    # add new organism
    # TODO: same place

    new_key = add_organism!(model, new_program)
    new_organism = model.organisms[new_key]

    return new_organism
end

function run_simulation(model::TierraModel, abstracted_organism_to_replace::Organism, new_program::Vector{UInt8})
    run_simulation(model, abstracted_organism_to_replace.id, new_program)
end

function run_simulation(model::TierraModel, key_to_replace::UInt64, new_program::Vector{UInt8})
    model = deepcopy(model)
    model.logger = DoNothingLogger()

    new_organism = replace_organism!(model, key_to_replace, new_program)
    new_key = new_organism.key

    # run simulation until death of the new organism

    while haskey(model.organisms, new_key)
        execute_slice!(model)
    end

    return new_organism
end

function run_until(model::TierraModel, termination_predicate, logger=DoNothingLogger())
    model = deepcopy(model)
    model.logger = logger

    while termination_predicate(logger, model) == false
        execute_slice!(model)
    end

    return model
end

function run_n_timesteps(model::TierraModel, n_timesteps, logger=DoNothingLogger())
    model = deepcopy(model)
    model.logger = logger

    for _ in 1:convert(UInt64, floor(n_timesteps / SLICE_SIZE))
        execute_slice!(model)
    end

    return model
end

