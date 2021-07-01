@testset "Memory Utils Tests" begin
    @test ALifeBenchmark._determine_overlap(0, 1, 0, 1) == ALifeBenchmark.ExactMatch()
    @test ALifeBenchmark._determine_overlap(0, 10, 0, 10) == ALifeBenchmark.ExactMatch()
    @test ALifeBenchmark._determine_overlap(199, 20008, 199, 20008) == ALifeBenchmark.ExactMatch()
    
    @test ALifeBenchmark._determine_overlap(0, 1, 1, 1) == ALifeBenchmark.LeftNeighbor()
    @test ALifeBenchmark._determine_overlap(0, 10, 10, 20) == ALifeBenchmark.LeftNeighbor()
    @test ALifeBenchmark._determine_overlap(2245, 100, 2345, 20) == ALifeBenchmark.LeftNeighbor()
    
    @test ALifeBenchmark._determine_overlap(1, 1, 0, 1) == ALifeBenchmark.RightNeighbor()
    @test ALifeBenchmark._determine_overlap(10, 1, 0, 10) == ALifeBenchmark.RightNeighbor()
    @test ALifeBenchmark._determine_overlap(2000, 100, 1000, 1000) == ALifeBenchmark.RightNeighbor()
    
    @test ALifeBenchmark._determine_overlap(0, 1, 2, 1) == ALifeBenchmark.Disjunct()
    @test ALifeBenchmark._determine_overlap(0, 10, 100, 20) == ALifeBenchmark.Disjunct()
    @test ALifeBenchmark._determine_overlap(2983, 10276, 23, 50) == ALifeBenchmark.Disjunct()
    
    @test ALifeBenchmark._determine_overlap(1, 8, 0, 10) == ALifeBenchmark.Within()
    @test ALifeBenchmark._determine_overlap(5, 1, 0, 10) == ALifeBenchmark.Within()
    @test ALifeBenchmark._determine_overlap(500, 207, 213, 14320) == ALifeBenchmark.Within()
    
    @test ALifeBenchmark._determine_overlap(0, 1, 0, 10) == ALifeBenchmark.WithinFromStart()
    @test ALifeBenchmark._determine_overlap(0, 8, 0, 10) == ALifeBenchmark.WithinFromStart()
    @test ALifeBenchmark._determine_overlap(293, 208, 293, 1340) == ALifeBenchmark.WithinFromStart()
    
    @test ALifeBenchmark._determine_overlap(9, 1, 0, 10) == ALifeBenchmark.WithinToEnd()
    @test ALifeBenchmark._determine_overlap(2, 8, 0, 10) == ALifeBenchmark.WithinToEnd()
    @test ALifeBenchmark._determine_overlap(300, 200, 200, 300) == ALifeBenchmark.WithinToEnd()

    @test ALifeBenchmark._determine_overlap(0, 10, 1, 8) == ALifeBenchmark.CompleteOverlap()
    @test ALifeBenchmark._determine_overlap(0, 10, 5, 1) == ALifeBenchmark.CompleteOverlap()
    @test ALifeBenchmark._determine_overlap(213, 14320, 500, 207) == ALifeBenchmark.CompleteOverlap()
    
    @test ALifeBenchmark._determine_overlap(0, 10, 5, 5) == ALifeBenchmark.LeftOverlap()
    @test ALifeBenchmark._determine_overlap(0, 15, 10, 10) == ALifeBenchmark.LeftOverlap()
    @test ALifeBenchmark._determine_overlap(0, 15, 14, 10) == ALifeBenchmark.LeftOverlap()
    @test ALifeBenchmark._determine_overlap(325, 123, 425, 200) == ALifeBenchmark.LeftOverlap()
    
    @test ALifeBenchmark._determine_overlap(0, 10, 0, 5) == ALifeBenchmark.RightOverlap()
    @test ALifeBenchmark._determine_overlap(5, 10, 0, 10) == ALifeBenchmark.RightOverlap()
    @test ALifeBenchmark._determine_overlap(9, 10, 0, 10) == ALifeBenchmark.RightOverlap()
    @test ALifeBenchmark._determine_overlap(239, 1000, 0, 1000) == ALifeBenchmark.RightOverlap()
end