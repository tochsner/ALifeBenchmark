function get_axiom_network()
    network = Network()
    update_inputs_outputs!(network, [get_axiom_node()])
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