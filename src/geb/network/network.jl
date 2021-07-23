mutable struct Network
    inputs::Vector{Node}
    outputs::Vector{Node}

    fully_developed::Bool
    num_development_steps::Int8

    Network() = new([], [], false, 0)
end

function Network(starting_node::Node)
    network = Network()

    apply_to_all(starting_node) do x
        if x.type == InputNode()
            push!(network.inputs, x)
        elseif x.type == OutputNode()
            push!(network.outputs, x)
        end
    end

    return network
end

function get_number_neurons(network)
    num_neurons = 0
    apply_to_all(_ -> num_neurons += 1, network)
    return num_neurons
end

function update_inputs_outputs!(network, starting_nodes)    
    clear!(network.inputs)
    clear!(network.outputs)

    if length(starting_nodes) == 0 return end

    apply_to_all(starting_nodes) do x
        if x.type == InputNode()
            push!(network.inputs, x)
        elseif x.type == OutputNode()
            push!(network.outputs, x)
        end
    end        
end

function remove_non_reachable_nodes!(network)
    apply_to_all(network) do node
        node.reachable_from_input = false
    end

    apply_to_all(network.inputs, only_to_outputs = true) do node
        node.reachable_from_input = true
    end

    apply_to_all(network) do node
        filter!(x -> x.reachable_from_input, node.in_inhibitory)
        filter!(x -> x.reachable_from_input, node.in_excitatory)
        filter!(x -> x.reachable_from_input, node.out_inhibitory)
        filter!(x -> x.reachable_from_input, node.out_excitatory)
    end

    filter!(x -> x.reachable_from_input, network.outputs)
end
