function _is_within_range(query_start, query_length, target_start, target_length)
    target_start <= query_start <= query_start - 1 + query_length <= target_start - 1 + target_length
end

abstract type Overlap end
struct ExactMatch <: Overlap end
struct LeftNeighbor <: Overlap end
struct RightNeighbor <: Overlap end
struct Disjunct <: Overlap end
struct Within <: Overlap end
struct WithinFromStart <: Overlap end
struct WithinToEnd <: Overlap end
struct CompleteOverlap <: Overlap end
struct LeftOverlap <: Overlap end
struct RightOverlap <: Overlap end

function _determine_overlap(query_start, query_length, target_start, target_length)
    query_end = query_start - 1 + query_length
    target_end = target_start - 1 + target_length

    if query_start == target_start && query_length == target_length
        ExactMatch()
    elseif query_end == target_start - 1
        LeftNeighbor()
    elseif query_start == target_end + 1
        RightNeighbor()
    elseif query_end < target_start || target_end < query_start
        Disjunct()
    elseif target_start == query_start <= query_end < target_end
        WithinFromStart()
    elseif target_start < query_start <= query_end == target_end
        WithinToEnd()
    elseif target_start < query_start <= query_end  < target_end
        Within()
    elseif query_start < target_start <= query_end <= target_end
        LeftOverlap()
    elseif target_start <= query_start <= target_end < query_end
        RightOverlap()
    elseif query_start < target_start <= target_end  < query_end
        CompleteOverlap()
    else
        println(query_start, " ", query_length, " ", target_start, " ", target_length)
        @assert false
    end
end