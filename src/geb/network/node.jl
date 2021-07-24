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

    inhibitory_output::Float64
    excitatory_output::Float64
    
    temp_inhibitory_output::Float64
    temp_excitatory_output::Float64

    reachable_from_input::Bool

    io_value::Float64

    function Node(string, in_inhibitory, out_inhibitory, in_excitatory, out_excitatory)
        new(string, in_inhibitory, out_inhibitory, in_excitatory, out_excitatory,
            [], [], [], [], HiddenNode(), 0, 0, 0, 0, false, 0)
    end

    Node(string) = new(string, [], [], [], [], [], [], [], [], HiddenNode(), 0, 0, 0, 0, false, 0)
end

function fill_temp_links!(node)
    node.temp_in_inhibitory = []
    node.temp_out_inhibitory = []
    node.temp_in_excitatory = []
    node.temp_out_excitatory = []
    append!(node.temp_in_inhibitory, node.in_inhibitory)
    append!(node.temp_out_inhibitory, node.out_inhibitory)
    append!(node.temp_in_excitatory, node.in_excitatory)
    append!(node.temp_out_excitatory, node.out_excitatory)
end

function apply_temp_links!(node)
    node.in_inhibitory = []
    node.out_inhibitory = []
    node.in_excitatory = []
    node.out_excitatory = []

    append!(node.in_inhibitory, node.temp_in_inhibitory)
    append!(node.out_inhibitory, node.temp_out_inhibitory)
    append!(node.in_excitatory, node.temp_in_excitatory)
    append!(node.out_excitatory, node.temp_out_excitatory)
end

function apply_temp_activations!(node)
    node.inhibitory_output = node.temp_inhibitory_output
    node.excitatory_output = node.temp_excitatory_output
end