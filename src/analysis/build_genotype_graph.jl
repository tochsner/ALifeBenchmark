using Serialization
using LightGraphs
using SimpleWeightedGraphs
using MetaGraphs
using Bijections

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
load_graph_data() = deserialize(CALCULATED_FOLDER * "GGraphData")

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

    for (i, edge) in unique(enumerate(edges(graph_data.genotype_graph)))
        u, v = src(edge), dst(edge)

        if u == v continue end
        if has_edge(graph.genotype_graph, u, v) == false continue end
        if graph_data.genotype_graph.weights[u, v] < min_occurances continue end

        genotype_u, genotype_v = graph_data.genotype_vertex_mapping(u), graph_data.genotype_vertex_mapping(v)

        if has_edge(phenotype_graph, v, u) 
            similarity = phenotype_graph.weights[v, u]
        else
            similarity = get_phenotype_similarity(genotype_u, genotype_v, tolerance, min_samples, max_samples)
            similarity = max(eps(), similarity) # an edge weight of 0 would be ignored by SimpleWeightedDiGraph
        end

        add_edge!(phenotype_graph, u, v, similarity)
        
        @info "$(i / ne(graph.genotype_graph)) \t $similarity"
    end

    graph.phenotype_graph = phenotype_graph
end

function build_neutral_networks!(graph_data::GGraphData, epsilon)
    neutral_networks = []
    already_assigned_nodes = []
    memberships = Dict()

    for edge in edges(graph_data.phenotype_graph)
	    if has_edge(graph_data.phenotype_graph, edge) == false continue end
        
	    node = src(edge)    # we ignore sinks
        if node in already_assigned_nodes continue end

	    neutral_network = _find_neutral_network(graph_data.phenotype_graph, node, epsilon)
        push!(neutral_networks, neutral_network)

        for node in neutral_network
            push!(already_assigned_nodes, node)
            memberships[node] = length(neutral_networks)
        end
    end

    neutral_network_graph = SimpleWeightedDiGraph(length(neutral_networks))

    for edge in edges(graph_data.genotype_graph)
        u, v = src(edge), dst(edge)
        
	    if has_edge(graph_data.genotype_graph, u, v) == false continue end
	    if haskey(memberships, u) == false continue end
	    if haskey(memberships, v) == false continue end

        nn_index_u = memberships[u]
        nn_index_v = memberships[v]

        if has_edge(neutral_network_graph, nn_index_u, nn_index_v)
            num = neutral_network_graph.weights[nn_index_u, nn_index_v] + graph_data.genotype_graph.weights[u, v]
        else
            num = graph_data.genotype_graph.weights[u, v]
        end
        
        add_edge!(neutral_network_graph, nn_index_u, nn_index_v, num)
    end

    graph_data.neutral_networks = neutral_networks
    graph_data.neutral_network_graph = neutral_network_graph
end

function _find_neutral_network(graph::SimpleWeightedDiGraph, starting_vertex, epsilon)
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
