
function apply_to_neighbors(func, node; to_temp = false, only_to_outputs = false)
    if to_temp
        if only_to_outputs == false
            for in_node in node.temp_in_inhibitory
                func(in_node)
            end
            for in_node in node.temp_in_excitatory
                func(in_node)
            end
        end
        for out_node in node.temp_out_inhibitory
            func(out_node)
        end
        for out_node in node.temp_out_excitatory
            func(out_node)
        end
    else
        if only_to_outputs == false
            for in_node in node.in_inhibitory
                func(in_node)
            end
            for in_node in node.in_excitatory
                func(in_node)
            end
        end
        for out_node in node.out_inhibitory
            func(out_node)
        end
        for out_node in node.out_excitatory
            func(out_node)
        end
    end
end

function apply_to_all(func, network::Network; to_temp = false, only_to_outputs = false)
    already_visited_nodes = Set{Node}()

    for node in network.inputs
        _apply_to_all(func, node, already_visited_nodes, to_temp = to_temp, only_to_outputs = only_to_outputs)
    end
    for node in network.outputs
        _apply_to_all(func, node, already_visited_nodes, to_temp = to_temp, only_to_outputs = only_to_outputs)
    end
end
function apply_to_all(func, node::Node; to_temp = false, only_to_outputs = false)
    apply_to_all(func, [node], to_temp = to_temp, only_to_outputs = only_to_outputs)
end
function apply_to_all(func, nodes::Vector{Node}; to_temp = false, only_to_outputs = false)
    already_visited_nodes = Set{Node}()
    
    for node in nodes
        _apply_to_all(func, node, already_visited_nodes, to_temp = to_temp, only_to_outputs = only_to_outputs)
    end
end
function _apply_to_all(func, node, already_visited_nodes; to_temp = false, only_to_outputs = false)
    if node in already_visited_nodes
        return
    end

    push!(already_visited_nodes, node)
    func(node)

    apply_to_neighbors(node_ -> _apply_to_all(func, node_, already_visited_nodes, to_temp = to_temp, only_to_outputs = only_to_outputs), node, 
                        to_temp = to_temp, only_to_outputs = only_to_outputs)
end