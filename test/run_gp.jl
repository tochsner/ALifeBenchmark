using ALifeBenchmark
using Plots
using Measures
using Serialization
import Base.Threads.@threads
import SharedArrays.SharedArray
import Base.GC.gc
using Memoize

epsilons = [10.0^(-x) for x in 9:-0.1:4]

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
            dpi = 1000)
    savefig("$name.png")
end

function save_result(data, name)
    serialize("$name", data)
end

function create_null_epsilon_plot(metric, name)    
    num_epsilons = length(epsilons)
    values = SharedArray{Float64}(num_epsilons)
    null_values = SharedArray{Float64}(num_epsilons)

    @threads for (i, epsilon) in enumerate(epsilons) |> unique
        graph_data = load_graph_data(epsilon, "")
        value = metric(graph_data)
	graph_data = nothing
	empty!(memoize_cache(ALifeBenchmark.get_corresponding_neutral_network))
	gc()

        graph_data = load_graph_data(epsilon, "N")
        null_value = metric(graph_data)
	graph_data = nothing
	empty!(memoize_cache(ALifeBenchmark.get_corresponding_neutral_network))
	gc()

        @info "$epsilon \t $value \t $null_value"
         
        values[i] = value
        null_values[i] = null_value
   end

   plot(epsilons, [values null_values], 
            title = "",
            label = "",
            xguide = "Epsilon",
            yguide = name,
            xscale = :log10,
            seriestype = :scatter,
            markersize = 1.5,            
            markerstrokewidth = 0,
            size = (900, 600),
            margin = 10mm,
            dpi = 1000)
    savefig("$name.png")
    serialize("$name", (epsilons, Array(values), Array(null_values)))
end

if "process_logs" in ARGS
    save_offspring_log()    
end

if "load_null" in ARGS
    graph_data = load_graph_data() |> get_house_of_cards_null_model
    file_prefix = "N"
elseif "load_complete_null" in ARGS
    graph_data = load_graph_data() |> get_complete_house_of_cards_null_model
    file_prefix = "CN"
else
    graph_data = load_graph_data()
    file_prefix = ""
end

if "build_gg_graph" in ARGS
    build_genotype_graph!(graph_data)
    save_graph_data(graph_data)
end

if "build_p_graph" in ARGS
    build_phenotype_graph!(graph_data, 5, 0.05, 50, 500)
    save_graph_data(graph_data)
end

if "build_nn" in ARGS
    epsilon = 1e-7
    @info epsilon
    build_neutral_networks!(graph_data)
    save_graph_data(graph_data)
end

if "build_nns" in ARGS
    @threads for epsilon in epsilons
        @info epsilon
        build_neutral_networks!(graph_data, epsilon)
        save_graph_data(graph_data, epsilon, file_prefix)
    end
end

if "build_nns_g_sampling" in ARGS
    n = parse(Int, ARGS[end])
    nns = get_neutral_networks_by_g_sampling(graph_data, 1e-5, n, 0.05, 20, 50)
    serialize(nns, "g-sampled NNs")
end

if "general_analysis" in ARGS
    analyse_neutral_networks(graph_data)
    analyse_neutral_network_graph(graph_data)
end

if "generate_plots" in ARGS
    # create_null_epsilon_plot(gd -> get_shape_space_covering(gd, 1), "1-Shape-Space Covering")
    # create_null_epsilon_plot(gd -> get_shape_space_covering(gd, 2), "2-Shape-Space Covering")
    # create_null_epsilon_plot(gd -> get_shape_space_covering(gd, 4), "4-Shape-Space Covering")
    # create_null_epsilon_plot(gd -> get_shape_space_covering(gd, 7), "7-Shape-Space Covering")
    # create_null_epsilon_plot(gd -> get_shape_space_covering(gd, 10), "10-Shape-Space Covering")
    # create_null_epsilon_plot(get_average_phenotype_evolvability_robustness_cor, "Phenotype Evolvability Robustness Correlation")
    # create_null_epsilon_plot(get_average_phenotype_evolvability, "Phenotype Evolvability")
    create_null_epsilon_plot(get_average_phenotype_robustness, "Phenotype Robustness")
    create_null_epsilon_plot(get_nn_size_percentile, "NN Size Skewness")
    create_null_epsilon_plot(get_average_nn_size, "NN Size")
    create_null_epsilon_plot(get_average_diameter, "NN Diameter")
    create_null_epsilon_plot(get_average_radius, "NN Radius")
    create_null_epsilon_plot(get_average_clustering, "NN Clustering")
end
