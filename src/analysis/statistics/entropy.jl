get_entropy(snapshot) = get_genotype_distribution(snapshot) |> get_entropy
get_entropy(distribution::Dict) = -sum([p * log2(p) for p in values(distribution)])