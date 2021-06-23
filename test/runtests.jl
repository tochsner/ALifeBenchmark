import Random

import ALifeBenchmark
using Test

Random.seed!(1234)

include("geb/inputs_tests.jl")
include("geb/actions_tests.jl")
include("geb/network_tests.jl")
include("geb/nodes_tests.jl")
include("geb/rules_tests.jl")
include("geb/utils_tests.jl")

include("Tierra/scheduler_tests.jl")
include("Tierra/instruction_tests.jl")
include("Tierra/ancestor_tests.jl")
include("Tierra/memory_utils_tests.jl")
include("Tierra/memory_tests.jl")
