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
get_genotype_id(::TierraModel, tierrian_organism::TierrianOrganism) = tierrian_organism.hash
function get_genotype(tierrian_model::TierraModel, tierrian_organism::TierrianOrganism)
    read_memory(tierrian_model, tierrian_organism.start_address, tierrian_organism.length)
end
function get_parent_genotype_id(::TierraModel, tierrian_organism::TierrianOrganism)
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
function get_age(::TierraModel, tierrian_organism::TierrianOrganism)
    tierrian_organism.age
end

get_daughters(TierraModel, tierrian_organism::TierrianOrganism) = tierrian_organism.daughters

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

function replace_organism!(model::TierraModel, key::UInt64, new_program::Vector{UInt8})    
    # remove old organism first

    remove_organism!(model, key)

    # add new organism
    # TODO: same place

    new_key = add_organism!(model, new_program)
    new_organism = model.organisms[new_key]

    return new_organism
end

function run_until!(termination_predicate, model::TierraModel)
    while termination_predicate(model) == false
        execute_slice!(model)
    end
end