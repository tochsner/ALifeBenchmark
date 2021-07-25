using ALifeBenchmark
using Plots
using Measures
using Serialization

function plot_result(times, values, name)
    plot(times, values, 
            title = "",
            label = "",
            xguide = "Time",
            yguide = name,
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            size = (900, 600),
            margin = 10mm,
            dpi = 1000,
            yscale:log10)
    savefig("$name")
end

function save_result(data, name)
    serialize("$name", data)
end

if "process_logs" in ARGS
    save_offspring_log()    
end

graph_data = load_graph_data()

if "build_gg_graph" in ARGS
    build_genotype_graph!(graph_data)
    save_graph_data(graph_data)
end

if "build_p_graph" in ARGS
    build_phenotype_graph(graph_data, 5, 0.05, 50, 500)
    save_graph_data(graph_data)
end

if "build_nn" in ARGS
    # epsilon = get_diversity_threshold(graph_data, 0.99)
    epsilon = 1e-7
    @info epsilon
    build_neutral_networks!(graph_data, epsilon)
    save_graph_data(graph_data)
end

if "general_analysis" in ARGS
    analyse_neutral_networks(graph_data)
    analyse_neutral_network_graph(graph_data)
end

if "analyse_size" in ARGS
    epsilons = [10.0^(-x) for x in 12:-0.25:7]
    sizes = []

    for epsilon in epsilons
        @info "Test epsilon $epsilon"

        build_neutral_networks!(graph_data, epsilon)
        size = get_average_nn_size(graph_data)
        
        @info "Avg. size: $size"

        push!(sizes, size)
    end

    plot_result(epsilons, sizes, "NN Size")
    save_result((epsilons, sizes), "NNSize")
end