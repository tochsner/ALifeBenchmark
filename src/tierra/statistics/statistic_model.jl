struct TierrianPosition <: Position
    start::UInt16
    length::UInt16
end

struct TierrianEnvironment <: Environment end

get_time(tierrian_model::TierraModel) = tierrian_model.time
get_organisms(tierrian_model::TierraModel) = [o for o in values(tierrian_model.organisms)]

get_logger(tierrian_model::TierraModel) = tierrian_model.logger
function set_logger!(tierrian_model::TierraModel, logger::Logger)
    tierrian_model.logger = logger
end

get_id(::TierraModel, tierrian_organism::TierrianOrganism) = tierrian_organism.key
function get_genotype(tierrian_model::TierraModel, tierrian_organism::TierrianOrganism)
    read_memory(tierrian_model, tierrian_organism.start_address, tierrian_organism.length)
end
function get_position(::TierraModel, tierrian_organism::TierrianOrganism)
    TierrianPosition(tierrian_organism.start_address, tierrian_organism.length)
end
function get_environment(::TierraModel, ::TierrianOrganism)
    TierrianEnvironment()
end
function get_time_birth(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.time_birth
end
function get_time_death(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.time_birth + tierrian_organism.age
end
function get_age(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.age
end

get_daughters(::TierraModel, tierrian_organism::TierrianOrganism) = tierrian_organism.daughters

function get_abstracted_organism(model::TierraModel, model_organism::TierrianOrganism, parent_ids, parent_genotypes)
    return Organism{TierrianPosition, TierrianEnvironment, Vector{UInt8}}(
                    get_id(model, model_organism),
                    get_genotype(model, model_organism),
                    parent_ids, parent_genotypes,
                    get_position(model, model_organism),
                    get_environment(model, model_organism),
                    get_time_birth(model, model_organism),
                    get_time_death(model, model_organism),
                    -1
    )
end

function replace_organism!(model::TierraModel, key::UInt64, new_program::Vector{UInt8})    
    # remove old organism first

    remove_organism!(model, key)

    # add new organism
    # TODO: same place

    new_key = add_organism!(model, new_program)

    if new_key === nothing
        throw(SimulationExpection("New organism cannot be created in Tierra -- not enough memory."))
    end

    new_organism = model.organisms[new_key]

    return new_organism
end

function run_until!(termination_predicate, model::TierraModel)
    while termination_predicate(model) == false
        execute_slice!(model)
    end
end