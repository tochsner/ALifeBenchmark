mutable struct GebOrganism
    key::UInt32
    genotype::String
    rules::Vector{Rule}
    coordinates::Tuple{Float64, Float64}
    direction::UInt16

    network::Network

    function GebOrganism(genotype, coordinates)
        GebOrganism(0, genotype, coordinates)
    end
    function GebOrganism(key, genotype, coordinates)
        rules = get_filtered_rules(genotype)
        direction = rand(0:359)
        network = get_axiom_network()

        new(key, genotype, rules, coordinates, direction, network)
    end
end
