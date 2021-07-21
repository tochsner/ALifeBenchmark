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
end

function activate_inputs!(network, excitatory_activations)
    activate_inputs!(network, excitatory_activations, [0 for _ in excitatory_activations])
end
function activate_inputs!(network, excitatory_activations, inhibitory_activations)
    reset_activations!(network)

    for (input_node, inhibitory, excitatory) in 
        zip(network.inputs, inhibitory_activations, excitatory_activations)

        input_node.inhibitory_activation = [0 for _ in input_node.in_inhibitory]
        input_node.excitatory_activation = [0 for _ in input_node.in_excitatory]

        external_inhibitory_index = findfirst(x -> x.type == ExternalNode(), input_node.in_inhibitory)
        input_node.inhibitory_activation[external_inhibitory_index] = inhibitory
        
        external_excitatory_index = findfirst(x -> x.type == ExternalNode(), input_node.in_excitatory)
        input_node.excitatory_activation[external_excitatory_index] = excitatory
    end

    for node in network.inputs
        if _can_fire(node)
            fire!(node)
        end
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
    if node.type == ExternalNode() return end    

    excitatory_output = 0
    inhibitory_output = 0

    inhibitory_activation = sum(node.inhibitory_activation)
    excitatory_activation = sum(node.excitatory_activation)

    node.has_fired = true

    if inhibitory_activation <= 0.0
        excitatory_output = excitatory_activation
        
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

    for out_node in node.out_inhibitory
        inhibit!(out_node, node, inhibitory_output)
    end
    for out_node in node.out_excitatory
        excite!(out_node, node, excitatory_output)
    end
end
