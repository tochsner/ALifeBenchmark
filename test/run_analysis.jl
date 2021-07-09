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
    savefig("$name$trial_id")
end

function save_result(times, values, name, trial_id)
    serialize("$name$trial_id", (times, values))
end

"""
STATISTICS
"""

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
	current_reachable_fitness = get_reachable_fitness(data, snapshot_id, 0.0001, 200, 5000)
        current_time = get_time(get_snapshot(data, snapshot_id))

        @info "RF $current_time \t $current_reachable_fitness"

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

        @info "$current_time \t $current_distance"

        divergences[i] = current_distance
        times[i] = current_time
    end

    return (times, divergences)
end

function reachable_diversity(trial_id)
    @info "REACHABLE DIVERSITY:"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    reachable_diversities = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_time = get_time(get_snapshot(data, snapshot_id))
        current_diversity = get_reachable_diversity(data, snapshot_id, 0.01, 50, 500)

        @info "$current_time \t $current_diversity"

        reachable_diversities[i] = current_diversity
        times[i] = current_time
    end

    return (times, reachable_diversities)
end

function evolutionary_potential(trial_id)
    @info "EVOLUTIONARY POTENTIAL:"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    evolutionary_potentials = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_time = get_time(get_snapshot(data, snapshot_id))
        current_potential = get_evolutionary_potential(data, snapshot_id, 600_000, 0.01, 50, 500)

        @info "$current_time \t $current_potential"

        evolutionary_potentials[i] = current_potential
        times[i] = current_time
    end

    return (times, evolutionary_potentials)
end

trial_id = "12433992799852588"
name = "EvolutionaryPotential"

# add_logged_organisms(data, trial_id)

times, values = evolutionary_potential(trial_id)
plot_result(times, values, name, trial_id)
save_result(times, values, name, trial_id)

save_calculated(data)
