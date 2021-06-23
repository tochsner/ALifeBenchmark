function delete!(array::Vector{T}, element::T) where {T}
    deleteat!(array, indexin([element], array))
end

function deleteif!(array::Array{T, N}, predicate) where {T, N}
    deleteat!(array, findall(predicate, array))
end

function clear!(array)
    for i in length(array):-1:1
        deleteat!(array, i)
    end
end

function index_of(array::Array{T, N}, element::T) where {T, N}
    first(indexin([element], array))
end

mod_1(x, d) = mod(x - 1, d) + 1