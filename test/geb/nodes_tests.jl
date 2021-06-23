@testset "Axiom Network Tests" begin

    axiom_network = ALifeBenchmark.get_axiom_node()

    @test axiom_network.string == "001"
    @test axiom_network.out_excitatory[1].string == "000"
    @test axiom_network.out_excitatory[1].out_excitatory[1].string == "01"

    @test axiom_network.out_excitatory[1].in_excitatory[1] == axiom_network
    @test axiom_network.out_excitatory[1].out_excitatory[1].in_excitatory[1] == axiom_network.out_excitatory[1]

end

@testset "Development Helper Test" begin

    node = ALifeBenchmark.Node("1", [], [], [], [ALifeBenchmark.Node("0")])
    rule = ALifeBenchmark.Rule("1", "11", "", false, false, false, false, false, false, 0, 0)

    ALifeBenchmark.apply_to_all(ALifeBenchmark.fill_temp!, node)
    ALifeBenchmark._apply_rule!(rule, node)
    ALifeBenchmark.apply_to_all(ALifeBenchmark.apply_temp!, node)

    @test node.string == "11"
    @test node.out_excitatory[1].string == "0"


    node = ALifeBenchmark.Node("1", [], [], [], [ALifeBenchmark.Node("0")])
    rule = ALifeBenchmark.Rule("1", "11", "010", false, false, false, true, false, false, 0, 0)

    ALifeBenchmark.apply_to_all(ALifeBenchmark.fill_temp!, node)
    ALifeBenchmark._apply_rule!(rule, node)
    ALifeBenchmark.apply_to_all(ALifeBenchmark.apply_temp!, node)

    @test node.string == "11"
    @test length(node.out_excitatory) == 2
    @test node.out_excitatory[2].in_excitatory[1] == node
    @test node.out_excitatory[2].out_excitatory[1] == node.out_excitatory[1]


    node = ALifeBenchmark.Node("1", [], [ALifeBenchmark.Node("101")], [ALifeBenchmark.Node("0")], [])
    rule = ALifeBenchmark.Rule("1", "11", "010", true, false, false, false, true, false, 0, 0)

    ALifeBenchmark.apply_to_all(ALifeBenchmark.fill_temp!, node)
    ALifeBenchmark._apply_rule!(rule, node)
    ALifeBenchmark.apply_to_all(ALifeBenchmark.apply_temp!, node)

    @test node.string == "11"
    @test length(node.out_excitatory) == 0
    @test length(node.out_inhibitory) == 1
    @test length(node.in_excitatory) == 1
    @test length(node.in_inhibitory) == 1

    new = node.in_inhibitory[1]
    @test new.string == "010"
    @test length(new.out_excitatory) == 0
    @test length(new.out_inhibitory) == 1
    @test length(new.in_excitatory) == 0
    @test length(new.in_inhibitory) == 1
    @test new.out_inhibitory[1] == node
    @test new.in_inhibitory[1] == node.in_excitatory[1]

end

@testset "Complete Development Test 1" begin

    node1 = ALifeBenchmark.get_axiom_node()
    node2 = node1.out_excitatory[1]
    node3 = node2.out_excitatory[1]

    rules = [
        ALifeBenchmark.Rule("0", "011", "1101", false, true, false, false, false, true, 1, 1),
        ALifeBenchmark.Rule("00", "101", "", false, true, true, true, false, false, 1, 1),
        ALifeBenchmark.Rule("011", "", "0110", false, false, true, true, false, false, 1, 1),
        ALifeBenchmark.Rule("1101", "110", "1010", false, true, true, false, false, true, 1, 1)
    ]

    @test node1.string == "001"
    @test node2.string == "000"
    @test node3.string == "01"


    ALifeBenchmark.develop_nodes!(node1, rules)

    node4 = node2.out_excitatory[2]

    @test node1.string == "101"
    @test node2.string == "101"
    @test node3.string == "011"
    @test node4.string == "1101"

    @test length(node1.in_inhibitory) == 0
    @test length(node1.in_excitatory) == 0
    @test length(node1.out_inhibitory) == 0
    @test length(node1.out_excitatory) == 1

    @test length(node2.in_inhibitory) == 0
    @test length(node2.in_excitatory) == 1
    @test length(node2.out_inhibitory) == 0
    @test length(node2.out_excitatory) == 2

    @test length(node3.in_inhibitory) == 0
    @test length(node3.in_excitatory) == 2
    @test length(node3.out_inhibitory) == 0
    @test length(node3.out_excitatory) == 0

    @test length(node4.in_inhibitory) == 0
    @test length(node4.in_excitatory) == 1
    @test length(node4.out_inhibitory) == 0
    @test length(node4.out_excitatory) == 1

    @test node1.out_excitatory[1] == node2
    @test node2.in_excitatory[1] == node1

    @test node2.out_excitatory[1] == node3
    @test node3.in_excitatory[1] == node2

    @test node2.out_excitatory[2] == node4
    @test node4.in_excitatory[1] == node2

    @test node4.out_excitatory[1] == node3
    @test node3.in_excitatory[2] == node4


    ALifeBenchmark.develop_nodes!(node1, rules)
    
    node3 = node4.out_excitatory[1]
    node5 = node4.out_inhibitory[1]

    @test length(node1.in_inhibitory) == 0
    @test length(node1.in_excitatory) == 0
    @test length(node1.out_inhibitory) == 0
    @test length(node1.out_excitatory) == 1
    
    @test length(node2.in_inhibitory) == 0
    @test length(node2.in_excitatory) == 1
    @test length(node2.out_inhibitory) == 0
    @test length(node2.out_excitatory) == 3
    
    @test length(node3.in_inhibitory) == 0
    @test length(node3.in_excitatory) == 2
    @test length(node3.out_inhibitory) == 0
    @test length(node3.out_excitatory) == 0
    
    @test length(node4.in_inhibitory) == 0
    @test length(node4.in_excitatory) == 2
    @test length(node4.out_inhibitory) == 1
    @test length(node4.out_excitatory) == 1
    
    @test length(node5.in_inhibitory) == 1
    @test length(node5.in_excitatory) == 1
    @test length(node5.out_inhibitory) == 0
    @test length(node5.out_excitatory) == 1
    
    @test node1.out_excitatory[1] == node2
    @test node2.in_excitatory[1] == node1
    
    @test node2.out_excitatory[2] == node3
    @test node3.in_excitatory[1] == node2
    
    @test node2.out_excitatory[1] == node4
    @test node4.in_excitatory[1] == node2
    
    @test node4.out_excitatory[1] == node3
    @test node3.in_excitatory[2] == node4
    
    @test node2.out_excitatory[3] == node5
    @test node5.in_excitatory[1] == node2
    
    @test node5.out_excitatory[1] == node4
    @test node4.in_excitatory[2] == node5

    @test node4.out_inhibitory[1] == node5
    @test node5.in_inhibitory[1] == node4

end

@testset "Complete Development Test 2" begin

    node1 = ALifeBenchmark.get_axiom_node()
    node2 = node1.out_excitatory[1]
    node3 = node2.out_excitatory[1]

    rules = [
        ALifeBenchmark.Rule("001", "0", "01", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("0", "01", "000", false, true, false, false, false, true, 1, 1),
        ALifeBenchmark.Rule("000", "101", "00", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("", "10", "000", true, false, true, true, true, true, 1, 1),
        ALifeBenchmark.Rule("101", "100", "", false, true, false, false, true, true, 1, 1)
    ]

    @test node1.string == "001"
    @test node2.string == "000"
    @test node3.string == "01"


    ALifeBenchmark.develop_nodes!(node1, rules)

    node4 = node2.in_excitatory[2]
    node5 = node1.out_excitatory[2]
    node6 = node2.out_excitatory[2]

    @test node1.string == "0"
    @test node2.string == "101"
    @test node3.string == "01"
    @test node4.string == "01"
    @test node5.string == "00"
    @test node6.string == "000"

    @test length(node1.in_inhibitory) == 0
    @test length(node1.in_excitatory) == 0
    @test length(node1.out_inhibitory) == 0
    @test length(node1.out_excitatory) == 2
    
    @test length(node2.in_inhibitory) == 0
    @test length(node2.in_excitatory) == 2
    @test length(node2.out_inhibitory) == 0
    @test length(node2.out_excitatory) == 2
    
    @test length(node3.in_inhibitory) == 0
    @test length(node3.in_excitatory) == 3
    @test length(node3.out_inhibitory) == 0
    @test length(node3.out_excitatory) == 0
    
    @test length(node4.in_inhibitory) == 0
    @test length(node4.in_excitatory) == 0
    @test length(node4.out_inhibitory) == 0
    @test length(node4.out_excitatory) == 1
    
    @test length(node5.in_inhibitory) == 0
    @test length(node5.in_excitatory) == 1
    @test length(node5.out_inhibitory) == 0
    @test length(node5.out_excitatory) == 1
    
    @test length(node6.in_inhibitory) == 0
    @test length(node6.in_excitatory) == 1
    @test length(node6.out_inhibitory) == 0
    @test length(node6.out_excitatory) == 1

    println([n.string for n in node1.out_excitatory])

    @test node1.out_excitatory[1] == node2
    @test node2.in_excitatory[1] == node1
    
    @test node1.out_excitatory[2] == node5
    @test node5.in_excitatory[1] == node1

    @test node2.out_excitatory[1] == node3
    @test node3.in_excitatory[1] == node2

    @test node2.out_excitatory[2] == node6
    @test node6.in_excitatory[1] == node2

    @test node4.out_excitatory[1] == node2
    @test node2.in_excitatory[2] == node4

    @test node5.out_excitatory[1] == node3
    @test node3.in_excitatory[2] == node5

    @test node6.out_excitatory[1] == node3
    @test node3.in_excitatory[3] == node6
end