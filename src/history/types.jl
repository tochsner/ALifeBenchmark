mutable struct DetailedOrganism 
    id::Int

    genotype::Genotype
    parent::Int
    
    position::Position
    environment::Environment

    time_birth::Int
    time_death::Int

    num_offsprings::Int
    num_identical_offsprings::Int
    
    population::Dict{Genotype, Int}

    function DetailedOrganism(organism::Organism, num_offsprings, num_identical_offsprings, population)
        new(get_id(organism), organism.genotype, get_id(organism.parent), organism.position, organism.environment, 
            organism.time_birth, organism.time_death, num_offsprings, num_identical_offsprings, population)
    end
end

get_id(organism::DetailedOrganism) = organism.id
get_fitness(organism::DetailedOrganism) = organism.num_identical_offsprings

abstract type PropertyType end
struct GenotypeType <: PropertyType end
struct PositionType <: PropertyType end
struct EnvironmentType <: PropertyType end
struct FitnessType <: PropertyType end
struct NumOffspringsType <: PropertyType end
struct PopulationType <: PropertyType end

get(organism::DetailedOrganism, ::GenotypeType) = organism.genotype
get(organism::DetailedOrganism, ::PositionType) = organism.position
get(organism::DetailedOrganism, ::EnvironmentType) = organism.environment
get(organism::DetailedOrganism, ::FitnessType) = organism.num_identical_offsprings
get(organism::DetailedOrganism, ::NumOffspringsType) = organism.num_offsprings
get(organism::DetailedOrganism, ::PopulationType) = organism.population