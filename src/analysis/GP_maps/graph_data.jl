using Serialization
using LightGraphs
using SimpleWeightedGraphs
using MetaGraphs
using Bijections
using Statistics
import LightGraphs.Parallel
import Base.Threads.@threads

mutable struct GGraphData
    genotype_vertex_mapping::Bijection
    genotype_graph::SimpleWeightedDiGraph
    
    phenotype_graph::SimpleWeightedDiGraph

    neutral_networks::Vector
    neutral_network_graph::SimpleWeightedDiGraph

    fitness_values::Dict

    GGraphData() = new(Bijection(), SimpleWeightedDiGraph(0), SimpleWeightedDiGraph(0), [], SimpleWeightedDiGraph(0), Dict())
end