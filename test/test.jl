using ALifeBenchmark

"""
rm = RandomModel(1000, 10)

results = run_simulation(rm, 100)

history = History(results)

println(get_total_fitness_variance(history))
println(get_biotic_variance(history))
println(get_abiotic_variance(history))
println(get_mutational_variance(history))
println(get_inherent_variance(history))
"""

using Profile
using Printf

model = TierraModel(LARGE_ANCESTOR)

function f()
    for _ in 1:1_000_000
        execute_slice!(model)
    end
end

f()

@profile f()

"""
while true

    break
    #print(model)
    @printf "Memory in use: %2i %% \t Num of organisms: %i \t Num of free blocks: %i \n" round(Int64, 100*model.used_memory / model.memory_size) length(model.organism_keys) length(model.free_blocks)
    # readline()
end
"""
