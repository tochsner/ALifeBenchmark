using ALifeBenchmark

@info "Collect parent-offspring relations"

save_offspring_log()

graph_data = GGraphData()

@info "Build Genotype Graph"
build_genotype_graph!(graph_data)

save_graph_data(graph_data)
