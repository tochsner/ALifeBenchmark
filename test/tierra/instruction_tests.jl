@testset "Instruction Tests" begin
    model = ALifeBenchmark.TierraModel(
        ALifeBenchmark.TierrianInstruction[
        ALifeBenchmark.NOP_0()
        ])

    ancestor = model.organisms[model.organism_keys[1]]    

    # NOP
    ALifeBenchmark.apply!(ALifeBenchmark.NOP_0(), ancestor, model)
    @test sum(model.memory) == 0
    ALifeBenchmark.apply!(ALifeBenchmark.NOP_1(), ancestor, model)
    @test sum(model.memory) == 0

    # OR
    ALifeBenchmark.apply!(ALifeBenchmark.OR_1(), ancestor, model)
    @test ancestor.c == 1
    ALifeBenchmark.apply!(ALifeBenchmark.OR_1(), ancestor, model)
    @test ancestor.c == 1
    
    # Shift
    ALifeBenchmark.apply!(ALifeBenchmark.SH_L(), ancestor, model)
    @test ancestor.c == 2
    ALifeBenchmark.apply!(ALifeBenchmark.SH_L(), ancestor, model)
    @test ancestor.c == 4
end