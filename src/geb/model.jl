mutable struct GebModel
    size::Int8

    organisms::Vector{GebOrganism}
    grid::Array{Union{GebOrganism, Nothing}, 2}

    next_key::UInt64

    time::UInt64

    logger::Logger

    function GebModel(; size=20)
        GebModel(DoNothingLogger(), size=size)
    end
    function GebModel(logger::Logger; size=20)
        initial_organisms = [
            GebOrganism(size*(x-1) + y, "0", (x - 0.5, y - 0.5))
            for x in 1:size for y in 1:size
        ]
        grid = [initial_organisms[size*(x-1) + y] for x in 1:size, y in 1:size]

        return new(size, initial_organisms, grid, size*size + 1, 0, logger)
    end
end

function _get_grid_coordinates(continuous_coordinates)
    (
        @fastmath max(1, Int(ceil(continuous_coordinates[1]))),
        @fastmath max(1, Int(ceil(continuous_coordinates[2])))
    )    
end

function get_organism(model::GebModel, key::UInt64)
    for organism in model.organisms
        if organism.key == key return organism end
    end
end

function add_organism!(model::GebModel, organism::GebOrganism)
    x, y = _get_grid_coordinates(organism.coordinates)
    model.grid[x, y] = organism

    push!(model.organisms, organism)

    organism.key = model.next_key
    model.next_key += 1

    return organism
end

function kill!(model::GebModel, organism::GebOrganism)
    if length(model.organisms) <= MIN_ORGANISMS return end

    x, y = _get_grid_coordinates(organism.coordinates)
    model.grid[x, y] = nothing

    @assert organism in model.organisms
    delete!(model.organisms, organism)

    log_death(model.logger, model, organism)
end