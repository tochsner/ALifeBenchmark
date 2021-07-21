@testset "Axiom Network Test" begin
    network = ALifeBenchmark.get_axiom_network()
    
    @test [n.string for n in network.inputs] == ["001"]
    @test [n.string for n in network.outputs] == ["01"]
end

@testset "Network Development 1 Test" begin
    network = ALifeBenchmark.get_axiom_network()

    rules = [
        ALifeBenchmark.Rule("001", "0", "01", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("0", "01", "000", false, true, false, false, false, true, 1, 1),
        ALifeBenchmark.Rule("000", "101", "00", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("", "10", "000", true, false, true, true, true, true, 1, 1),
        ALifeBenchmark.Rule("101", "100", "", false, true, false, false, true, true, 1, 1)
    ]

    ALifeBenchmark.develop_nodes!(network, rules)

    @test [n.string for n in network.inputs] == ["0", "01"]
    @test [n.string for n in network.outputs] == ["01", "000"]
end

@testset "Network Development 2 Test" begin
    network = ALifeBenchmark.get_axiom_network()

    rules = [
        ALifeBenchmark.Rule("0", "011", "1101", false, true, false, false, false, true, 1, 1),
        ALifeBenchmark.Rule("00", "101", "", false, true, true, true, false, false, 1, 1),
        ALifeBenchmark.Rule("011", "", "0110", false, false, true, true, false, false, 1, 1),
        ALifeBenchmark.Rule("1101", "110", "1010", false, true, true, false, false, true, 1, 1),
    ]

    ALifeBenchmark.develop_nodes!(network, rules)

    @test [n.string for n in network.inputs] == ["101"]
    @test [n.string for n in network.outputs] == ["011", "1101"]
end

@testset "Activation Propagation Test" begin
    Random.seed!(100)

    node1 = ALifeBenchmark.Node("1", [], [], [], [])
    node2 = ALifeBenchmark.Node("2", [], [], [], [])
    node3 = ALifeBenchmark.Node("3", [], [], [], [])
    node4 = ALifeBenchmark.Node("4", [], [], [], [])
    node5 = ALifeBenchmark.Node("5", [], [], [], [])
    node6 = ALifeBenchmark.Node("6", [], [], [], [])
    node7 = ALifeBenchmark.Node("7", [], [], [], [])
    
    node1.type = ALifeBenchmark.InputNode()
    node2.type = ALifeBenchmark.InputNode()
    node6.type = ALifeBenchmark.OutputNode()
    node7.type = ALifeBenchmark.OutputNode()

    push!(node1.out_excitatory, node3)
    push!(node1.out_inhibitory, node4)
    
    push!(node2.out_excitatory, node3)
    push!(node2.out_excitatory, node4)
    
    push!(node3.in_excitatory, node1)
    push!(node3.in_excitatory, node2)
    push!(node3.out_excitatory, node5)

    push!(node4.in_inhibitory, node1)
    push!(node4.in_excitatory, node2)
    push!(node4.out_excitatory, node7)
    
    push!(node5.in_excitatory, node3)
    push!(node5.out_excitatory, node6)
    push!(node5.out_excitatory, node7)
    
    push!(node6.in_excitatory, node5)
    push!(node6.out_excitatory, node7)
    
    push!(node7.in_excitatory, node4)
    push!(node7.in_excitatory, node5)
    push!(node7.in_excitatory, node6)

    network = ALifeBenchmark.Network()
    ALifeBenchmark.update_inputs_outputs!(network, [node1])
    ALifeBenchmark.add_external_nodes!(network)

    @test length(network.inputs) == 2
    @test length(network.outputs) == 2
    
    @test network.inputs == [node1, node2]
    @test network.outputs == [node6, node7]

    @test length(node1.in_excitatory) == 1
    @test length(node1.in_inhibitory) == 1
    @test length(node2.in_excitatory) == 1
    @test length(node2.in_inhibitory) == 1
    @test length(node6.out_excitatory) == 2
    @test length(node6.out_inhibitory) == 1
    @test length(node7.out_excitatory) == 1
    @test length(node7.out_inhibitory) == 1

    @test node1.in_excitatory[1].type == ALifeBenchmark.ExternalNode()
    @test node1.in_inhibitory[1].type == ALifeBenchmark.ExternalNode()
    @test node2.in_excitatory[1].type == ALifeBenchmark.ExternalNode()
    @test node2.in_inhibitory[1].type == ALifeBenchmark.ExternalNode()
    @test node6.out_excitatory[2].type == ALifeBenchmark.ExternalNode()
    @test node6.out_inhibitory[1].type == ALifeBenchmark.ExternalNode()
    @test node7.out_excitatory[1].type == ALifeBenchmark.ExternalNode()
    @test node7.out_inhibitory[1].type == ALifeBenchmark.ExternalNode()
   
    ALifeBenchmark.activate_inputs!(network, [0, 0], [0, 0])

    @test node6.out_excitatory[2].excitatory_activation == [0.2805599027529448]
    @test node7.out_excitatory[1].excitatory_activation == [0.21156818398564092]
    @test node6.out_excitatory[2].inhibitory_activation == [0]
    @test node7.out_excitatory[1].inhibitory_activation == [0]
    
    ALifeBenchmark.activate_inputs!(network, [1, 2], [1, 0])
    
    @test node6.out_excitatory[2].excitatory_activation == [0.10999587928642951]
    @test node7.out_excitatory[1].excitatory_activation == [0.37576338834068457]
    @test node6.out_excitatory[2].inhibitory_activation == [1.0]
    @test node7.out_excitatory[1].inhibitory_activation == [1.0]

end
