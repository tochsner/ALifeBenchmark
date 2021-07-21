using LinearAlgebra
import Base.FastMath.@fastmath

abstract type Side end
struct BothSides <: Side end
struct ToTheLeft <: Side end
struct ToTheRight <: Side end

function determine_input_activations(model::GebModel, organism::GebOrganism)    
    all_neighbors = _get_neighbors(BothSides(), model, organism)

    left_neighbors = nothing
    right_neighbors = nothing

    loaded_left_neighbors = false
    loaded_right_neighbors = false

    activations = Float64[]

    distances = Dict()

    for input in organism.network.inputs
        string = input.string

        if length(string) == 0
            push!(activations, 0.0)
            continue
        end

        if string[1] == '0'
            if loaded_left_neighbors == false
                left_neighbors = _get_neighbors(ToTheLeft(), model, organism, all_neighbors)
                loaded_left_neighbors == true
            end
            relevant_neighbors = left_neighbors
        else
            if loaded_right_neighbors == false
                right_neighbors = _get_neighbors(ToTheRight(), model, organism, all_neighbors)
                loaded_right_neighbors == true
            end
            relevant_neighbors = right_neighbors
        end

        activation_sum = 0.0
        for neighbor in relevant_neighbors
            neighbor_sum = 0.0

            for output in neighbor.network.external_outputs
                if _is_match(string[2:end], output.string)
                    neighbor_sum += sum([a for (a, n) in zip(output.excitatory_activation, output.in_excitatory) if n.has_fired])
                end
            end

            if 0.0 < neighbor_sum
                if haskey(distances, neighbor) == false
                    distances[neighbor] = @fastmath norm(organism.coordinates .- neighbor.coordinates)
                end

                activation_sum += DISTANCE_SCALE_FACTOR * (neighbor_sum / distances[neighbor])
            end
        end

        
        push!(activations, activation_sum)
    end
    
    println(activations)
    return activations
end

function _get_neighbors(side::Side, model::GebModel, organism::GebOrganism, all_neighbors)
    [neighbor for neighbor in all_neighbors if _is_on_side(side, model, neighbor, organism)]
end

function _get_neighbors(side::Side, model::GebModel, organism::GebOrganism)
    _get_neighbors(side, model, organism, _get_neighbors(BothSides(), model, organism))
end

function _get_neighbors(::BothSides, model::GebModel, organism::GebOrganism)
    neighbors = []

    x_center, y_center = _get_grid_coordinates(organism.coordinates)

    for x in (x_center - INFLUENCE_RADIUS):(x_center + INFLUENCE_RADIUS)
        for y in (y_center - INFLUENCE_RADIUS):(y_center + INFLUENCE_RADIUS)
            x, y = mod_1(x, model.size), mod_1(y, model.size)

            if model.grid[x, y] !== nothing && model.grid[x, y] != organism
                push!(neighbors, model.grid[x, y])
            end
        end
    end

    return neighbors
end

function _is_on_side(side::Side, model::GebModel, target::GebOrganism, source::GebOrganism)
    _is_on_side(side, model, target.coordinates, source.coordinates, source.direction)
end
function _is_on_side(side::Side, model::GebModel, target_coordinates, source_coordinates, source_direction)
    Δx = @fastmath (target_coordinates[1] - source_coordinates[1])
    Δy = @fastmath -(target_coordinates[2] - source_coordinates[2]) # negative as direction of y-axis is different in array!

    # test if wrap-over sides is nearer
    if abs(Δx) >= model.size / 2
        Δx = @fastmath (Δx - sign(Δx)*model.size)
    end
    if abs(Δy) >= model.size / 2
        Δy = @fastmath (Δy - sign(Δy)*model.size)
    end

    if Δx == 0
        target_direction = (0 <= Δy) ? 90 : 270
    elseif Δx < 0
        target_direction = @fastmath (180 + atand(Δy / Δx))
    elseif 0 < Δx
        target_direction = @fastmath (atand(Δy / Δx))
    end

    return _is_on_side(side, target_direction, source_direction)
end
function _is_on_side(::ToTheLeft, target_direction::Number, source_direction::Number)
    mod(target_direction - source_direction, 360) <= 180
end
function _is_on_side(::ToTheRight, target_direction::Number, source_direction::Number)
    mod(target_direction - source_direction, 360) > 180
end
