get_value(tuple::Tuple{DetailedOrganism, T}) where {T <: Number} = tuple[2]
get_value(organism::DetailedOrganism) = get_fitness(organism)

# mean

function mean(list)
    return sum(list) / length(list)
end

function mean(organisms::Union{Vector{DetailedOrganism}, Vector{Tuple{DetailedOrganism, T}}}) where {T <: Number}
    mean(get_value.(organisms))
end

function mean(organisms::Vector{DetailedOrganism}, conditionals) 
    group_function = get_group_function(conditionals)
    mean_per_group = Dict([key => mean(group) for (key, group) in _group_by(organisms, group_function)])    
    return [(organism, mean_per_group[group_function(organism)]) for organism in organisms]
end

function mean(organisms::Vector{Tuple{DetailedOrganism, T}}, conditionals) where {T <: Number}
    group_function = x -> get_group_function(conditionals)(x[1])
    mean_per_group = Dict([key => mean(group) for (key, group) in _group_by(organisms, group_function)])
    return [(organism[1], mean_per_group[group_function(organism)]) for organism in organisms]
end


# variance

function var(list)
    avg = mean(list)
    return sum([(item - avg)^2 for item in list]) / (length(list) - 1)
end

function var(organisms::Union{Vector{DetailedOrganism}, Vector{Tuple{DetailedOrganism, T}}}) where {T <: Number}
    var(get_value.(organisms))
end

function var(organisms::Vector{DetailedOrganism}, conditionals)
    group_function = get_group_function(conditionals)
    var_per_group = Dict([key => var(group) for (key, group) in _group_by(organisms, group_function)])
    return [(organism, var_per_group[group_function(organism)]) for organism in organisms]
end

function var(organisms::Vector{Tuple{DetailedOrganism, T}}, conditionals)  where {T <: Number}
    group_function = x -> get_group_function(conditionals)(x[1])
    var_per_group = Dict([key => var(group) for (key, group) in _group_by(organisms, group_function)])    
    return [(organism[1], var_per_group[group_function(organism)]) for organism in organisms]
end
