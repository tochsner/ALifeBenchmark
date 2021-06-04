import Random

import ALifeBenchmark
using Test

Random.seed!(1234)

include("Tierra/scheduler_tests.jl")
include("Tierra/instruction_tests.jl")
include("Tierra/ancestor_tests.jl")
include("Tierra/memory_utils_tests.jl")
include("Tierra/memory_tests.jl")
