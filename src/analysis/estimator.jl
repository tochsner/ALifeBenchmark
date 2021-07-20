function estimate(get_sample, rel_tolerance, min_samples, max_samples; print_progress = false, return_all_samples = false)
    estimate(get_sample, _get_new_estimation, _get_estimation_variance, rel_tolerance, min_samples, max_samples, print_progress = print_progress, return_all_samples = return_all_samples)
end

function _get_new_estimation(sample::Number, previous_samples, previous_estimation)
    if length(previous_samples) == 0
        sample
    else
        (sum(previous_samples) + sample) / (length(previous_samples) + 1)
    end
end
function _get_new_estimation(sample::Vector, previous_samples, previous_estimation)
    if length(previous_samples) == 0
        mean(sample)
    else
        (sum(previous_samples) + sum(sample)) / (length(previous_samples) + length(sample))
    end
end

function _get_estimation_variance(sample, previous_samples, estimate)
    if length(previous_samples) + length(sample) <= 1 return Inf end

    all_samples = [previous_samples ; sample]
    
    n = length(all_samples)
    mean = sum(all_samples) / n

    return 1 / (n * (n - 1)) * sum([(s - mean)^2 for s in all_samples]) / max(EPS, mean^2)  
end

function estimate(get_sample, get_new_estimation, get_estimation_variance, tolerance, min_samples, max_samples; print_progress = false, return_all_samples = false)
    previous_samples = []
    num_samples = 0

    estimation = 0
    estimation_variance = 2*tolerance
    
    while (num_samples <= min_samples || tolerance < estimation_variance) && num_samples <= max_samples
        try
            new_sample = get_sample()

            estimation = get_new_estimation(new_sample, previous_samples, estimation)
            estimation_variance = get_estimation_variance(new_sample, previous_samples, estimation)

            _add_sample!(previous_samples, new_sample)
            num_samples = length(previous_samples)

            if print_progress
                println("$estimation_variance \t $new_sample \t $estimation")
            end
        catch e
            if !isa(e, SimulationExpection)
                rethrow(e)
            end
        end
    end

    if return_all_samples
        return estimation, previous_samples
    else
        return estimation
    end
end

_add_sample!(previous_samples::Vector, new_sample) = push!(previous_samples, new_sample)
_add_sample!(previous_samples::Vector, new_sample::Vector) = append!(previous_samples, new_sample)
