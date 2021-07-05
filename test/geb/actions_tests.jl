@testset "Grid Test" begin
    @test ALifeBenchmark._get_grid_coordinates((1, 1)) == (1, 1)
    @test ALifeBenchmark._get_grid_coordinates((0.5, 0.5)) == (1, 1)
    @test ALifeBenchmark._get_grid_coordinates((6.5, 3)) == (7, 3)
    @test ALifeBenchmark._get_grid_coordinates((2.5, 3.4)) == (3, 4)

    model = ALifeBenchmark.GebModel(size=2)

    organism_11 = model.grid[1, 1]
    organism_12 = model.grid[1, 2]
    organism_21 = model.grid[2, 1]
    organism_22 = model.grid[2, 2]

    @test ALifeBenchmark._get_cell_in_direction(model, (0.5, 0.5), 0) == (2,  1)
    @test ALifeBenchmark._get_cell_in_direction(model, (0.5, 0.5), 90) == (1, 2)
    @test ALifeBenchmark._get_cell_in_direction(model, (0.5, 0.5), 180) == (2, 1)
    @test ALifeBenchmark._get_cell_in_direction(model, (0.5, 0.5), 270) == (1, 2)
    
    @test ALifeBenchmark._get_cell_in_direction(model, (1.5, 0.5), 0) == (1,  1)
    @test ALifeBenchmark._get_cell_in_direction(model, (1.5, 0.5), 90) == (2, 2)
    @test ALifeBenchmark._get_cell_in_direction(model, (1.5, 0.5), 180) == (1, 1)
    @test ALifeBenchmark._get_cell_in_direction(model, (1.5, 0.5), 270) == (2, 2)

    organism_11.direction = 0
    @test ALifeBenchmark._get_organism_in_front(model, organism_11) == organism_21
    @test ALifeBenchmark._get_organism_behind(model, organism_11) == organism_21
    
    organism_22.direction = 90
    @test ALifeBenchmark._get_organism_in_front(model, organism_22) == organism_21
    @test ALifeBenchmark._get_organism_behind(model, organism_22) == organism_21
end

@testset "Cross-Over Test" begin
    model = ALifeBenchmark.GebModel(size=2)

    organism_11 = model.grid[1, 1]
    organism_12 = model.grid[1, 2]
    organism_21 = model.grid[2, 1]
    organism_22 = model.grid[2, 2]

    organism_11.direction = 0

    ALifeBenchmark.perform!(ALifeBenchmark.CrossOver(), model, organism_11, 1)
    @test model.grid[2, 1] != organism_21
    @test model.grid[2, 1].genotype == "00"
    
    organism_12.genotype = "01" 
    organism_22.genotype = "11" 
    organism_12.direction = 0
    ALifeBenchmark.perform!(ALifeBenchmark.CrossOver(), model, organism_12, 1)
    @test model.grid[2, 2] != organism_22
    @test model.grid[2, 2].genotype == "011"

    organism_11.genotype = "011" 
    organism_12.genotype = "0011" 
    organism_11.direction = 270
    ALifeBenchmark.perform!(ALifeBenchmark.CrossOver(), model, organism_11, 1)
    @test model.grid[1, 2] != organism_12
    @test model.grid[1, 2].genotype in ["00011", "011", "01011", "011"]

    organism_11.genotype = "011" 
    model.grid[1, 2].genotype = "0011" 
    organism_11.direction = 270
    ALifeBenchmark.perform!(ALifeBenchmark.CrossOver(), model, organism_11, 1)
    @test model.grid[1, 2].genotype in ["00011", "011", "01011", "011"]
    
    organism_11.genotype = "011" 
    model.grid[1, 2].genotype = "0011" 
    organism_11.direction = 270
    ALifeBenchmark.perform!(ALifeBenchmark.CrossOver(), model, organism_11, 1)
    @test model.grid[1, 2].genotype in ["00011", "011", "01011", "011"]
end

@testset "Fight Test" begin
    model = ALifeBenchmark.GebModel(size=2)

    organism_11 = model.grid[1, 1]
    organism_12 = model.grid[1, 2]
    organism_21 = model.grid[2, 1]
    organism_22 = model.grid[2, 2]

    organism_11.direction = 0

    ALifeBenchmark.perform!(ALifeBenchmark.Fight(), model, organism_11, 1)
    @test model.grid[2, 1] === nothing
end

@testset "Turning Test" begin
    model = ALifeBenchmark.GebModel(size=2)

    organism_11 = model.grid[1, 1]
    organism_12 = model.grid[1, 2]
    organism_21 = model.grid[2, 1]
    organism_22 = model.grid[2, 2]

    organism_11.direction = 0

    ALifeBenchmark.perform!(ALifeBenchmark.TurnClockwise(), model, organism_11, 20/360)
    @test organism_11.direction == 3
    ALifeBenchmark.perform!(ALifeBenchmark.TurnClockwise(), model, organism_11, 350/360)
    @test organism_11.direction == 61
    ALifeBenchmark.perform!(ALifeBenchmark.TurnAntiClockwise(), model, organism_11, 40/360)
    @test organism_11.direction == 54
    ALifeBenchmark.perform!(ALifeBenchmark.TurnAntiClockwise(), model, organism_11, 100/360)
    @test organism_11.direction == 37
end

@testset "Moving Test" begin
    model = ALifeBenchmark.GebModel(size=2)

    organism_11 = model.grid[1, 1]
    organism_12 = model.grid[1, 2]
    organism_21 = model.grid[2, 1]
    organism_22 = model.grid[2, 2]

    organism_11.direction = 0

    @test organism_11.coordinates == (0.5, 0.5)
    
    ALifeBenchmark.perform!(ALifeBenchmark.MoveForward(), model, organism_11, 0.1)
    @test organism_11.coordinates == (0.6, 0.5)

    ALifeBenchmark.perform!(ALifeBenchmark.MoveForward(), model, organism_11, 0.5)
    @test organism_11.coordinates == (0.6, 0.5)
    
    ALifeBenchmark.kill!(model, organism_21)
    ALifeBenchmark.perform!(ALifeBenchmark.MoveForward(), model, organism_11, 0.5)
    @test organism_11.coordinates == (1.1, 0.5)
    @test model.grid[1, 1] === nothing
    @test model.grid[2, 1] === organism_11
end

@testset "Complete Action Test" begin
    Random.seed!(100)

    # build network 
    node1 = ALifeBenchmark.Node("1", [], [], [], [])
    node2 = ALifeBenchmark.Node("2", [], [], [], [])
    node3 = ALifeBenchmark.Node("3", [], [], [], [])
    node4 = ALifeBenchmark.Node("4", [], [], [], [])
    node5 = ALifeBenchmark.Node("5", [], [], [], [])
    node6 = ALifeBenchmark.Node("1112", [], [], [], [])  # move forward
    node7 = ALifeBenchmark.Node("11001", [], [], [], []) # turn clockwise
    
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
    ALifeBenchmark.activate_inputs!(network, [0, 0], [0, 0])

    # build Geb model

    model = ALifeBenchmark.GebModel(size=2)

    organism_11 = model.grid[1, 1]
    organism_12 = model.grid[1, 2]
    organism_21 = model.grid[2, 1]
    organism_22 = model.grid[2, 2]

    organism_11.network = network
    organism_11.direction = 0

    @assert organism_11.coordinates == (0.5, 0.5)

    ALifeBenchmark.perform!(model, organism_11)

    @test organism_11.coordinates == (0.5 + 0.2805599027529448, 0.5)
    @test organism_11.direction == 346
end