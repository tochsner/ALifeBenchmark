using ALifeBenchmark
using Printf
using Serialization
using Dates
import Random
using Profile

create_model(logger) = GebModel(logger)
function print_function(trial, step, model)
    if step % 1_000 == 0
        @printf "%i %i (%s): Num of organisms: %i \n" trial step Dates.format(now(), "HH:MM:SS") length(model.organisms)
    end
end

const NUM_ITERATIONS = 1e7
const NUM_TRIALS = 1

collect_distribution(create_model, execute!, print_function, NUM_ITERATIONS, NUM_TRIALS, 1)