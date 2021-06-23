mutable struct GebModel
    size::Int8

    organisms::Vector{GebOrganism}
    grid::Array{Union{GebOrganism, Nothing}, 2}

    next_key::UInt32

    function GebModel(; size=20)
        initial_organisms = [
            GebOrganism(size*(x-1) + y, "0", (x - 0.5, y - 0.5))
            for x in 1:size for y in 1:size
        ]
        grid = [initial_organisms[size*(x-1) + y] for x in 1:size, y in 1:size]

        return new(size, initial_organisms, grid, size*size + 1)
    end
end

function _get_grid_coordinates(continuous_coordinates)
    (
        max(1, Int(ceil(continuous_coordinates[1]))),
        max(1, Int(ceil(continuous_coordinates[2])))
    )    
end

function add_organism!(model::GebModel, organism::GebOrganism)
    x, y = _get_grid_coordinates(organism.coordinates)
    model.grid[x, y] = organism

    push!(model.organisms, organism)

    organism.key = model.next_key
    model.next_key += 1
end

function kill!(model::GebModel, organism::GebOrganism)
    x, y = _get_grid_coordinates(organism.coordinates)
    model.grid[x, y] = nothing

    delete!(model.organisms, organism)
end