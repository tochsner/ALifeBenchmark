mutable struct Network
    inputs::Vector{Node}
    outputs::Vector{Node}
    external_outputs::Vector{Node} 

    fully_developed::Bool

    Network() = new([], [], [], false)
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
    _remove_external_nodes(network)
    
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

    _add_external_nodes(network)
end

function _remove_external_nodes(network)
    for input in network.inputs
        deleteif!(input.in_excitatory, x -> x.type == ExternalNode())
        deleteif!(input.in_inhibitory, x -> x.type == ExternalNode())
    end
    for output in network.outputs
        deleteif!(output.out_excitatory, x -> x.type == ExternalNode())
        deleteif!(output.out_inhibitory, x -> x.type == ExternalNode())
    end
    clear!(network.external_outputs)
end

function _add_external_nodes(network)
    external_inputs = Dict()
    for input in network.inputs
        if haskey(external_inputs, input.string)
            external = external_inputs[input.string]
        else    
            external = Node(input.string, [], [], [], [])
            external.type = ExternalNode()
            external_inputs[input.string] = external
        end

        push!(input.in_excitatory, external)
        push!(input.in_inhibitory, external)
        
        push!(external.out_excitatory, input)
        push!(external.out_inhibitory, input)
    end
    
    external_outputs = Dict()
    for output in network.outputs
        if haskey(external_outputs, output.string)
            external = external_outputs[output.string]
        else
            external = Node(output.string, [], [], [], [])
            external.type = ExternalNode()
            external_outputs[output.string] = external
        end
        
        push!(external.in_excitatory, output)
        push!(external.in_inhibitory, output)

        push!(output.out_excitatory, external)
        push!(output.out_inhibitory, external)
        
        push!(network.external_outputs, external)
    end
end