using LightGraphs
using Serialization
using Statistics

function get_diversity_threshold(graph_data::GGraphData, threshold_percentile)
    _, variances = _get_fitness_variance(graph_data, 0.05, 500, 5000)
    
    diversities = variances .* 2
    diversity_threshold = quantile(diversities, threshold_percentile)

    serialize("div", diversities)

    return diversity_threshold
end

function _get_fitness_variance(graph_data::GGraphData, rel_tolerance, min_samples, max_samples)
    num_genotypes = nv(graph_data.genotype_graph)
    genotype_weights = get_overall_genotype_distribution(graph_data)
    
    fitness_variance = estimate(rel_tolerance, min_samples, max_samples, print_progress = true, return_all_samples = true) do
        vertex = weighted_rand(1:num_genotypes, genotype_weights)
        genotype = graph_data.genotype_vertex_mapping(vertex)
        
        snapshot = sample_snapshot_id() |> get_snapshot
        sample = get_organisms(snapshot) |> rand
        sample_id = get_id(snapshot, sample)

        sample_similaritiy = (get_fitness(snapshot, sample_id, genotype) - get_fitness(snapshot, sample_id, genotype))^2  
        
        return sample_similaritiy / 2
    end

    return fitness_variance
end

function analyse_neutral_networks(graph_data::GGraphData)
    println("Size: \t $(analyse_neutral_networks(graph_data, nv))")
    println("Diameter: \t $(analyse_neutral_networks(graph_data, diameter))")
    println("Radius: \t $(analyse_neutral_networks(graph_data, radius))")
    println("Characteristic Path Length: \t $(analyse_neutral_networks(graph_data, g -> mean(1 / closeness_centrality(g))))")
    println("Clustering: \t $(analyse_neutral_networks(graph_data, global_clustering_coefficient))")
    # println("Assortativity: \t $(analyse_neutral_networks(graph_data, assortativity))")
end

get_average_nn_size(graph_data::GGraphData) = analyse_neutral_networks(graph_data, nv)

function analyse_neutral_networks(graph_data::GGraphData, metric)
    genotype_weights = get_overall_genotype_distribution(graph_data)
    total_used_weights = 0

    result = 0

    for neutral_network in graph_data.neutral_networks
        neutral_network_weight = sum(genotype_weights[neutral_network]) # 1 / length(graph_data.neutral_networks) # 
        total_used_weights += neutral_network_weight

        graph, vertex_mapping = induced_subgraph(graph_data.genotype_graph, neutral_network)
        
        metric_induced_graph = build_metric_induced_graph(graph) do v_1, v_2
            genotype_index_1 = vertex_mapping[v_1]
            genotype_index_2 = vertex_mapping[v_2]

            genotype_1 = graph_data.genotype_vertex_mapping(genotype_index_1)
            genotype_2 = graph_data.genotype_vertex_mapping(genotype_index_2)

            return Levenshtein()(genotype_1, genotype_2)
        end

        current_result = metric(metric_induced_graph)

        result += neutral_network_weight * current_result
    end

    return result / total_used_weights
end

function analyse_neutral_network_graph(graph_data::GGraphData)
    println("Shape-Space-Covering:")
    for i in 1:40
        println("$i \t $(n_shape_space_covering(graph_data, i))")
    end
end

function n_shape_space_covering(graph_data::GGraphData, n)
    num_neutral_networks = length(graph_data.neutral_networks)

    reachable_percentages = []

    for i in 1:num_neutral_networks
        current_reachable_networks = [j for j in outneighbors(graph_data.neutral_network_graph, i) if graph_data.neutral_network_graph.weights[i, j] <= n]
        current_reachable_percentage = length(current_reachable_networks) / (num_neutral_networks - 1) # we exclude the NN i itself

        push!(reachable_percentages, current_reachable_percentage)
    end

    return mean(reachable_percentages)
end

function get_corresponding_neutral_networks(graph_data::GGraphData, genotypes)
    [get_corresponding_neutral_network(graph_data, genotype) for genotype in genotypes]
end
function get_corresponding_neutral_network(graph_data::GGraphData, genotype)
    if haskey(graph_data.genotype_vertex_mapping, genotype) == false return 0 end

    for (i, neutral_network) in enumerate(graph_data.neutral_networks)        
        if graph_data.genotype_vertex_mapping[genotype] in neutral_network
            return i
        end
    end

    return 0
end

function get_neutral_network_distribution(graph_data::GGraphData, snapshot)
    organisms = get_organisms(snapshot)
    genotypes = [get_genotype(snapshot, organism) for organism in organisms]
    neutral_networks = get_corresponding_neutral_networks(graph_data, genotypes)
    nn_distribution = get_distribution(neutral_networks)

    return nn_distribution
end