import Random

function collect_distribution(model_creator, step_function, print_function, num_steps, num_trials, slice_size)
    for t in 1:num_trials
        trial_id = time_ns()

        Random.seed!(0) # trial_id)

        logger = DoNothingLogger() # RunLogger(trial_id)
        model = model_creator(logger)

        for s in 1:convert(UInt64, floor(num_steps / slice_size))
            step_function(model)
            print_function(t, s, model)
        end

        save_log(logger)
    end
end
