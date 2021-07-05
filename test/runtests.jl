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

"""
include("tierra/scheduler_tests.jl")
include("tierra/instruction_tests.jl")
include("tierra/ancestor_tests.jl")
include("tierra/memory_utils_tests.jl")
include("tierra/memory_tests.jl")
"""