abstract type NodeType end
struct InputNode <: NodeType end
struct HiddenNode <: NodeType end
struct OutputNode <: NodeType end
struct ExternalNode <: NodeType end

mutable struct Node
    string::String

    in_inhibitory::Vector{Node}
    out_inhibitory::Vector{Node}

    in_excitatory::Vector{Node}
    out_excitatory::Vector{Node}

    temp_in_inhibitory::Vector{Node}
    temp_out_inhibitory::Vector{Node}
    temp_in_excitatory::Vector{Node}
    temp_out_excitatory::Vector{Node}

    type::NodeType

    inhibitory_activation::Vector{Float64}
    excitatory_activation::Vector{Float64}

    function Node(string, in_inhibitory, out_inhibitory, in_excitatory, out_excitatory)
        new(string, in_inhibitory, out_inhibitory, in_excitatory, out_excitatory,
            [], [], [], [], HiddenNode(), [], [])
    end

    Node(string) = new(string, [], [], [], [], [], [], [], [], HiddenNode(), [], [])
end

function fill_temp!(node)
    node.temp_in_inhibitory = []
    node.temp_out_inhibitory = []
    node.temp_in_excitatory = []
    node.temp_out_excitatory = []
    append!(node.temp_in_inhibitory, node.in_inhibitory)
    append!(node.temp_out_inhibitory, node.out_inhibitory)
    append!(node.temp_in_excitatory, node.in_excitatory)
    append!(node.temp_out_excitatory, node.out_excitatory)
end

function apply_temp!(node)
    node.in_inhibitory = []
    node.out_inhibitory = []
    node.in_excitatory = []
    node.out_excitatory = []

    append!(node.in_inhibitory, node.temp_in_inhibitory)
    append!(node.out_inhibitory, node.temp_out_inhibitory)
    append!(node.in_excitatory, node.temp_in_excitatory)
    append!(node.out_excitatory, node.temp_out_excitatory)
end

function reset_activations!(node)
    node.inhibitory_activation = [-1 for _ in node.in_inhibitory]
    node.excitatory_activation = [-1 for _ in node.in_excitatory]
end

function apply_to_neighbors(func, node; to_temp = false)
    if to_temp
        for in_node in node.temp_in_inhibitory
            func(in_node)
        end
        for out_node in node.temp_out_inhibitory
            func(out_node)
        end
        for in_node in node.temp_in_excitatory
            func(in_node)
        end
        for out_node in node.temp_out_excitatory
            func(out_node)
        end
    else
        for in_node in node.in_inhibitory
            func(in_node)
        end
        for out_node in node.out_inhibitory
            func(out_node)
        end
        for in_node in node.in_excitatory
            func(in_node)
        end
        for out_node in node.out_excitatory
            func(out_node)
        end
    end
end

function apply_to_all(func, node; to_temp = false)
    _apply_to_all(func, node, [], to_temp = to_temp)
end
function _apply_to_all(func, node, already_visited_nodes; to_temp = false)
    if node in already_visited_nodes
        return
    end

    push!(already_visited_nodes, node)
    func(node)

    apply_to_neighbors(node_ -> _apply_to_all(func, node_, already_visited_nodes, to_temp = to_temp), node)
end
