@testset "Scheduler Tests" begin

    ancestor_1 = [
        ALifeBenchmark.OR_1(),      # 1 -> c
        ALifeBenchmark.NOP_0(),
        ALifeBenchmark.NOP_0(),
        ALifeBenchmark.JMP(),       # raises error
        ALifeBenchmark.DIVIDE()    # raises error
    ]
    ancestor_2 = [
        ALifeBenchmark.OR_1(),      # 1 -> c
        ALifeBenchmark.SH_L(),      # 2 -> c
        ALifeBenchmark.DIVIDE(),    # raises error
        ALifeBenchmark.NOP_0(),
        ALifeBenchmark.NOP_0()
    ]

    model = ALifeBenchmark.TierraModel(ancestor_1)
    ALifeBenchmark.add_organism!(model, ancestor_2)
    
    ancestor_1 = model.organisms[1]
    ancestor_2 = model.organisms[2]


    # test initialization

    @test ancestor_1.key == 1
    @test ancestor_2.key == 2

    @test model.reaper_queue == [1, 2]
    @test model.organism_keys == [1, 2]
    @test model.slice_index == 1
    
    
    # run program:

    # 2: OR_1
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 0
    @test ancestor_2.c == 1
    @test model.slice_index == 2
    @test model.reaper_queue == [1, 2]

    # 1: OR_1
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 1
    @test model.slice_index == 1
    @test model.reaper_queue == [1, 2]
    
    # 2: SH_L
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 2
    @test model.reaper_queue == [1, 2]
    
    # 1: NOP_0
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 1
    @test model.reaper_queue == [1, 2]
    
    # 2: DIVIDE -> Error
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 2
    @test model.reaper_queue == [2, 1]
    
    # 1: NOP_0
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 1
    @test model.reaper_queue == [2, 1]
  
    # 2: NOP_0
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 2
    @test model.reaper_queue == [2, 1]

    # 1: JMP -> Error
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 1
    @test model.reaper_queue == [1, 2]
  
    # 2: NOP_0
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 2
    @test model.reaper_queue == [1, 2]
    
    # 1: DIVIDE -> Error
    ALifeBenchmark.execute_slice!(model, slice_size = 1)
    @test ancestor_1.c == 1
    @test ancestor_2.c == 2
    @test model.slice_index == 1
    @test model.reaper_queue == [1, 2]
end