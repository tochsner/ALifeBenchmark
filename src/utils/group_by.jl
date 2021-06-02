function get_grouped_by(organisms::Vector{DetailedOrganism}, properties::PropertyType...)    
    return _group_by(organisms, get_group_function(properties))
end

get_group_function(properties) = x -> [get(x, p) for p in properties]

function _group_by(list, group_function)
    groups = Dict()

    for item in list
        group = group_function(item)

        if haskey(groups, group)
            push!(groups[group], item)
        else
            groups[group] = [item]
        end
    end

    return groups
end