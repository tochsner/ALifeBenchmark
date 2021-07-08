@testset "Add Sample Tests" begin
    previous_samples = []
    new_sample = 5
    ALifeBenchmark._add_sample!(previous_samples, new_sample)
    @test previous_samples == [5]
    
    previous_samples = [3]
    new_sample = 5
    ALifeBenchmark._add_sample!(previous_samples, new_sample)
    @test previous_samples == [3, 5]

    previous_samples = []
    new_sample = [1, 2]
    ALifeBenchmark._add_sample!(previous_samples, new_sample)
    @test previous_samples == [1, 2]
    
    previous_samples = [3]
    new_sample = [1, 2]
    ALifeBenchmark._add_sample!(previous_samples, new_sample)
    @test previous_samples == [3, 1, 2]
end

@testset "New Estimation Tests" begin
    @test ALifeBenchmark.get_new_estimation(5, [], nothing) == 5
    @test ALifeBenchmark.get_new_estimation(5, [1], 1) == 3
    @test ALifeBenchmark.get_new_estimation(4, [2, 3], 2.5) == 3
    
    @test ALifeBenchmark.get_new_estimation([5], [], nothing) == 5
    @test ALifeBenchmark.get_new_estimation([1, 3], [], nothing) == 2
    @test ALifeBenchmark.get_new_estimation([5], [1], 1) == 3
    @test ALifeBenchmark.get_new_estimation([2, 3], [1], 1) == 2
    @test ALifeBenchmark.get_new_estimation([4], [3, 5], 4) == 4
    @test ALifeBenchmark.get_new_estimation([3, 5], [1, 7], 4) == 4
end

@testset "Estimation Variance Tests" begin
    @test ALifeBenchmark.get_estimation_variance(5, []) == Inf
    @test ALifeBenchmark.get_estimation_variance([5], []) == Inf
    @test ALifeBenchmark.get_estimation_variance([], []) == Inf
    
    @test ALifeBenchmark.get_estimation_variance(2, [2]) == 0
    @test ALifeBenchmark.get_estimation_variance([2], [2]) == 0
    @test ALifeBenchmark.get_estimation_variance(2, [2, 2]) == 0
    @test ALifeBenchmark.get_estimation_variance([2, 2], [2, 2]) == 0

    @test ALifeBenchmark.get_estimation_variance(2, [2, 5]) == 1
    @test ALifeBenchmark.get_estimation_variance(11, [2, 2, 5]) == 54 / 12
    @test ALifeBenchmark.get_estimation_variance([2, 11], [2, 5]) == 54 / 12
end