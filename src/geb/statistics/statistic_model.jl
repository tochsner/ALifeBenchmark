struct GebbianPosition <: Position
    x::Float64
    y::Float64
end

struct GebbianEnvironment <: Environment end

get_time(gebbian_model::GebModel) = gebbian_model.time
get_organisms(gebbian_model::GebModel) = [o for o in gebbian_model.organisms]

get_logger(gebbian_model::GebModel) = gebbian_model.logger
function set_logger!(gebbian_model::GebModel, logger::Logger)
    gebbian_model.logger = logger
end

get_id(::GebModel, gebbian_organism::GebOrganism) = gebbian_organism.key
get_genotype(::GebModel, gebbian_organism::GebOrganism) = gebbian_organism.genotype
function get_position(::GebModel, gebbian_organism::GebOrganism)
    GebbianPosition(gebbian_organism.coordinates[1], gebbian_organism.coordinates[2])
end
function get_environment(::GebModel, ::GebOrganism)
    GebbianEnvironment()
end
function get_time_birth(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.time_birth
end
function get_time_death(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.time_birth + gebbian_organism.age
end
function get_age(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.age
end
function clean_snapshot!(model::GebModel)
    model.logger = DoNothingLogger()
end

get_daughters(::GebModel, gebbian_organism::GebOrganism) = gebbian_organism.daughters

function get_abstracted_organism(model::GebModel, model_organism::GebOrganism, parent_ids, parent_genotypes)
    return Organism{GebbianPosition, GebbianEnvironment, String}(
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

function replace_organism!(model::GebModel, key::UInt64, new_genotype::String)    
    # remove old organism first

    old_organism = get_organism(model, key)
    kill!(model, old_organism)

    # add new organism

    new_organism = GebOrganism(new_genotype, old_organism.coordinates, old_organism.parent_genotypes[1], 
                                old_organism.parent_genotypes[2], model.time)

    add_organism!(model, new_organism)

    return new_organism
end

function run_until(termination_predicate, model::GebModel)
    while termination_predicate(logger, model) == false
        execute!(model)
    end
end
