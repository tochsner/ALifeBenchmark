function Base.delete!(array::Vector{T}, element::T) where {T}
    deleteat!(array, indexin([element], array))
end

function deleteif!(array::Array{T, N}, predicate) where {T, N}
    deleteat!(array, findall(predicate, array))
end

function clear!(array::Array)
    for i in length(array):-1:1
        deleteat!(array, i)
    end
end
function clear!(dict::Dict)
    for key in unique(keys(dict))
        delete!(dict, key)
    end
end

function index_of(array::Array{T, N}, element::T) where {T, N}
    first(indexin([element], array))
end

mod_1(x, d) = mod(x - 1, d) + 1

"""
struct IndexList{T}
    items::Dict{T, UInt64}
end

Base.length(list::IndexList) = length(list.items)

function Base.push!(list::IndexList{T}, element::T) where {T}
    list.items[element] = length(list) + 1
end

function index_of(list::IndexList{T}, element::T) where {T}
   list.items[element]
end
"""