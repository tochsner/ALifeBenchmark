using ALifeBenchmark
using Printf
using Serialization
using Dates
import Random
using Profile
using PProf

const NUM_ITERATIONS = 1e6
const NUM_TRIALS = 1

create_model(logger) = GebModel(logger)
function print_function(trial, step, model)
    if step % 500 == 0
        @info "$step \t $(step / NUM_ITERATIONS) \t $(length(model.organisms))"
    end
end

collect_distribution(create_model, execute!, print_function, NUM_ITERATIONS, NUM_TRIALS, 1)
