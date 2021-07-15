using ALifeBenchmark
import SharedArrays.SharedArray
using Plots
using Serialization
import Base.Threads.@threads
using StringDistances: Levenshtein
using Measures

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
            size = (900, 600),
            margin = 10mm,
            dpi = 1000)
    savefig("$name$trial_id")
end
function plot_result(times_1, times_2, values, name, trial_id)
    plot(times_1, times_2, 
            marker_z  = values,
            title = "",
            label = "",
            xguide = "Time",
            yguide = name,
            seriestype = :scatter,
            markersize = 3,
            markerstrokewidth = 0,
            size = (900, 600),
            margin = 10mm,
            dpi = 1000)
    savefig("$name$trial_id")
end

function save_result(data, name, trial_id)
    serialize("$name$trial_id", data)
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

    count = Threads.Atomic{Int}(0)
    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        adaption = get_adaption_of_snapshot(data, last_snaphot_id, snapshot_id, 0.001, 50, 500)
        time = get_time(get_snapshot(data, snapshot_id))

        Threads.atomic_add!(count, 1)
        @info "$count[] \t $time \t $adaption"

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
        current_reachable_fitness = get_reachable_fitness(data, snapshot_id, 0.001, 50, 500)
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

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_time = get_time(get_snapshot(data, snapshot_id))
        current_diversity = get_reachable_diversity(data, snapshot_id, 0.001, 100, 500)

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

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_time = get_time(get_snapshot(data, snapshot_id))
        current_potential = get_evolutionary_potential(data, snapshot_id, 600_000, 0.001, 50, 500)

        @info "$current_time \t $current_potential"

        evolutionary_potentials[i] = current_potential
        times[i] = current_time
    end

    return (times, evolutionary_potentials)
end

function cross_population_divergence(trial_id)
    @info "2D-POPULATION DIVERGENCE:"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    divergences = SharedArray{Float64}(num_snapshots^2)
    times_1 = SharedArray{UInt64}(num_snapshots^2)
    times_2 = SharedArray{UInt64}(num_snapshots^2)

    @threads for (i, snapshot_id_1) in unique(enumerate(snapshot_ids))
        snapshot_1 = get_snapshot(data, snapshot_id_1)
        time_1 = get_time(snapshot_1)
        distribution_1 = get_genotype_distribution(snapshot_1)
        
        for (j, snapshot_id_2) in unique(enumerate(snapshot_ids))
            snapshot_2 = get_snapshot(data, snapshot_id_2)
            time_2 = get_time(snapshot_2)
            distribution_2 = get_genotype_distribution(snapshot_2)
            
            current_distance = _wasserstein(distribution_1, distribution_2, Levenshtein())

            
            index = (i-1)*num_snapshots + j
            
            divergences[index] = current_distance
            times_1[index] = time_1
            times_2[index] = time_2
        end
        @info "2D-PD \t $time_1"
    end

    return (times_1, times_2, divergences)
end

function cross_level_of_adaption(trial_id)
    @info "2D-Level of Adaption:"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    adaptions = SharedArray{Float64}(num_snapshots^2)
    times_1 = SharedArray{UInt64}(num_snapshots^2)
    times_2 = SharedArray{UInt64}(num_snapshots^2)
    
    count = Threads.Atomic{Int}(0)

    @threads for (i, snapshot_id_1) in unique(enumerate(rand(snapshot_ids, 100)))
	snapshot_1 = get_snapshot(data, snapshot_id_1)
        time_1 = get_time(snapshot_1)
        
        for (j, snapshot_id_2) in unique(enumerate(rand(snapshot_ids, 100)))
            snapshot_2 = get_snapshot(data, snapshot_id_2)
            time_2 = get_time(snapshot_2)
            
            current_adaption = get_adaption_of_snapshot(data, snapshot_id_1, snapshot_id_2, 0.01, 10, 50)
            
            index = (i-1)*num_snapshots + j

	    
	    Threads.atomic_add!(count, 1)
            @info "2D-LA \t $time_1 \t $(count[])"


            adaptions[index] = current_adaption
            times_1[index] = time_1
            times_2[index] = time_2
        end
        @info "2D-LA \t $time_1 \t $(count[])"
    end

    return (times_1, times_2, adaptions)
end

function genotype_entropy(trial_id)
    @info "ENTROPY:"

    snapshot_ids = get_snapshot_ids(data, trial_id)
    num_snapshots = length(snapshot_ids)

    entropies = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        current_snapshot = get_snapshot(data, snapshot_id)
        current_time = get_time(current_snapshot)
        
        current_distribution = get_genotype_distribution(current_snapshot)
        current_entropy = get_entropy(current_distribution)

        @info "$current_time \t $current_entropy"

        entropies[i] = current_entropy
        times[i] = current_time
    end

    return (times, entropies)
end

if length(ARGS) != 2
    trial_id = "12433992799852588"
    type_of_analysis = "LA"
else
    trial_id, type_of_analysis = ARGS
end

@info ARGS

if type_of_analysis == "LA"
    name = "LevelOfAdaption"
    func = level_of_adaption
elseif type_of_analysis == "RF"
    name = "ReachableFitness"
    func = reachable_fitness
elseif type_of_analysis == "RD"
    name = "ReachableDiversity"
    func = reachable_diversity
elseif type_of_analysis == "PD"
    name = "PopulationDivergence"
    func = population_divergence
elseif type_of_analysis == "EP"
    name = "EvolutionaryPotential"
    func = evolutionary_potential
elseif type_of_analysis == "2DPD"
    name = "2DPopulationDivergence"
    func = cross_population_divergence
elseif type_of_analysis == "2DLA"
    name = "2DLevelOfAdaption"
    func = cross_level_of_adaption
elseif type_of_analysis == "EN"
    name = "GenotypeEntropy"
    func = genotype_entropy
end

result = func(trial_id)
plot_result(result..., name, trial_id)
save_result(result, name, trial_id)

save_calculated(data)
