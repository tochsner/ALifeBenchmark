module ALifeBenchmark

# export RandomModel
# export run_simulation
# 
# export History
# export get_default_history, get_detailed_history, get_by_environment
# 
# export get_total_fitness_variance, get_abiotic_variance, get_mutational_variance, get_biotic_variance, get_inherent_variance


export load_collected_data, save_calculated, add_logged_organisms

export get_genotype, get_snapshot_ids, get_time, get_snapshot, get_trials

export get_phenotype_similarity, get_most_frequent_genotypes, get_reachable_diversity
export get_reachable_fitness, get_snapshot, get_T_similarity, get_evolutionary_potential
export get_adaption_of_genotype, get_adaption_of_snapshot
export is_reproducing
export get_entropy

export _wasserstein, get_genotype_distribution

export save_offspring_log, build_genotype_graph, analyse_graph, calculate_phenotype_graph!
export GGraphData, save_graph_data, load_graph_data
export build_genotype_graph!, build_phenotype_graph!, build_neutral_networks!

# Tierra

export TierraModel
export TierrianOrganism

export SMALL_ANCESTOR, LARGE_ANCESTOR

export execute_slice!, SLICE_SIZE

export collect_distribution

export print_program


# Geb

export GebModel
export GebOrganism

export execute!


# Analysis

include("utils/organism.jl")

# include("history/types.jl")
# include("history/history.jl")# 

# include("utils/group_by.jl")# 

# include("utils/model.jl")
# include("random_model.jl")# 

# include("analysis/statistics.jl")
# include("analysis/selective_factors.jl")

include("analysis/config.jl")
include("logging/statistic_model.jl")
include("logging/collect_distribution.jl")
include("logging/logger.jl")
include("logging/run_logger.jl")


include("analysis/collected_data.jl")
include("analysis/sample_distributions.jl")

include("analysis/estimator.jl")

include("analysis/utils.jl")
include("analysis/phenotype_similarity.jl")
include("analysis/reachable_diversity.jl")
include("analysis/reachable_fitness.jl")
include("analysis/T_similarity.jl")
include("analysis/evolutionary_potential.jl")
include("analysis/level_of_adaption.jl")
include("analysis/reproducability.jl")
include("analysis/entropy.jl")

include("analysis/build_genotype_graph.jl")



# Tierra

include("tierra/config.jl")

include("tierra/instructions/search_directions.jl")

include("tierra/instructions/definitions.jl")

include("tierra/world/free_memory_block.jl")
include("tierra/mutations.jl")

include("tierra/organism/organism.jl")
include("tierra/world/tierra_model.jl")

include("tierra/statistics/statistic_model.jl")

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
include("geb/network/BFS.jl")

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

include("geb/statistics/statistic_model.jl")

include("geb/show.jl")

end
