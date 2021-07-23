using ALifeBenchmark
using Plots
using Measures

if length(ARGS) == 1
    trial_id = ARGS
else
    trial_id = "22578359168939802"
end

most_frequent_genotypes = []

snapshot_ids = get_snapshot_ids(trial_id)

for snapshot_id in snapshot_ids
    genotype_distribution = get_snapshot(snapshot_id) |> get_genotype_distribution

    current_frequent_genotypes = [g for (g, n) in genotype_distribution if n >= 0.01]
    append!(most_frequent_genotypes, current_frequent_genotypes)
end

most_frequent_genotypes = unique(most_frequent_genotypes)

println(length(most_frequent_genotypes))

"""
graph_data = load_graph_data()

nn_dict = Dict()
nns = []
for genotype in most_frequent_genotypes
    global cnt
    
    nn = 0
    for (i, neutral_network) in enumerate(graph_data.neutral_networks)        
        if haskey(graph_data.genotype_vertex_mapping, genotype) && graph_data.genotype_vertex_mapping[genotype] in neutral_network
            nn = i
        end
    end
    
    if haskey(nn_dict, nn) == false 
        nn_dict[nn] = length(nn_dict) + 1
    end

    push!(nns, nn_dict[nn])
end

@assert length(nns) == length(most_frequent_genotypes)


occurances = zeros(length(snapshot_ids), length(nn_dict))
times = zeros(length(snapshot_ids))

for (i, snapshot_id) in enumerate(snapshot_ids)
    genotype_distribution = get_snapshot(snapshot_id) |> get_genotype_distribution
    times[i] = get_snapshot(snapshot_id).time

    for (j, genotype) in enumerate(most_frequent_genotypes)
        if haskey(genotype_distribution, genotype)
            occurances[i, nns[j]] += genotype_distribution[genotype]
        end
    end
end

"""
occurances = zeros(length(snapshot_ids), length(most_frequent_genotypes))

for (i, snapshot_id) in enumerate(snapshot_ids)
    genotype_distribution = get_snapshot(snapshot_id) |> get_genotype_distribution

    for (j, genotype) in enumerate(most_frequent_genotypes)
        if haskey(genotype_distribution, genotype)
            occurances[i, j] += genotype_distribution[genotype]
        end
    end
end


plot(times, occurances,
        title = "",
        label = "",
        xguide = "Time",
        yguide = "Genotype Occurances",
        size = (900, 600),
        margin = 10mm,
        dpi = 1000)
savefig("genotype_distribution_$trial_id.png")