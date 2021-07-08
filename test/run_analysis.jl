using ALifeBenchmark
import SharedArrays.SharedArray
using Plots
using Serialization
import Base.Threads.@threads
using StringDistances: Levenshtein

using Serialization

data = load_collected_data(load_logged_organisms = false)


function plot_result(times, values, name, trial_id)
    plot(times, values, 
            title = "",
            label = "",
            xguide = "Time",
            yguide = name,
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            dpi = 1000)
    savefig("$name_$trial_id")
end

function save_result(times, values, name, trial_id)
    serialize("$name_$trial_id", (times, values))
end

function level_of_adaption(trial_id)
    @info "LEVEL OF ADAPTION"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    last_snaphot_id = snapshot_ids[end]

    adaptions = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        adaption = get_adaption_of_snapshot(data, last_snaphot_id, snapshot_id, 0.1, 20, 200)
        time = get_time(get_snapshot(data, snapshot_id))

        @info "$time \t $adaption"

        adaptions[i] = adaption
        times[i] = time
    end

    return (times, adaptions)
end

function reachable_fitness(trial_id)
    @info "REACHABLE FITNESS"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    reachable_fitness = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_reachable_fitness = get_reachable_fitness(data, snapshot_id, 0.01, 50, 200)
        current_time = get_time(get_snapshot(data, snapshot_id))

        @info "$current_time \t $current_reachable_fitness"

        reachable_fitness[i] = current_reachable_fitness
        times[i] = current_time
    end

    return (times, reachable_fitness)
end

function population_divergence(trial_id)
    @info "POPULATION DIVERGENCE:"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    last_snaphot_id = snapshot_ids[end]
    last_snapshot = get_snapshot(data, last_snaphot_id)
    last_distribution = get_genotype_distribution(last_snapshot)

    divergences = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_snapshot = get_snapshot(data, snapshot_id)
        current_time = get_time(current_snapshot)
        
        current_distribution = get_genotype_distribution(current_snapshot)
        current_distance = _wasserstein(last_distribution, current_distribution, Levenshtein())

        @info "$current_distance \t $current_distance"

        divergences[i] = current_distance
        times[i] = current_time
    end

    return (times, divergences)
end

trial_id = "12433992799852588"
name = "Level of Adaption"

times, values = level_of_adaption(trial_id)
plot_result(times, values, name, trial_id)
save_result(times, values, name, trial_id)

save_calculated(data)
