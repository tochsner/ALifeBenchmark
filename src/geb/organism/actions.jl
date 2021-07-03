abstract type GebAction end
struct CrossOver <: GebAction end
struct Fight <: GebAction end
struct TurnClockwise <: GebAction end
struct TurnAntiClockwise <: GebAction end
struct MoveForward <: GebAction end
struct NoAction <: GebAction end

_get_prefix(::CrossOver) = "01"
_get_prefix(::Fight) = "100"
_get_prefix(::TurnAntiClockwise) = "101"
_get_prefix(::TurnClockwise) = "110"
_get_prefix(::MoveForward) = "111"

function perform!(model::GebModel, organism::GebOrganism)
    perform!(CrossOver(), model, organism)
    perform!(Fight(), model, organism)
    perform!(MoveForward(), model, organism)
    perform!(TurnAntiClockwise(), model, organism)
    perform!(TurnClockwise(), model, organism)
end

function perform!(action::GebAction, model::GebModel, organism::GebOrganism)
    prefix = _get_prefix(action)

    excitatory_sum = 0
    has_match = false

    for external in organism.network.external_outputs
        if _is_match(prefix, external.string)
            has_match = true
            excitatory_sum += sum(external.excitatory_activation)
        end
    end

    if !has_match
        excitatory_sum = 2*NOISE_LEVEL*rand() - NOISE_LEVEL
    else
        excitatory_sum = max(-1, min(1, excitatory_sum))
    end

    perform!(action, model, organism, excitatory_sum)
end

function perform!(::CrossOver, model::GebModel, parent_1::GebOrganism, activation)
    if activation < CROSS_OVER_THRESHOLD return end

    parent_2 = _get_organism_in_front(model, parent_1)

    if parent_2 === nothing return end

    genotype_1 = parent_1.genotype
    genotype_2 = parent_2.genotype

    min_size = min(length(genotype_1), length(genotype_2))

    cut_point_1 = rand(1:max(1, min_size - 1)) # there is never a cut off at the end
    
    if length(genotype_2) == 1
        cut_point_2 = 1
    elseif cut_point_1 == 1
        cut_point_2 = 1
    elseif cut_point_1 == length(genotype_2)
        cut_point_2 = cut_point_1
    else
        cut_point_2 = cut_point_1 + rand([0, 2])
    end

    child_genotype = genotype_1[1:cut_point_1] * genotype_2[cut_point_2:end]
    child_genotype = get_mutated_genotype(child_genotype)

    if _get_organism_behind(model, parent_1) === nothing
        x_child_grid, y_child_grid = _get_cell_in_direction(model, parent_1.coordinates, 360 - parent_1.direction)

        child = GebOrganism(child_genotype, 
                            (x_child_grid - 0.5, y_child_grid - 0.5),
                            parent_1.genotype, 
                            parent_2.genotype,
                            model.time)
        
        push!(parent_1.daughters, child)
        push!(parent_2.daughters, child)

        add_organism!(model, child)

        log_birth(model.logger, model, child, [parent_1, parent_2])
    else
        child = GebOrganism(child_genotype, 
        parent_2.coordinates,
        parent_1.genotype, 
        parent_2.genotype,
        model.time)
        
        push!(parent_1.daughters, child)
        push!(parent_2.daughters, child)
        
        kill!(model, parent_2)
        
        add_organism!(model, child)
        
        log_birth(model.logger, model, child, [parent_1, parent_2])
    end
end

function perform!(::Fight, model::GebModel, fighter::GebOrganism, activation)
    if activation < FIGHT_THRESHOLD return end

    target = _get_organism_in_front(model, fighter)

    if target !== nothing 
        kill!(model, target)
    end
end

function perform!(::TurnAntiClockwise, ::GebModel, organism::GebOrganism, angle)
    organism.direction = mod(organism.direction - min(MAX_TURN, Int(round(MAX_TURN*angle))), 360)
end
function perform!(::TurnClockwise, ::GebModel, organism::GebOrganism, angle)
    organism.direction = mod(organism.direction + min(MAX_TURN, Int(round(MAX_TURN*angle))), 360)
end

function perform!(::MoveForward, model::GebModel, organism::GebOrganism, distance)
    x_start, y_start = organism.coordinates
    x_start_grid, y_start_grid = _get_grid_coordinates((x_start, y_start))
    dir = organism.direction

    x_end, y_end = x_start + cosd(dir)*distance, y_start + sind(dir)*distance
    x_end, y_end = mod(x_end, model.size), mod(y_end, model.size)

    x_end_grid, y_end_grid = _get_grid_coordinates((x_end, y_end))

    # has the cell even changed?
    if (x_start_grid, y_start_grid) == (x_end_grid, y_end_grid)
        organism.coordinates = x_end, y_end
        return
    end

    # is there already an organism on the new cell?
    if model.grid[x_end_grid, y_end_grid] !== nothing
        return
    end

    # move to new cell
    organism.coordinates = x_end, y_end
    model.grid[x_start_grid, y_start_grid] = nothing
    model.grid[x_end_grid, y_end_grid] = organism
end

function perform!(::NoAction, ::GebModel, ::GebOrganism, _) end