module ALifeBenchmark

export RandomModel
export run_simulation

export History
export get_default_history, get_detailed_history, get_by_environment

export get_total_fitness_variance, get_abiotic_variance, get_mutational_variance, get_biotic_variance, get_inherent_variance

export TierraModel
export TierrianOrganism

export ANCESTOR, LARGE_ANCESTOR

export execute_slice!, _perform_instruction!

# Analysis

include("utils/organism.jl")

include("history/types.jl")
include("history/history.jl")

include("utils/group_by.jl")

include("utils/model.jl")
include("random_model.jl")

include("analysis/statistics.jl")
include("analysis/selective_factors.jl")

# Tierra

include("tierra/config.jl")

include("tierra/instructions/definitions.jl")

include("tierra/world/free_memory_block.jl")

include("tierra/organism/organism.jl")
include("tierra/world/tierra_model.jl")

include("tierra/world/memory_utils.jl")
include("tierra/world/memory.jl")
include("tierra/world/division.jl")
include("tierra/world/execution.jl")

include("tierra/organism/template_search.jl")

include("tierra/instructions/implementation.jl")

include("tierra/small_ancestor.jl")
include("tierra/large_ancestor.jl")

include("tierra/show.jl")

end