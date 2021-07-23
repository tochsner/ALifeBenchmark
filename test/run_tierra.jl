using ALifeBenchmark
using Printf
using Serialization
using Dates
import Random
using Profile

id = string(time_ns())

ANCESTOR = LARGE_ANCESTOR
const NUM_ITERATIONS = 1e10

create_model(logger) = TierraModel(ANCESTOR, logger)
function print_function(trial, step, model)
    if step % 1e7 == 0
        @info "$id \t $step \t $(step / NUM_ITERATIONS)"
        @printf "%i %i (%s): Memory in use: %2i %% \t Num of organisms: %i \t Num of free blocks: %i\n" trial step Dates.format(now(), "HH:MM:SS")  round(Int64, 100*model.used_memory / model.memory_size) length(model.organism_keys) length(model.free_blocks)
    end
end

const NUM_TRIALS = 1

collect_distribution(create_model, execute_slice!, print_function, NUM_ITERATIONS, NUM_TRIALS, SLICE_SIZE)