using ALifeBenchmark
using Random
import SharedArrays.SharedArray
using Plots
using Serialization
import Base.Threads.@threads
using StringDistances: Levenshtein

println("Loading collected data...")
data = load_collected_data(load_logged_organisms = false)
println("Colleted data loaded.\n")

TRIAL_ID = "12433992799852588"

function level_of_adaption()
    println("Level of Adaption:")

    snapshot_ids = get_snapshot_ids(data, TRIAL_ID)
    num_snapshots = length(snapshot_ids)

    last_snaphot_id = snapshot_ids[end]

    adaptions = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    println(num_snapshots)

    count = Threads.Atomic{Int}(0)
    l = Threads.ReentrantLock()

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids[1:20]))
        adaption = get_adaption_of_snapshot(data, last_snaphot_id, snapshot_id, 0.1, 10, 200)
        time = get_time(get_snapshot(data, snapshot_id))

        println(time, "\t", adaption)

        Threads.atomic_add!(count, 1)


        lock(l) do
            adaptions[i] = adaption
            times[i] = time
        end
    end

    serialize("LevelofAdaption", (times, adaptions))

    plot(times, adaptions, 
            title = "Level Of Adaption",
            label = "",
            xguide = "Time",
            yguide = "Adaption",
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            dpi = 1000)
    savefig("LevelOfAdaption")
end

function reachable_fitness()
    println("Reachable Fitness:")

    snapshot_ids = get_snapshot_ids(data, TRIAL_ID)
    num_snapshots = length(snapshot_ids)

    last_snaphot_id = snapshot_ids[end]

    reachable_fitness = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids[1:10]))
        current_reachable_fitness = get_reachable_fitness(data, snapshot_id, 0.01, 50, 200)
        current_time = get_time(get_snapshot(data, snapshot_id))

        println(current_time, "\t", current_reachable_fitness)

        reachable_fitness[i] = current_reachable_fitness
        times[i] = current_time
    end

    serialize("ReachableFitness", (times, reachable_fitness))

    plot(times, reachable_fitness, 
            title = "Reachable Fitness",
            label = "",
            xguide = "Time",
            yguide = "Reachable Fitness",
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            dpi = 1000)
    savefig("ReachableFitness")
end

function population_divergence()
    trials = get_trials()
    num_trials = length(trials)

    all_divergences = []
    all_times = []    
    
    for trial_id in trials
        println("Population Divergence:")

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

            divergences[i] = current_distance
            times[i] = current_time
        end

        push!(all_divergences, divergences)
        push!(all_times, times)
    end
    
    serialize("PopulationDivergence", (trials, all_times, all_divergences))
    
    plot(all_times, all_divergences, 
            title = "Population Divergence",
            label = "",
            xguide = "Time",
            yguide = "Population Divergence (Wasserstein)",
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            dpi = 1000)

    savefig("PopulationDivergence.png")
end

function population_divergence()
    trials = get_trials()
    num_trials = length(trials)

    all_divergences = []
    all_times = []    
    
    for trial_id in trials
        println("Population Divergence:")

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

            divergences[i] = current_distance
            times[i] = current_time
        end

        push!(all_divergences, divergences)
        push!(all_times, times)
    end
    
    serialize("PopulationDivergence", (trials, all_times, all_divergences))
    
    plot(all_times, all_divergences, 
            title = "Population Divergence",
            label = "",
            xguide = "Time",
            yguide = "Population Divergence (Wasserstein)",
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            dpi = 1000)

    savefig("PopulationDivergence.png")
end

# genotype_id_1 = "4154df3571b1ddce463713e5e713a0d8d4e80c465bdae473b87502b8160e7aeb"
# genotype_id_2 = "834dcac3370f9dd44eba227de14f6496d372446c3018a2fe19ffe77a4f028429"
# 
# println("-" ^ 10)
# println("Genotype 1")
# print_program(get_genotype(data, genotype_id_1))
# 
# println("-" ^ 10)
# println("Genotype 1")
# print_program(get_genotype(data, genotype_id_2))
# 
# println("-" ^ 10)
# println("Most Frequent")
# 
# get_most_frequent_genotypes(data, 10)
# 
# println("Calculate Phenotype Similarity...")

# @time similarity = get_phenotype_similarity(data, genotype_id_1, genotype_id_2, 0.005)
# 
# save_calculated(data)
# 
# println(similarity)



# Random.seed!(0)

# using StringDistances: Levenshtein
# 


# snapshot_1 = "85527776840800"
# snapshot_2 = "97916520365199"
# 
# snapshot_1 = get_snapshot(data, snapshot_1)
# snapshot_2 = get_snapshot(data, snapshot_2)
# 
# println(get_adaption_of_snapshot(data, "83280182507199", "83280182507199", 0.01, 5, 100))
# 
# println(get_T_similarity(snapshot_1, snapshot_2, 10_000_000, 0.1, 20, 25))
#
#println(get_reachable_fitness(data, 100, 0.005, 50, 500))


level_of_adaption()

save_calculated(data)
