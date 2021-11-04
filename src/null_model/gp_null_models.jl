using LightGraphs

# assumes that genotype and phenotype graph have been built
function get_house_of_cards_null_model(graph_data::GGraphData)
    null_model = deepcopy(graph_data)

    weights = [e.weight for e in edges(null_model.phenotype_graph)]

    shuffle!(weights)

    for (i, edge) in edges(null_model.phenotype_graph) |> enumerate
        u, v = src(edge), dst(edge)

        add_edge!(null_model.phenotype_graph, u, v, weights[i])
    end

    return null_model
end

# assumes that genotype and phenotype graph have been built
function get_complete_house_of_cards_null_model(graph_data::GGraphData)
    null_model = deepcopy(graph_data)

    if isfile(CALCULATED_FOLDER * "phenotype_similarities")
        similarities = deserialize(CALCULATED_FOLDER * "phenotype_similarities")
    else
        similarities = _sample_phenotype_similarities(graph_data::GGraphData, 250)
        serialize(CALCULATED_FOLDER * "phenotype_similarities", similarities)
    end

    all_edges = edges(null_model.genotype_graph)
    sources = src.(all_edges)
    destinations = dst.(all_edges)
    weights::Vector{Real} = rand(similarities, length(sources))

    null_model.phenotype_graph = SimpleWeightedDiGraph(sources, destinations, weights)

    @info "$(nv(null_model.phenotype_graph)) $(ne(null_model.phenotype_graph))"

    return null_model
end

function _sample_phenotype_similarities(graph_data::GGraphData, n)
    similarities = []

    simple_genotype_graph = build_simple_graph(graph_data.genotype_graph)
    all_edges = unique(edges(simple_genotype_graph))

    for i in 1:n
        edge = rand(all_edges)
        u, v = src(edge), dst(edge)        
        
        if has_edge(graph_data.phenotype_graph, u, v)
            similarity = graph_data.phenotype_graph.weights[v, u]
        else
            genotype_u, genotype_v = graph_data.genotype_vertex_mapping(u), graph_data.genotype_vertex_mapping(v)
            similarity = get_phenotype_similarity(genotype_u, genotype_v, 0.05, 10, 20)
        end

        push!(similarities, similarity)

        @info "$i / $n sampled ($similarity)."
    end

    return similarities
end