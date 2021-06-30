using ALifeBenchmark
using Random

println("Load data...")
data = load_collected_data()

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
get_most_frequent_genotypes(data, 10)
# 
# println("Calculate Phenotype Similarity...")

# @time similarity = get_phenotype_similarity(data, genotype_id_1, genotype_id_2, 0.005)
# 
# save_calculated(data)
# 
# println(similarity)



# Random.seed!(0)

using StringDistances: Levenshtein

trial_id = "74031389094700"

snapshot_ids = get_snapshot_ids(data, trial_id)

last_snaphot_id = snapshot_ids[end]
last_snapshot = get_snapshot(data, last_snaphot_id)
last_distribution = get_genotype_distribution(last_snapshot)

for snapshot_id in snapshot_ids
    snapshot = get_snapshot(data, snapshot_id)

    distribution = get_genotype_distribution(snapshot)
    distance = _wasserstein(last_distribution, distribution, Levenshtein())
    
    println(snapshot_id, " ", distance)
end

# snapshot_1 = "85527776840800"
# snapshot_2 = "97916520365199"
# 
# snapshot_1 = get_snapshot(data, snapshot_1)
# snapshot_2 = get_snapshot(data, snapshot_2)
# 
# println(get_adaption_of_snapshot(data, "83280182507199", "83280182507199", 0.01, 5, 100))
# 
# println(get_T_similarity(snapshot_1, snapshot_2, 10_000_000, 0.1, 20, 25))

# println(get_reachable_fitness(data, 100, 0.005, 50, 500))

save_calculated(data)