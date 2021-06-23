@testset "IsOnSide Tests" begin
    model = ALifeBenchmark.GebModel()
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (0, 0), 0) == true 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (0, 0), 90) == false 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (0, 0), 180) == false 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (0, 0), 270) == true 
    
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (1, 0), 0) == true 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (1, 0), 90) == true 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (1, 0), 180) == false 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheLeft(), model, (1, -1), (1, 0), 270) == true 

    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (0, 0), 0) == false 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (0, 0), 90) == true 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (0, 0), 180) == true 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (0, 0), 270) == false 
     
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (1, 0), 0) == false 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (1, 0), 90) == false 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (1, 0), 180) == true 
    @test ALifeBenchmark._is_on_side(ALifeBenchmark.ToTheRight(), model, (1, -1), (1, 0), 270) == false 
end

@testset "Neighbors Tests" begin
    # the model we build:

    """
    ##_____
    _____#_
    ___#___
    ___#_#_
    _#_____
    _______
    ___#___
    """

    @assert ALifeBenchmark.INFLUENCE_RADIUS == 2

    model = ALifeBenchmark.GebModel(size=7)

    ALifeBenchmark.kill!(model, model.grid[1, 2])
    ALifeBenchmark.kill!(model, model.grid[1, 3])
    ALifeBenchmark.kill!(model, model.grid[1, 4])
    ALifeBenchmark.kill!(model, model.grid[1, 5])
    ALifeBenchmark.kill!(model, model.grid[1, 6])
    ALifeBenchmark.kill!(model, model.grid[1, 7])
    
    ALifeBenchmark.kill!(model, model.grid[2, 2])
    ALifeBenchmark.kill!(model, model.grid[2, 3])
    ALifeBenchmark.kill!(model, model.grid[2, 4])
    ALifeBenchmark.kill!(model, model.grid[2, 6])
    ALifeBenchmark.kill!(model, model.grid[2, 7])
    
    ALifeBenchmark.kill!(model, model.grid[3, 1])
    ALifeBenchmark.kill!(model, model.grid[3, 2])
    ALifeBenchmark.kill!(model, model.grid[3, 3])
    ALifeBenchmark.kill!(model, model.grid[3, 4])
    ALifeBenchmark.kill!(model, model.grid[3, 5])
    ALifeBenchmark.kill!(model, model.grid[3, 6])
    ALifeBenchmark.kill!(model, model.grid[3, 7])
    
    ALifeBenchmark.kill!(model, model.grid[4, 1])
    ALifeBenchmark.kill!(model, model.grid[4, 2])
    ALifeBenchmark.kill!(model, model.grid[4, 5])
    ALifeBenchmark.kill!(model, model.grid[4, 6])

    ALifeBenchmark.kill!(model, model.grid[5, 1])
    ALifeBenchmark.kill!(model, model.grid[5, 2])
    ALifeBenchmark.kill!(model, model.grid[5, 3])
    ALifeBenchmark.kill!(model, model.grid[5, 4])
    ALifeBenchmark.kill!(model, model.grid[5, 5])
    ALifeBenchmark.kill!(model, model.grid[5, 6])
    ALifeBenchmark.kill!(model, model.grid[5, 7])
    
    ALifeBenchmark.kill!(model, model.grid[6, 1])
    ALifeBenchmark.kill!(model, model.grid[6, 3])
    ALifeBenchmark.kill!(model, model.grid[6, 5])
    ALifeBenchmark.kill!(model, model.grid[6, 6])
    ALifeBenchmark.kill!(model, model.grid[6, 7])
    
    ALifeBenchmark.kill!(model, model.grid[7, 1])
    ALifeBenchmark.kill!(model, model.grid[7, 2])
    ALifeBenchmark.kill!(model, model.grid[7, 3])
    ALifeBenchmark.kill!(model, model.grid[7, 4])
    ALifeBenchmark.kill!(model, model.grid[7, 5])
    ALifeBenchmark.kill!(model, model.grid[7, 6])
    ALifeBenchmark.kill!(model, model.grid[7, 7])

    @test length(model.organisms) == 8

    model.grid[4, 4].direction = 90

    all = ALifeBenchmark._get_neighbors(ALifeBenchmark.BothSides(), model, model.grid[4, 4])

    @test length(all) == 4
    @test model.grid[2, 5] in all
    @test model.grid[4, 3] in all
    @test model.grid[6, 2] in all
    @test model.grid[6, 4] in all

    all = ALifeBenchmark._get_neighbors(ALifeBenchmark.BothSides(), model, model.grid[1, 1])

    @test length(all) == 2
    @test model.grid[2, 1] in all
    @test model.grid[6, 2] in all


    left = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheLeft(), model, model.grid[4, 4])

    @test length(left) == 2
    @test model.grid[4, 3] in left
    @test model.grid[2, 5] in left

    right = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheRight(), model, model.grid[4, 4])

    @test length(right) == 2
    @test model.grid[6, 2] in right
    @test model.grid[6, 4] in right


    model.grid[4, 4].direction = 40

    left = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheLeft(), model, model.grid[4, 4])

    @test length(left) == 3
    @test model.grid[2, 5] in left
    @test model.grid[4, 3] in left
    @test model.grid[6, 2] in left

    right = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheRight(), model, model.grid[4, 4])

    @test length(right) == 1
    @test model.grid[6, 4] in right


    model.grid[1, 1].direction = 220

    left = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheLeft(), model, model.grid[1, 1])

    @test length(left) == 1
    @test model.grid[2, 1] in left
    
    right = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheRight(), model, model.grid[1, 1])
    
    @test length(right) == 1
    @test model.grid[6, 2] in right
end

@testset "Inputs Test" begin
    # the model we build:

    """
    ##_____
    _____#_
    ___#___
    ___#_#_
    _#_____
    _______
    ___#___
    """

    model = ALifeBenchmark.GebModel(size=7)

    ALifeBenchmark.kill!(model, model.grid[1, 2])
    ALifeBenchmark.kill!(model, model.grid[1, 3])
    ALifeBenchmark.kill!(model, model.grid[1, 4])
    ALifeBenchmark.kill!(model, model.grid[1, 5])
    ALifeBenchmark.kill!(model, model.grid[1, 6])
    ALifeBenchmark.kill!(model, model.grid[1, 7])
    
    ALifeBenchmark.kill!(model, model.grid[2, 2])
    ALifeBenchmark.kill!(model, model.grid[2, 3])
    ALifeBenchmark.kill!(model, model.grid[2, 4])
    ALifeBenchmark.kill!(model, model.grid[2, 6])
    ALifeBenchmark.kill!(model, model.grid[2, 7])
    
    ALifeBenchmark.kill!(model, model.grid[3, 1])
    ALifeBenchmark.kill!(model, model.grid[3, 2])
    ALifeBenchmark.kill!(model, model.grid[3, 3])
    ALifeBenchmark.kill!(model, model.grid[3, 4])
    ALifeBenchmark.kill!(model, model.grid[3, 5])
    ALifeBenchmark.kill!(model, model.grid[3, 6])
    ALifeBenchmark.kill!(model, model.grid[3, 7])
    
    ALifeBenchmark.kill!(model, model.grid[4, 1])
    ALifeBenchmark.kill!(model, model.grid[4, 2])
    ALifeBenchmark.kill!(model, model.grid[4, 5])
    ALifeBenchmark.kill!(model, model.grid[4, 6])

    ALifeBenchmark.kill!(model, model.grid[5, 1])
    ALifeBenchmark.kill!(model, model.grid[5, 2])
    ALifeBenchmark.kill!(model, model.grid[5, 3])
    ALifeBenchmark.kill!(model, model.grid[5, 4])
    ALifeBenchmark.kill!(model, model.grid[5, 5])
    ALifeBenchmark.kill!(model, model.grid[5, 6])
    ALifeBenchmark.kill!(model, model.grid[5, 7])
    
    ALifeBenchmark.kill!(model, model.grid[6, 1])
    ALifeBenchmark.kill!(model, model.grid[6, 3])
    ALifeBenchmark.kill!(model, model.grid[6, 5])
    ALifeBenchmark.kill!(model, model.grid[6, 6])
    ALifeBenchmark.kill!(model, model.grid[6, 7])
    
    ALifeBenchmark.kill!(model, model.grid[7, 1])
    ALifeBenchmark.kill!(model, model.grid[7, 2])
    ALifeBenchmark.kill!(model, model.grid[7, 3])
    ALifeBenchmark.kill!(model, model.grid[7, 4])
    ALifeBenchmark.kill!(model, model.grid[7, 5])
    ALifeBenchmark.kill!(model, model.grid[7, 6])
    ALifeBenchmark.kill!(model, model.grid[7, 7])

    @test length(model.organisms) == 8


    model.grid[4, 4].direction = 90

    all = ALifeBenchmark._get_neighbors(ALifeBenchmark.BothSides(), model, model.grid[4, 4])

    @test length(all) == 4
    @test model.grid[2, 5] in all
    @test model.grid[4, 3] in all
    @test model.grid[6, 2] in all
    @test model.grid[6, 4] in all

    all = ALifeBenchmark._get_neighbors(ALifeBenchmark.BothSides(), model, model.grid[1, 1])

    @test length(all) == 2
    @test model.grid[2, 1] in all
    @test model.grid[6, 2] in all


    left = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheLeft(), model, model.grid[4, 4])

    @test length(left) == 2
    @test model.grid[4, 3] in left
    @test model.grid[2, 5] in left

    right = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheRight(), model, model.grid[4, 4])

    @test length(right) == 2
    @test model.grid[6, 2] in right
    @test model.grid[6, 4] in right


    model.grid[4, 4].direction = 40

    left = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheLeft(), model, model.grid[4, 4])

    @test length(left) == 3
    @test model.grid[2, 5] in left
    @test model.grid[4, 3] in left
    @test model.grid[6, 2] in left

    right = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheRight(), model, model.grid[4, 4])

    @test length(right) == 1
    @test model.grid[6, 4] in right


    model.grid[1, 1].direction = 220

    left = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheLeft(), model, model.grid[1, 1])

    @test length(left) == 1
    @test model.grid[2, 1] in left
    
    right = ALifeBenchmark._get_neighbors(ALifeBenchmark.ToTheRight(), model, model.grid[1, 1])
    
    @test length(right) == 1
    @test model.grid[6, 2] in right
end