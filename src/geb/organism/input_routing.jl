using LinearAlgebra

abstract type Side end
struct BothSides <: Side end
struct ToTheLeft <: Side end
struct ToTheRight <: Side end

function determine_input_activations(model::GebModel, organism::GebOrganism)
    left_neighbors = _get_neighbors(ToTheLeft(), model, organism)
    right_neighbors = _get_neighbors(ToTheRight(), model, organism)

    activations = Float64[]

    distances = Dict()

    for input in organism.network.inputs
        string = input.string

        if length(string) == 0
            push!(activations, 0.0)
            continue
        end

        relevant_neighbors = (string[1] == '0') ? left_neighbors : right_neighbors

        sum = 0.0
        for neighbor in relevant_neighbors
            neighbor_sum = 0.0

            for output in neighbor.network.external_outputs
                if _is_match(string[2:end], output.string) && length(output.excitatory_activation) == 1
                    neighbor_sum += output.excitatory_activation[1]
                end
            end

            if 0.0 < neighbor_sum
                if haskey(distances, neighbor) == false
                    distances[neighbor] = norm(organism.coordinates .- neighbor.coordinates)
                end

                sum += neighbor_sum / distances[neighbor]
            end
        end

        push!(activations, sum)
    end   
    
    return activations
end

function _get_neighbors(side::Side, model::GebModel, organism::GebOrganism)
    all_neighbors = _get_neighbors(BothSides(), model, organism)

    return [neighbor for neighbor in all_neighbors if _is_on_side(side, model, neighbor, organism)]
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
    Δx = target_coordinates[1] - source_coordinates[1]
    Δy = -(target_coordinates[2] - source_coordinates[2]) # negative as direction of y-axis is different in array!

    # test if wrap-over sides is nearer
    if abs(Δx) >= model.size / 2
        Δx = Δx - sign(Δx)*model.size
    end
    if abs(Δy) >= model.size / 2
        Δy = Δy - sign(Δy)*model.size
    end

    if Δx == 0
        target_direction = (0 <= Δy) ? 90 : 270
    elseif Δx < 0
        target_direction = 180 + atand(Δy / Δx)
    elseif 0 < Δx
        target_direction = atand(Δy / Δx)
    end

    return _is_on_side(side, target_direction, source_direction)
end
function _is_on_side(::ToTheLeft, target_direction::Number, source_direction::Number)
    mod(target_direction - source_direction, 360) <= 180
end
function _is_on_side(::ToTheRight, target_direction::Number, source_direction::Number)
    mod(target_direction - source_direction, 360) > 180
end
