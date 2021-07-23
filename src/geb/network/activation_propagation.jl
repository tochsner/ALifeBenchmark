_can_fire(node) = !node.has_fired &&
                    all(x -> x >= 0, node.inhibitory_activation) && 
                    all(x -> x >= 0, node.excitatory_activation)

function reset_activations!(network::Network)
    apply_to_all(reset_activations!, network)
end
function reset_activations!(node::Node)
    node.inhibitory_activation = [-1 for _ in node.in_inhibitory]
    node.excitatory_activation = [-1 for _ in node.in_excitatory]
    node.has_fired = false
    node.io_value = 0.0
end

function activate_inputs!(network, excitatory_activations)
    reset_activations!(network)

    for (input_node, excitatory) in zip(network.inputs, excitatory_activations)
        input_node.inhibitory_activation = [0 for _ in input_node.in_inhibitory]
        input_node.excitatory_activation = [0 for _ in input_node.in_excitatory]

        input_node.io_value = excitatory
    end

    for node in network.inputs
        fire!(node)
    end
end

function inhibit!(target, source::Node, activation)
    inhibit!(target, index_of(target.in_inhibitory, source), activation)
end
function inhibit!(target, source_index::Int, activation)
    target.inhibitory_activation[source_index] = activation

    if _can_fire(target)
        fire!(target)
    end
end

function excite!(target, source::Node, activation)
    excite!(target, index_of(target.in_excitatory, source), activation)
end
function excite!(target, source_index::Int, activation)
    target.excitatory_activation[source_index] = activation

    if _can_fire(target)
        fire!(target)
    end
end

function fire!(node)
    excitatory_output = 0
    inhibitory_output = 0

    inhibitory_activation = sum(node.inhibitory_activation)
    excitatory_activation = sum(node.excitatory_activation)

    node.has_fired = true

    if inhibitory_activation <= 0.0
        excitatory_output = excitatory_activation

        if node.type == InputNode()
            excitatory_output += node.io_value
        end
        
        noise = 2.0*NOISE_LEVEL_NODES*rand() - NOISE_LEVEL_NODES
        excitatory_output += noise
        
        excitatory_output = max(excitatory_output, EXCITATORY_MIN)
        excitatory_output = min(excitatory_output, EXCITATORY_MAX)

        excitatory_output -= EXCITATORY_MIN
        excitatory_output /= (EXCITATORY_MAX - EXCITATORY_MIN)        
    end    
    
    if INHIBITORY_THRESHOLD <= excitatory_activation
        inhibitory_output = 1
    end

    if node.type == OutputNode()
        node.io_value = excitatory_output
    end

    for out_node in node.out_inhibitory
        inhibit!(out_node, node, inhibitory_output)
    end
    for out_node in node.out_excitatory
        excite!(out_node, node, excitatory_output)
    end
end
