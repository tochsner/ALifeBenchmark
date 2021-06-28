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
# get_most_frequent_genotypes(data, 500)
# 
# println("Calculate Phenotype Similarity...")

# @time similarity = get_phenotype_similarity(data, genotype_id_1, genotype_id_2, 0.005)
# 
# save_calculated(data)
# 
# println(similarity)

snapshot_1 = "97693929022999"

similarity = get_reachable_fitness(data, 200)

println(similarity)

save_calculated(data)