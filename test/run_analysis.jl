using ALifeBenchmark
using Random
import SharedArrays.SharedArray
using Plots

import Base.Threads.@threads

using Serialization

println("Loading collected data...")
data = load_collected_data()
println("Colleted data loaded.\n")

TRIAL_ID = "21507144614952565"

function level_of_adaption()
    println("Level of Adaption:")

    snapshot_ids = get_snapshot_ids(data, TRIAL_ID)
    num_snapshots = length(snapshot_ids)

    last_snaphot_id = snapshot_ids[end]

    adaptions = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt32}(num_snapshots)

    @threads for (i, snapshot_id) in unique(enumerate(snapshot_ids))
        adaption = get_adaption_of_snapshot(data, last_snaphot_id, snapshot_id, 0.1, 5, 200)
        time = get_time(get_snapshot(data, snapshot_id))

        println(time, "\t", adaption)

        adaptions[i] = adaption
        times[i] = time
    end

    serialize("LevelofAdaption", (times, adaptions))

    plot(times, adaptions, 
            title = "Level Of Adaption",
            label = "",
            xguide = "Time",
            yguide = "Adaption",
            seriestype = :scatter,
            dpi = 600)
    savefig("LevelOfAdaption", )
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