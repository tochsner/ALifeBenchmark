using Profile

function get_axiom_network()
    network = Network()
    update_inputs_outputs!(network, get_axiom_node())
    return network
end
function get_axiom_node()
    n1 = Node(AXIOM_NODES[1], [], [], [], [])
    n2 = Node(AXIOM_NODES[2], [], [], [], [])
    n3 = Node(AXIOM_NODES[3], [], [], [], [])

    n1.type = InputNode()
    n3.type = OutputNode()

    push!(n1.out_excitatory, n2)
    push!(n2.in_excitatory, n1)

    push!(n2.out_excitatory, n3)
    push!(n3.in_excitatory, n2)

    return n1
end

function develop_nodes!(network::Network, rules)
    if length(network.inputs) == 0 return end

    old_network = deepcopy(network)

    time = @elapsed (some_reachable_node = develop_nodes!(network.inputs[1], rules))
    if time > 1
        println("sloooow")        
        println(old_network)
        println([string(r) * "\n" for r in rules])        
    end
    update_inputs_outputs!(network, some_reachable_node)
end

function develop_nodes!(starting_node::Node, rules)
    apply_to_all(fill_temp!, starting_node)

    some_reachable_nodes = []

    apply_to_all(starting_node) do node
        reachable_node = _develop_node!(node, rules)

        if reachable_node !== nothing
            push!(some_reachable_nodes, reachable_node)
        end
    end

    if 0 < length(some_reachable_nodes)
        starting_node = some_reachable_nodes[1]
    end

    apply_to_all(apply_temp!, starting_node, to_temp = true)
    apply_to_all(_remove_deleted, starting_node)

    return 0 < length(some_reachable_nodes) ? some_reachable_nodes[1] : nothing
end

function _develop_node!(node, rules)
    best_matching_rules = find_best_matches(node, rules)

    if 0 < length(best_matching_rules)
        rule_to_apply = rand(best_matching_rules)
        return _apply_rule!(rule_to_apply, node)
    else
        return node
    end
end

function _apply_rule!(rule, node) # Assumes that temp are filled before calling

    # 1. replace string with sucessor_1 or remove node completely

    keep_node = (rule.successor_1 != "")

    if keep_node
        node.string = rule.successor_1
    else
        node.string = DELETED
    end

    # if we don't create a successor we're finished

    if rule.successor_2 == ""
        return keep_node ? node : nothing
    end

    # 2. create successor

    successor = Node(rule.successor_2)
    successor.type = node.type

    # 3. create ingoing inhibitory links to successor

    if rule.inhibitory_1_2 && keep_node
        push!(successor.temp_in_inhibitory, node)
    elseif rule.reverse_input
        append!(successor.temp_in_inhibitory, node.in_excitatory)
    else
        append!(successor.temp_in_inhibitory, node.in_inhibitory)
    end

    # 4. create ingoing excitatory links to successor

    if rule.excitatory_1_2 && keep_node
        push!(successor.temp_in_excitatory, node)
    elseif rule.reverse_input
        append!(successor.temp_in_excitatory, node.in_inhibitory)
    else
        append!(successor.temp_in_excitatory, node.in_excitatory)
    end

    # 5. create outgoing inhibitory links from successor

    if rule.inhibitory_2_1 && keep_node
        push!(successor.temp_out_inhibitory, node)
    elseif rule.reverse_output
        append!(successor.temp_out_inhibitory, node.out_excitatory)
    else
        append!(successor.temp_out_inhibitory, node.out_inhibitory)
    end

    # 6. create outgoing excitatory links from successor

    if rule.excitatory_2_1 && keep_node
        push!(successor.temp_out_excitatory, node)
    elseif rule.reverse_output
        append!(successor.temp_out_excitatory, node.out_inhibitory)
    else
        append!(successor.temp_out_excitatory, node.out_excitatory)
    end

    # 7. create reverse connections

    for in_node in successor.temp_in_inhibitory
        push!(in_node.temp_out_inhibitory, successor)
    end
    for out_node in successor.temp_out_inhibitory
        push!(out_node.temp_in_inhibitory, successor)
    end
    for in_node in successor.temp_in_excitatory
        push!(in_node.temp_out_excitatory, successor)
    end
    for out_node in successor.temp_out_excitatory
        push!(out_node.temp_in_excitatory, successor)
    end

    return keep_node ? node : successor
end

function _remove_deleted(node)
    filter!(x -> x.string != DELETED, node.in_inhibitory)
    filter!(x -> x.string != DELETED, node.in_excitatory)
    filter!(x -> x.string != DELETED, node.out_inhibitory)
    filter!(x -> x.string != DELETED, node.out_excitatory)
end
