module ALifeBenchmark

export RandomModel
export run_simulation

export History
export get_default_history, get_detailed_history, get_by_environment

export get_total_fitness_variance, get_abiotic_variance, get_mutational_variance, get_biotic_variance, get_inherent_variance

# Tierra

export TierraModel
export TierrianOrganism

export SMALL_ANCESTOR, LARGE_ANCESTOR

export execute_slice!

export log_model

# Geb

export GebModel
export GebOrganism

export execute!


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

include("tierra/instructions/search_directions.jl")

include("tierra/instructions/definitions.jl")

include("tierra/world/free_memory_block.jl")
include("tierra/mutations.jl")

include("tierra/organism/organism.jl")
include("tierra/world/tierra_model.jl")

include("tierra/world/memory_utils.jl")
include("tierra/world/memory.jl")
include("tierra/world/division.jl")
include("tierra/world/execution.jl")

include("tierra/instructions/template_search.jl")

include("tierra/instructions/implementation.jl")

include("tierra/small_ancestor.jl")
include("tierra/large_ancestor.jl")

include("tierra/show.jl")
include("tierra/logging.jl")

# Geb

include("geb/config.jl")

include("geb/utils.jl")

include("geb/network/rule.jl")
include("geb/network/node.jl")
include("geb/network/network.jl")

include("geb/network/rule_decoding.jl")
include("geb/network/development.jl")

include("geb/organism/organism.jl")
include("geb/model.jl")

include("geb/network/activation_propagation.jl")

include("geb/grid_utils.jl")
include("geb/organism/mutation.jl")
include("geb/organism/actions.jl")
include("geb/organism/input_routing.jl")

include("geb/execution.jl")

include("geb/show.jl")

end
