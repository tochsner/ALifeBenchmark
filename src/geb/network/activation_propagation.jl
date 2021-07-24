function fire!(network, excitatory_inputs)
    for (input_node, excitatory) in zip(network.inputs, excitatory_inputs)
        input_node.io_value = excitatory
    end

    apply_to_all(fire!, network)
    apply_to_all(apply_temp_activations!, network)
end

function fire!(node)
    excitatory_output = 0
    inhibitory_output = 0

    inhibitory_activation = sum([n.inhibitory_output for n in node.in_inhibitory])
    excitatory_activation = sum([n.excitatory_output for n in node.in_excitatory])

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

    node.temp_inhibitory_output = inhibitory_output
    node.temp_excitatory_output = excitatory_output
end
