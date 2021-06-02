abstract type Genotype end
abstract type Position end
abstract type Environment end

struct DefaultEnvironment <: Environment end
struct DefaultPosition <: Position end

struct Ancestor end

mutable struct Organism
    id::Int

    genotype::Genotype
    parent::Union{Organism, Ancestor}
    
    position::Position
    environment::Environment

    time_birth::Int
    time_death::Int

    function Organism(genotype::Genotype, parent::Union{Organism, Ancestor}, time_birth, time_death)
        new(-1, genotype, parent, DefaultPosition(), DefaultEnvironment(), time_birth, time_death)
    end
end

get_id(::Ancestor) = -1
get_id(organism::Organism) = organism.id