@testset "Modulo Test" begin
    @test ALifeBenchmark.mod_1(1, 10) == 1
    @test ALifeBenchmark.mod_1(0, 10) == 10
    @test ALifeBenchmark.mod_1(10, 10) == 10
    @test ALifeBenchmark.mod_1(15, 10) == 5
    @test ALifeBenchmark.mod_1(-2, 10) == 8
end