function build_metric_induced_graph(metric, graph)
    n = nv(graph)
    
    metric_induced_graph = SimpleGraph(n)

    for u in 1:n
        for v in u:n
            if metric(u, v) <= 1 || has_edge(graph, u, v) || has_edge(graph, v, u)
                add_edge!(metric_induced_graph, u, v)
            end
        end
    end

    return metric_induced_graph
end

function build_simple_graph(graph)
    SimpleGraph(adjacency_matrix(graph) + transpose(adjacency_matrix(graph)))
end

function get_simple_digraph(graph)
    SimpleDiGraph(adjacency_matrix(graph))
end

function get_simple_weighted_graph(graph)
    SimpleWeightedGraph(max.(adjacency_matrix(graph), transpose(adjacency_matrix(graph))))
end