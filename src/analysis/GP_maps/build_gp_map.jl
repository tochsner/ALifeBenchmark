using Serialization
using LightGraphs
using SimpleWeightedGraphs
using MetaGraphs
using Bijections
using Statistics
import LightGraphs.Parallel

mutable struct GGraphData
    genotype_vertex_mapping::Bijection
    genotype_graph::SimpleWeightedDiGraph
    
    phenotype_graph::SimpleWeightedDiGraph

    neutral_networks::Vector
    neutral_network_graph::SimpleWeightedDiGraph

    fitness_values::Dict

    GGraphData() = new(Bijection(), SimpleWeightedDiGraph(0), SimpleWeightedDiGraph(0), [], SimpleWeightedDiGraph(0), Dict())
end

function save_graph_data(graph::GGraphData)
    serialize(CALCULATED_FOLDER * "GGraphData", graph)
end
function load_graph_data() 
    if isfile(CALCULATED_FOLDER * "GGraphData")
        deserialize(CALCULATED_FOLDER * "GGraphData")
    else
        GGraphData()
    end
end   

function get_overall_genotype_distribution(graph_data::GGraphData)
    occurances = []

    for vertex in 1:nv(graph_data.genotype_graph)
        outgoing = outneighbors(graph_data.genotype_graph, vertex)

        if length(outgoing) == 0
            push!(occurances, 0)
        else
            push!(occurances, sum([graph_data.genotype_graph.weights[vertex, u] for u in outgoing]))
        end
    end

    occurances = occurances ./ sum(occurances)

    return occurances
end

function build_genotype_graph!(graph_data::GGraphData)    
    parent_offsprings = deserialize(CALCULATED_FOLDER * "parent_offspring_ocurrances")

    genotype_mapping = Bijection()

    for ((parent, _), _) in parent_offsprings
        if haskey(genotype_mapping, parent) == false
            genotype_mapping[parent] = length(genotype_mapping) + 1
        end
    end

    @info "Mapping created. ($(length(genotype_mapping))) Building graph..."

    genotype_graph = SimpleWeightedDiGraph(length(genotype_mapping))

    count = 0

    for ((parent, offspring), num) in parent_offsprings
        if haskey(genotype_mapping, offspring) == false continue end   # we skip sinks without offsprings

        parent_index = genotype_mapping[parent]
        offspring_index = genotype_mapping[offspring]        
        add_edge!(genotype_graph, parent_index, offspring_index, num)

        count += 1
        if count % 1000 == 0
            @info (count / length(parent_offsprings))
        end
    end

    @info "Graph built."

    graph_data.genotype_vertex_mapping = genotype_mapping
    graph_data.genotype_graph = genotype_graph
end 

function build_phenotype_graph!(graph_data::GGraphData, min_occurances, tolerance, min_samples, max_samples)
    phenotype_graph = SimpleWeightedDiGraph(nv(graph_data.genotype_graph))

    @info "Collect relevant edges."

    edges_to_test = []

    for edge in edges(graph_data.genotype_graph)
        u, v = src(edge), dst(edge)

        if u == v continue end
        if (v, u) in edges_to_test continue end
        if has_edge(graph_data.genotype_graph, u, v) == false continue end
        if graph_data.genotype_graph.weights[u, v] < min_occurances continue end

        push!(edges_to_test, (u, v))
    end

    @info "Calculate Phenotype Similarities for $(length(edges_to_test)) edges."

    num_edges_to_test = length(edges_to_test)
    phenotype_similarities = SharedArrays.SharedArray{Float64}(num_edges_to_test)

    done = Threads.Atomic{Int}(0)

    @threads for (i, (u, v)) in unique(enumerate(edges_to_test))
        genotype_u, genotype_v = graph_data.genotype_vertex_mapping(u), graph_data.genotype_vertex_mapping(v)
        similarity = get_phenotype_similarity(genotype_u, genotype_v, tolerance, min_samples, max_samples)

        phenotype_similarities[i] = similarity

        Threads.atomic_add!(done, 1)
        @info (done[] / length(edges_to_test))
    end

    phenotype_similarities_dict = Dict()

    for i in 1:num_edges_to_test
        similariry = phenotype_similarities[i]
        u, v = edges_to_test[i]

        phenotype_similarities_dict[(u, v)] = similariry
        phenotype_similarities_dict[(v, u)] = similariry
    end

    @info "Build Phenotype Similarities Graph."

    for edge in edges(graph_data.genotype_graph)
        u, v = src(edge), dst(edge)

        if haskey(phenotype_similarities_dict, (u, v)) == false continue end

        similarity = phenotype_similarities_dict[(u, v)]
        add_edge!(phenotype_graph, u, v, similarity)        
    end

    graph_data.phenotype_graph = phenotype_graph
end

function analyse_phenotype_graph(graph_data::GGraphData)
    weights = [e.weight for e in edges(graph_data.phenotype_graph)]

    println("Minimum Weight: \t $(minimum(weights))")
    println("Maximum Weight: \t $(maximum(weights))")
    println("Mean Weight: \t $(mean(weights))")
    println("Median Weight: \t $(median(weights))")

    println()
    println("Quantiles:")
    for q in 0:0.1:1
        println("$q: \t $(quantile(weights, q))")
    end
end

function build_neutral_networks!(graph_data::GGraphData, epsilon)
    undirected_phenotype_graph = get_simple_weighted_graph(graph_data.phenotype_graph)
    
    neutral_networks = []
    already_assigned_nodes = []
    memberships = Dict()

    # find all neutral networks

    for edge in edges(undirected_phenotype_graph)
	    if has_edge(undirected_phenotype_graph, edge) == false continue end
        
	    node = src(edge)    # we ignore sinks
        if node in already_assigned_nodes continue end

	    neutral_network = _find_neutral_network(undirected_phenotype_graph, node, epsilon)
        push!(neutral_networks, neutral_network)

        for node in neutral_network
            push!(already_assigned_nodes, node)
            memberships[node] = length(neutral_networks)
        end
    end

    # create the graph of NNs and determine the minimum number of mutations between all NNs

    num_neutral_networks = length(neutral_networks)
    neutral_network_graph = SimpleWeightedDiGraph(num_neutral_networks)
    
    for (i, neutral_network_1) in enumerate(neutral_networks)
        distances = gdistances(graph_data.genotype_graph, neutral_network_1)
        
        for (j, neutral_network_2) in enumerate(neutral_networks)
            if neutral_network_1 == neutral_network_2 continue end

            distances_to_nn_2 = distances[neutral_network_2]
            min_distance_to_nn_2 = minimum(distances_to_nn_2)

            if min_distance_to_nn_2 == typemax(Int64) continue end
            
            @assert min_distance_to_nn_2 > 0

            add_edge!(neutral_network_graph, i, j, min_distance_to_nn_2)
        end
    end

    graph_data.neutral_networks = neutral_networks
    graph_data.neutral_network_graph = neutral_network_graph
end

function _find_neutral_network(graph, starting_vertex, epsilon)
    neutral_network = [starting_vertex]

    to_test = [(starting_vertex, n) for n in outneighbors(graph, starting_vertex)]

    while 0 < length(to_test)
        u, v = pop!(to_test)
 
        if graph.weights[u, v] <= epsilon            
            push!(neutral_network, v)

            for n in outneighbors(graph, v)
                if n in neutral_network continue end

                push!(to_test, (v, n))
            end
        end
    end

    return unique(neutral_network)
end
