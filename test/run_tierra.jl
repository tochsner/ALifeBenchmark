using ALifeBenchmark
using Printf
import Random

Random.seed!(1234)

ANCESTOR = LARGE_ANCESTOR
NUM_SLICES = 10_000_000

model = TierraModel(ANCESTOR)

for i in 1:NUM_SLICES
    execute_slice!(model)

    if i % 1_000_000 == 0
        @printf "Memory in use: %2i %% \t Num of organisms: %i \t Num of free blocks: %i \n" round(Int64, 100*model.used_memory / model.memory_size) length(model.organism_keys) length(model.free_blocks)
    end
end

log_model(model)
