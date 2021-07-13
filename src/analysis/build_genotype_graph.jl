using Serialization
using LightGraphs
using SimpleWeightedGraphs
using MetaGraphs
using Bijections

mutable struct GPGraph
    genotype_vertex_mapping::Bijection
    genotype_graph::SimpleWeightedDiGraph
    phenotype_graph::SimpleWeightedDiGraph
end

function build_genotype_graph()    
    genotype_mapping = Bijection()
    parent_offsprings = deserialize(CALCULATED_FOLDER * "offspring_parents")
    num_offsprings = Dict()

    i = 1

    for ((parent, offspring), num) in parent_offsprings
        if haskey(genotype_mapping, parent) == false
            genotype_mapping[parent] = i
            i += 1
        end
        if haskey(genotype_mapping, offspring) == false
            genotype_mapping[offspring] = i
            i += 1
        end

        if haskey(num_offsprings, parent)
            num_offsprings[parent] += num
        else
            num_offsprings[parent] = num
        end
    end

    genotype_graph = SimpleWeightedDiGraph(length(genotype_mapping))

    for ((parent, offspring), num) in parent_offsprings
        if isfile(GENOTYPE_FOLDER * parent) == false continue end
        if isfile(GENOTYPE_FOLDER * offspring) == false continue end

        if !haskey(num_offsprings, offspring) || num_offsprings[offspring] == 0 continue end # we skip offspring which are sinks

        parent_index = genotype_mapping[parent]
        offspring_index = genotype_mapping[offspring]        
        add_edge!(genotype_graph, parent_index, offspring_index, num)
    end

    println(genotype_graph)

    return GPGraph(genotype_mapping, genotype_graph, SimpleWeightedDiGraph(0))
end 

function analyse_graph(graph)    
    println("Density:             $(density(graph))")
    println("Max. Out. Degree:    $(Δout(graph))")
    println("Min. Out. Density:   $(δout(graph))")
    println("Max. In. Degree:     $(Δin(graph))")
    println("Min. In. Density:    $(δin(graph))")
    
    println("connectedness:       $(is_weakly_connected(graph))") 
end

function calculate_phenotype_graph!(data::CollectedData, graph::GPGraph, tolerance, min_samples, max_samples)
    phenotype_graph = SimpleWeightedDiGraph(nv(graph.genotype_graph))

    count = 0

    for e in unique(edges(graph.genotype_graph))
        u, v = src(e), dst(e)
        genotype_u, genotype_v = graph.genotype_vertex_mapping(u), graph.genotype_vertex_mapping(v)

        println(genotype_u, " ", genotype_v)

        if has_edge(phenotype_graph, v, u) 
            similarity = phenotype_graph.weights[v, u]
        else
            similarity = get_phenotype_similarity(data, genotype_u, genotype_v, tolerance, min_samples, max_samples)
            similarity = max(1e-15, similarity) # an edge weight of 0 would be ignored by SimpleWeightedDiGraph
        end

        add_edge!(phenotype_graph, u, v, similarity)

        count += 1

        @info "$(count / ne(graph.genotype_graph)) \t $similarity"
    end

    graph.phenotype_graph = phenotype_graph
end

function save_graph(graphGP_graph::GPGraph)
    serialize("GP", graph)
end