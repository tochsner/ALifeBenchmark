@testset "Free Memory Blocks Tests" begin

    model = ALifeBenchmark.TierraModel(
        ALifeBenchmark.TierrianInstruction[
            ALifeBenchmark.NOP_0()
        ]
    )

    
    # test size of allocated memory
    
    memory_allocated::UInt64 = 1

    @test model.free_blocks == [
        ALifeBenchmark.FreeMemoryBlock(1, 2^16-1)
    ]
    @test model.used_memory == memory_allocated

    size::UInt64 = 0
    result::Int64 = 0

    for _ in 1:10_000
        # first: allocate some memory
        
        size = rand(1:10000)
        
        result = ALifeBenchmark.allocate_free_memory!(model, size)
        
        if result != -1
            memory_allocated += size
        end
        
        @test model.used_memory == memory_allocated
        
        
        # second: try to clear some memory

        size = rand(1:10000)

        memory_allocated -= ALifeBenchmark.clear_memory!(model, rand(0:(2^16-size-1)), size)
        @test model.used_memory == memory_allocated


        # test free blocks

        free_block_sum = 0
        for free_block in model.free_blocks
            free_block_sum += free_block.length
        end
        @test free_block_sum == ALifeBenchmark.get_free_memory_size(model)
    end


    # test if free blocks are exclusive and non-neighboring

    free = falses(2^16)

    non_exclusive = false
    no_neighbors = false

    for free_block in model.free_blocks
        for i in free_block.start_address:(free_block.start_address - 1 + free_block.length)
            if free[i]
                non_exclusive = true
            end
            free[i] = true
        end

        if 0 < free_block.start_address
            if free[free_block.start_address - 1]
                println(free_block)
                no_neighbors = true
            end
        end
        if free_block.start_address + free_block.length < 2^16
            if free[free_block.start_address + free_block.length]
                println(free_block)
                no_neighbors = true
            end
        end
    end

    @test !non_exclusive
    @test !no_neighbors
end