abstract type Position end
abstract type Environment end

struct DefaultEnvironment <: Environment end
struct DefaultPosition <: Position end

struct Ancestor end

mutable struct Organism{P <: Position, E <: Environment}
    id::UInt64
    
    genotype_id::String
    parent_id::Union{UInt64, Vector{UInt64}}
    
    position::P
    environment::E

    time_birth::UInt64
    time_death::UInt64
    
    snapshot_id::String

    function Organism(genotype, parent, time_birth, time_death) where
        {O <: Organism, A <: Ancestor}

        new{DefaultPosition, DefaultEnvironment}(-1, genotype, parent, DefaultPosition(), DefaultEnvironment(), time_birth, time_death, 0)
    end
    function Organism{P, E}(id, genotype, parent, position::P, environment::E, time_birth, time_death, snapshot_id) where
        {P <: Position, E <: Environment}

        new{P, E}(id, genotype, parent, position, environment, time_birth, time_death, string(snapshot_id))
    end
end

get_id(::Ancestor) = -1
get_id(organism::Organism) = organism.id