# assumes that genotype and phenotype graph have been built
function get_house_of_cards_null_model(graph_data::GGraphData)
    null_model = deepcopy(graph_data)

    weights = [e.weight for e in edges(null_model.phenotype_graph)]

    shuffle!(weights)

    for (i, edge) in edges(null_model.phenotype_graph) |> enumerate
        u, v = src(edge), dst(edge)

        null_model.phenotype_graph.weights[u, v] = weights[i]
    end

    return null_model
end