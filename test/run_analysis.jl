using ALifeBenchmark
import SharedArrays.SharedArray
using Plots
using Random
using Serialization
import Base.Threads.@threads
using StringDistances: Levenshtein
using Measures
using LightGraphs

function plot_result(times, values, name, trial_id)
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
    savefig("$name$trial_id.svg")
end

function plot_result(times_1, times_2, values, name, trial_id)
    plot(times_1, times_2, 
            marker_z  = values,
            title = "",
            label = "",
            xguide = "Time",
            yguide = name,
            seriestype = :scatter,
            markersize = 3,
            markerstrokewidth = 0,
            size = (900, 600),
            margin = 10mm,
            dpi = 1000)
    savefig("$name$trial_id")
end

function save_result(data, name, trial_id)
    serialize("$name$trial_id", data)
end

function collect_basic_statistic(abbrevation, trial_id, get_statistic)
    collect_compare_to_end_statistic(abbrevation, trial_id, (x, _) -> get_statistic(x), identity)
end

function collect_compare_to_end_statistic(abbrevation, trial_id, get_statistic, prepare)
    @info "Start $abbrevation"

    snapshot_ids = get_snapshot_ids(trial_id)
    num_snapshots = length(snapshot_ids)

    prepared_last = last(snapshot_ids) |> get_snapshot |> prepare

    values = SharedArray{Float64}(num_snapshots)
    times = SharedArray{UInt64}(num_snapshots)

    done = Threads.Atomic{Int}(0)

    @threads for (i, snapshot_id) in (shuffle(snapshot_ids) |> enumerate |> unique)
        snapshot = get_snapshot(snapshot_id)
        prepared = prepare(snapshot)

        current_value = get_statistic(prepared, prepared_last)
        current_time = get_time(snapshot)
        
        values[i] = current_value
        times[i] = current_time

        Threads.atomic_add!(done, 1)
        @info "$abbrevation \t $(done[] / num_snapshots) \t $current_time \t $current_value"

        if done[] % 100 == 0
            # plot_result(Array(times), Array(values), abbrevation, trial_id)
            # save_result((Array(times), Array(values)), abbrevation, trial_id)
        end
    end

    return (Array(times), Array(values))
end

function collect_cross_statistic(abbrevation, trial_id, get_statistic, prepare)
    @info "Start $abbrevation"

    snapshot_ids = get_snapshot_ids(trial_id)
    num_snapshots = length(snapshot_ids)

    values = SharedArray{Float64}(num_snapshots^2)
    times_1 = SharedArray{UInt64}(num_snapshots^2)
    times_2 = SharedArray{UInt64}(num_snapshots^2)

    done = Threads.Atomic{Int}(0)

    @threads for (i, snapshot_id_1) in (shuffle(snapshot_ids[1:5:end]) |> enumerate |> unique)
        snapshot_1 = get_snapshot(snapshot_id_1)
        prepared_1 = prepare(snapshot_1)
        time_1 = get_time(snapshot_1)

        for (j, snapshot_id_2) in (shuffle(snapshot_ids[1:5:end]) |> enumerate |> unique)
            snapshot_2 = get_snapshot(snapshot_id_2)
            prepared_2 = prepare(snapshot_2)
            time_2 = get_time(snapshot_2)

            current_value = get_statistic(prepared_1, prepared_2)

            index = (i-1)*num_snapshots + j
            
            values[index] = current_value
            times_1[index] = time_1
            times_2[index] = time_2

            Threads.atomic_add!(done, 1)
            
            if done[] % 1000 == 0
                @info "$abbrevation \t $(done[] / num_snapshots / num_snapshots) \t $time_1 \t $time_2 \t $current_value"
            end

            if done[] % 100_000 == 0
                plot_result(Array(times_1), Array(times_2), Array(values), abbrevation, trial_id)
                save_result((Array(times_1), Array(times_2), Array(values)), abbrevation, trial_id)
            end
        end
    end

    return (Array(times_1), Array(times_2), Array(values))
end

"""
Build Cache
"""
phenotype_cache = Dict()
graph_data = load_graph_data()

for edge in edges(graph_data.phenotype_graph)
    u, v = src(edge), dst(edge)
    genotype_u, genotype_v = graph_data.genotype_vertex_mapping(u), graph_data.genotype_vertex_mapping(v)

    phenotype_similarity = edge.weight
    phenotype_cache[(genotype_u, genotype_v)] = phenotype_similarity
    phenotype_cache[(genotype_v, genotype_u)] = phenotype_similarity
end

"""
COLLECT STATISTIC
"""

if length(ARGS) == 2
    trial_id, type_of_analysis = ARGS
    threshold = 0.001
    min_samples, max_samples = 50, 500
elseif length(ARGS) == 5
    trial_id, type_of_analysis, threshold, min_samples, max_samples = ARGS
    threshold = parse(Float64, threshold)
    min_samples = parse(Int, min_samples)
    max_samples = parse(Int, max_samples)
else
    trial_id = "12433992799852588"
    type_of_analysis = "LA"
    threshold = 0.001
    min_samples, max_samples = 50, 500
end

@info ARGS

if type_of_analysis == "LA"
    result = collect_compare_to_end_statistic(
        type_of_analysis, 
        trial_id, 
        (snapshot, last_snapshot) -> get_adaption_of_snapshot(last_snapshot, snapshot, threshold, min_samples, max_samples), 
        identity
    )

elseif type_of_analysis == "RF"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_reachable_fitness(snapshot, threshold, min_samples, max_samples))

elseif type_of_analysis == "RD"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_reachable_diversity(snapshot, threshold, min_samples, max_samples))

elseif type_of_analysis == "PD"
    result = collect_compare_to_end_statistic(
        type_of_analysis, 
        trial_id,  
        (distribution, last_distribution) -> _wasserstein(last_distribution, distribution, Levenshtein()),
        get_genotype_distribution
    )

elseif type_of_analysis == "EP"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_evolutionary_potential(snapshot, 600_000, threshold, min_samples, max_samples))

elseif type_of_analysis == "CPD"
    result = collect_cross_statistic(
        type_of_analysis, 
        trial_id,  
        (distribution_1, distribution_2) -> _wasserstein(distribution_1, distribution_2, Levenshtein()),
        get_genotype_distribution
    )

elseif type_of_analysis == "CLA"
    result = collect_cross_statistic(
        type_of_analysis, 
        trial_id, 
        (snapshot_1, snapshot_2) -> get_adaption_of_snapshot(snapshot_1, snapshot_2, threshold, min_samples, max_samples), 
        identity
    )

elseif type_of_analysis == "ENT"
    result = collect_basic_statistic(type_of_analysis, trial_id, get_entropy)

elseif type_of_analysis == "GD"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_genotype_diversity(snapshot, Levenshtein(), threshold, min_samples, max_samples))

elseif type_of_analysis == "PHD"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_phenotype_diversity(snapshot, threshold, min_samples, max_samples))

elseif type_of_analysis == "NN"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_neutrality(snapshot, 1e-5, phenotype_cache))

elseif type_of_analysis == "NullNN"
    result = collect_basic_statistic(type_of_analysis, trial_id, snapshot -> get_neutrality_null_model(snapshot, 1e-5, phenotype_cache))

end

plot_result(result..., type_of_analysis, trial_id)
save_result(result, type_of_analysis, trial_id)
