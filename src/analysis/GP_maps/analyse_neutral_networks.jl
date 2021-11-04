using LightGraphs
using Serialization
using Statistics
import Memoize
import Base.Threads.@threads
import SharedArrays.SharedArray

get_average_nn_size(graph_data::GGraphData) = length.(graph_data.neutral_networks) |> mean
function get_nn_size_percentile(graph_data::GGraphData)
    neutral_networks = graph_data.neutral_networks
    num_neutral_networks = length(neutral_networks)
    num_genotypes = sum(length.(neutral_networks))

    percentile = 0.1*num_neutral_networks

    lengths_sorted = sort(length.(neutral_networks), rev=true)
    lengths_chosen = 0
    for (i, l) in enumerate(lengths_sorted)
        lengths_chosen += l

        if i >= percentile
            return lengths_chosen / num_genotypes
        end
    end

    return 1.0
end
get_average_diameter(graph_data::GGraphData) = analyse_neutral_networks(graph_data, diameter)
get_average_radius(graph_data::GGraphData) = analyse_neutral_networks(graph_data, radius)
get_average_clustering(graph_data::GGraphData) = analyse_neutral_networks(graph_data, global_clustering_coefficient)
get_average_phenotype_robustness(graph_data::GGraphData) = mean([get_phenotype_robustness(graph_data, nn) for nn in 1:length(graph_data.neutral_networks)])
get_average_phenotype_evolvability(graph_data::GGraphData) = mean([get_phenotype_evolvability(graph_data, nn) for nn in 1:length(graph_data.neutral_networks)])
function get_average_phenotype_evolvability_robustness_cor(graph_data::GGraphData)
    cor(
        [get_phenotype_evolvability(graph_data, i) for i in 1:length(graph_data.neutral_networks)],
        [get_phenotype_robustness(graph_data, i) for i in 1:length(graph_data.neutral_networks)]
        )
end
function get_shape_space_covering(graph_data::GGraphData, n)    
    unweighted_phenotype_graph = get_simple_digraph(graph_data.phenotype_graph)
    genotypes = [g for neutral_network in graph_data.neutral_networks for g in neutral_network]

    shape_space_covering = estimate(genotypes, 0.01, 100, 10_000) do genotype_index
        return get_shape_space_covering(graph_data, unweighted_phenotype_graph, genotype_index, n)
    end

    return shape_space_covering
end
    
get_phenotype_robustness(graph_data::GGraphData, network_index) = mean([get_genotype_robustness(graph_data, i, network_index) for i in graph_data.neutral_networks[network_index]])

function get_phenotype_evolvability(graph_data::GGraphData, network_index)
    reachable_genotypes = []

    for genotype_index in graph_data.neutral_networks[network_index]
        current_reachable_genotypes = outneighbors(graph_data.phenotype_graph, genotype_index)
        append!(reachable_genotypes, current_reachable_genotypes)
    end

    reachable_genotypes = unique(reachable_genotypes)
    reachable_networks = get_corresponding_neutral_networks(graph_data, reachable_genotypes)
    filter!(x -> x != 0, reachable_networks)                # filter out genotypes not on any neutral network
    filter!(x -> x != network_index, reachable_networks)    # filter out genotypes on the network in question
    reachable_networks = unique(reachable_networks)

    return length(reachable_networks) / (length(graph_data.neutral_networks) - 1)
end

get_genotype_robustness(graph_data, genotype_index) = get_genotype_robustness(GGraphData, genotype_index, get_corresponding_neutral_network(graph_data, genotype_index))
function get_genotype_robustness(graph_data::GGraphData, genotype_index, network_index)
    neutral_network = graph_data.neutral_networks[network_index]
    
    neighbors = outneighbors(graph_data.phenotype_graph, genotype_index)
    neutral_neighbors = [n for n in neighbors if n in neutral_network]

    return length(neutral_neighbors) / length(neighbors)
end

function get_shape_space_covering(graph_data::GGraphData, genotype_index, n)
    get_shape_space_covering(graph_data, get_simple_digraph(graph_data.phenotype_graph), genotype_index, n)
end
function get_shape_space_covering(graph_data::GGraphData, unweighted_phenotype_graph::SimpleDiGraph, genotype_index, n)
    reachable_genotypes = neighborhood(unweighted_phenotype_graph, genotype_index, n)

    reachable_networks = get_corresponding_neutral_networks(graph_data, reachable_genotypes) |> unique   
    filter!(x -> x != 0, reachable_networks)    # filter out genotypes not on any neutral network

    return (length(reachable_networks) - 1) / (length(graph_data.neutral_networks) - 1)   # ignore neutral network of genotype_index in question
end

function analyse_neutral_networks(graph_data::GGraphData, metric)
    results = []

    for neutral_network in graph_data.neutral_networks
        graph, vertex_mapping = induced_subgraph(graph_data.genotype_graph, neutral_network)
        
        metric_induced_graph = build_metric_induced_graph(graph) do v_1, v_2
            genotype_index_1 = vertex_mapping[v_1]
            genotype_index_2 = vertex_mapping[v_2]
 
            genotype_1 = graph_data.genotype_vertex_mapping(genotype_index_1)
            genotype_2 = graph_data.genotype_vertex_mapping(genotype_index_2)
 
            return Levenshtein()(genotype_1, genotype_2)
        end

        current_result = metric(metric_induced_graph)

        push!(results, current_result)
    end

    return mean(results)
end

function get_corresponding_neutral_networks(graph_data::GGraphData, genotype_indices)
    [get_corresponding_neutral_network(graph_data, genotype) for genotype in genotype_indices]
end
@memoize function get_corresponding_neutral_network(graph_data::GGraphData, genotype_index)
    for (i, neutral_network) in enumerate(graph_data.neutral_networks)        
        if genotype_index in neutral_network
            return i
        end
    end

    return 0
end

function get_neutral_network_distribution(graph_data::GGraphData, snapshot)
    organisms = get_organisms(snapshot)
    genotypes = [graph_data.genotype_vertex_mapping[get_genotype(snapshot, organism)] for organism in organisms]
    neutral_networks = get_corresponding_neutral_networks(graph_data, genotypes)
    nn_distribution = get_distribution(neutral_networks)

    return nn_distribution
end

function pmean(get_value_from_item, items)
    values = SharedArray{Float64}(length(items))

    for (i, item) in enumerate(items) |> unique
        value = get_value_from_item(item)
        values[i] = value
    end

    return mean(values)
end