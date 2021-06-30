import Random

function collect_distribution(model_creator, step_function, print_function, num_steps, num_trials)
    for t in 1:num_trials
        trial_id = time_ns()

        Random.seed!(1)

        logger = RunLogger(trial_id)
        model = model_creator(logger)

        for s in 1:convert(UInt64, floor(num_steps / SLICE_SIZE))
            step_function(model)
            print_function(t, s, model)
        end

        save_log(logger)
    end
end
