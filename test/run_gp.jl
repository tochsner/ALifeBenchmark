using ALifeBenchmark
data = load_collected_data(load_logged_organisms = false)
@info "Load"
gp_graph = build_genotype_graph()
@info "Calc GP"
calculate_phenotype_graph!(data, gp_graph, 0.01, 20, 200)
@info "Calc NNs"
calculate_neutral_networks!(gp_graph, 1e-3)
save_graph(gp_graph)
