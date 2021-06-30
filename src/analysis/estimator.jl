function estimate(get_sample_estimation, rel_tolerance, min_samples, max_samples, samples_per_step = 1; print_progress = false)
    merge_estimation(sample_estimation, estimation, num_samples) = (estimation*num_samples + sample_estimation) / (num_samples + samples_per_step)
    get_change(estimation, old_estimation) = abs(old_estimation - estimation) / max(EPS, old_estimation)

    estimate(get_sample_estimation, merge_estimation, get_change, 0, rel_tolerance, min_samples, max_samples, samples_per_step, print_progress = print_progress)
end

function estimate(get_sample_estimation, merge_estimation, get_change, initial_estimation, tolerance, min_samples, max_samples, samples_per_step = 1; print_progress = false)
    estimation = deepcopy(initial_estimation)

    num_samples = 0
    change = 2*tolerance

    while (num_samples <= min_samples || tolerance < change) && num_samples <= max_samples
        old_estimation = deepcopy(estimation)
        
        sample_estimation = get_sample_estimation()
        estimation = merge_estimation(sample_estimation, estimation, num_samples)
        
        change = get_change(estimation, old_estimation)
        num_samples += samples_per_step

        if print_progress
            println(change)
        end
    end

    return estimation
end