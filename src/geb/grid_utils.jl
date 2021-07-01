function _get_organism_in_front(model::GebModel, organism::GebOrganism)
    _get_organism_in_direction(model, organism.coordinates, organism.direction)
end
function _get_organism_behind(model::GebModel, organism::GebOrganism)
    _get_organism_in_direction(model, organism.coordinates, 360 - organism.direction)
end

function _get_organism_in_direction(model::GebModel, coordinates, direction)
    x_target, y_target = _get_cell_in_direction(model, coordinates, direction)
    target = model.grid[x_target, y_target]
    return target
end

function _get_cell_in_direction(model, coordinates, direction)
    x_organism, y_organism = _get_grid_coordinates(coordinates)

    if 45 <= direction < 135
        x_target, y_target = x_organism, y_organism + 1
    elseif 135 <= direction < 225
        x_target, y_target = x_organism - 1, y_organism
    elseif 225 <= direction < 315
        x_target, y_target = x_organism, y_organism - 1
    elseif 315 <= direction || direction < 45
        x_target, y_target = x_organism + 1, y_organism
    end

    x_target, y_target = mod_1(x_target, model.size), mod_1(y_target, model.size)

    return x_target, y_target
end