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

    has_fired::Bool
    reachable_from_input::Bool

    function Node(string, in_inhibitory, out_inhibitory, in_excitatory, out_excitatory)
        new(string, in_inhibitory, out_inhibitory, in_excitatory, out_excitatory,
            [], [], [], [], HiddenNode(), [], [], false, false)
    end

    Node(string) = new(string, [], [], [], [], [], [], [], [], HiddenNode(), [], [], false, false)
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
