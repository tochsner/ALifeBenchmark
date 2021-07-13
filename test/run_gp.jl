using ALifeBenchmark

data = load_collected_data(load_logged_organisms = false)

save_offspring_log(data)
gp_graph = build_genotype_graph()
calculate_phenotype_graph!(data, gp_graph, 0.01, 50, 500)
save_graph(gp_graph)