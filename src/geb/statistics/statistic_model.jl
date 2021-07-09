using SHA

struct GebbianPosition <: Position
    x::Float64
    y::Float64
end

struct GebbianEnvironment <: Environment end

get_time(gebbian_model::GebModel) = gebbian_model.time
get_organisms(gebbian_model::GebModel) = [o for o in gebbian_model.organisms]

function get_id(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.key
end
function get_genotype_id(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.genotype
end
function get_genotype(gebbian_model::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.genotype
end
function get_parent_genotype_id(::GebModel, gebbian_organism::GebOrganism)
    bytes2hex.(sha256.(gebbian_organism.parent_genotypes))
end
function get_position(::GebModel, gebbian_organism::GebOrganism)
    GebbianPosition(gebbian_organism.coordinates[1], gebbian_organism.coordinates[2])
end
function get_environment(::GebModel, gebbian_organism::GebOrganism)
    GebbianEnvironment()
end
function get_time_birth(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.time_birth
end
function get_time_death(::GebModel, gebbian_organism::GebOrganism)
    gebbian_organism.time_birth + gebbian_organism.age
end
function get_fitness(::GebModel, gebbian_organism::GebOrganism)
    num_daughters = length(gebbian_organism.daughters)
    age = gebbian_organism.age
    fitness = num_daughters / age
    return age == 0 ? 0 : fitness
end
function clean_snapshot!(model::GebModel)
    model.logger = DoNothingLogger()
end

function get_abstracted_organism(model::GebModel, model_organism::GebOrganism, parent_id)
    return Organism{GebbianPosition, GebbianEnvironment}(
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

function get_daughters(model::GebModel, abstracted_organism_to_replace::Organism, new_genotype::String)    
    new_organism = run_simulation(model, abstracted_organism_to_replace, new_genotype)

    daughters = [get_abstracted_organism(model, daughter, new_key) for daughter in new_organism.daughters]
    
    return daughters
end

function get_fitness(model::GebModel, abstracted_organism_to_replace::Organism, new_genotype::String)    
    get_fitness(model, abstracted_organism_to_replace.id, new_genotype)
end

function get_fitness(model::GebModel, key_to_replace::UInt64, new_genotype::String)    
    new_organism = run_simulation(model, key_to_replace, new_genotype)

    fitness = get_fitness(model, new_organism)

    return fitness
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

function run_simulation(model::GebModel, abstracted_organism_to_replace::Organism, new_genotype::String)
    run_simulation(model, abstracted_organism_to_replace.id, new_genotype)
end

function run_simulation(model::GebModel, key_to_replace::UInt64, new_genotype::String)
    model = deepcopy(model)
    model.logger = DoNothingLogger()

    new_organism = replace_organism!(model, key_to_replace, new_genotype)
    new_key = new_organism.key

    # run simulation until death of the new organism

    while new_organism in model.organisms
        execute!(model)
    end

    return new_organism
end

function run_until(model::GebModel, termination_predicate, logger=DoNothingLogger())
    model = deepcopy(model)
    model.logger = logger

    while termination_predicate(logger, model) == false
        execute!(model)
    end

    return model
end

