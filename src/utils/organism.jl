abstract type Position end
abstract type Environment end

struct DefaultEnvironment <: Environment end
struct DefaultPosition <: Position end

struct Ancestor end

mutable struct Organism{P <: Position, E <: Environment, G}
    id::UInt64
    
    genotype::G
    parent_ids::Vector{UInt64}
    parent_genotypes::Vector{G}
    
    position::P
    environment::E

    time_birth::UInt64
    time_death::UInt64
    
    snapshot_id::String

    function Organism(genotype, parent_ids, parent_genotypes, time_birth, time_death) where
        {O <: Organism, A <: Ancestor, G}

        new{DefaultPosition, DefaultEnvironment, G}(-1, genotype, parent_ids, parent_genotypes, DefaultPosition(), DefaultEnvironment(), time_birth, time_death, 0)
    end
    function Organism{P, E, G}(id, genotype, parent_ids, parent_genotypes, position::P, environment::E, time_birth, time_death, snapshot_id) where
        {P <: Position, E <: Environment, G}

        new{P, E, G}(id, genotype, parent_ids, parent_genotypes, position, environment, time_birth, time_death, string(snapshot_id))
    end
end

get_id(::Ancestor) = -1
get_id(organism::Organism) = organism.id