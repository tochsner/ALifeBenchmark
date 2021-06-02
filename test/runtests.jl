import Random

import ALifeBenchmark
using Test

Random.seed!(1234)
    
include("instruction_tests.jl")
include("ancestor_tests.jl")
include("memory_utils_tests.jl")
include("memory_tests.jl")
