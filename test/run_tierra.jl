using ALifeBenchmark
using Printf
import Random

Random.seed!(1234)

ANCESTOR = LARGE_ANCESTOR
NUM_SLICES = 100_000_000_000

model = TierraModel(ANCESTOR)

for i in 1:NUM_SLICES
    execute_slice!(model)

    if i % 1_000_000 == 0
        @printf "%i: Memory in use: %2i %% \t Num of organisms: %i \t Num of free blocks: %i \n" i round(Int64, 100*model.used_memory / model.memory_size) length(model.organism_keys) length(model.free_blocks)
    end

    if i % 20_000_000 == 0
        log_model(model, i)
    end
end

log_model(model)
