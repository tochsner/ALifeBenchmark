mutable struct GebOrganism
    key::UInt64

    genotype::String
    rules::Vector{Rule}
    
    coordinates::Tuple{Float64, Float64}
    direction::UInt16

    network::Network

    parent_genotypes::Tuple{String, String}

    time_birth::UInt64
    age::UInt64

    daughters::Vector{GebOrganism}

    function GebOrganism(genotype, coordinates)
        GebOrganism(0, genotype, coordinates)
    end
    function GebOrganism(key, genotype, coordinates)
        GebOrganism(key, genotype, coordinates, "", "", 0)
    end
    function GebOrganism(genotype, coordinates, parent_1_genotype, parent_2_genotype, time)
        GebOrganism(0, genotype, coordinates, parent_1_genotype, parent_2_genotype, time)
    end
    function GebOrganism(key, genotype, coordinates, parent_1_genotype, parent_2_genotype, time)
        rules = get_filtered_rules(genotype)
        direction = rand(0:359)
        network = get_axiom_network()

        new(key, genotype, rules, coordinates, direction, network, 
            (parent_1_genotype, parent_2_genotype), time, 0, [])
    end
end
