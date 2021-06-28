@testset "Ancestor Tests" begin
    @assert ALifeBenchmark.MUTATE == false
    
    model = ALifeBenchmark.TierraModel(ALifeBenchmark.LARGE_ANCESTOR)

    for _ in 1:900
        ALifeBenchmark.execute_slice!(model, slice_size = 1)
    end

    len_ancestor = length(ALifeBenchmark.LARGE_ANCESTOR)
    @test model.memory[1:len_ancestor] == model.memory[len_ancestor+1:2*len_ancestor] || model.memory[1:len_ancestor] == model.memory[2^16 - len_ancestor + 1:2^16]

    model = ALifeBenchmark.TierraModel(ALifeBenchmark.SMALL_ANCESTOR)

    for _ in 1:300
        ALifeBenchmark.execute_slice!(model, slice_size = 1)
    end

    len_ancestor = length(ALifeBenchmark.SMALL_ANCESTOR)
    @test model.memory[1:len_ancestor] == model.memory[len_ancestor+1:2*len_ancestor] || model.memory[1:len_ancestor] == model.memory[2^16 - len_ancestor + 1:2^16]
end