using Printf

function Base.show(io::IO, model::GebModel)
    println(io, "-"^10)
    
    for y in 1:model.size
        for x in 1:model.size
            print(io, (model.grid[x, y] === nothing) ? " " : "#")
        end
        println(io)
    end

    println(io)

    for organism in model.organisms
        Base.show(io, organism)
    end
end

function Base.show(io::IO, organism::GebOrganism)
    @printf(io, "(%2i, %2i) \t %3i \t %s \t %i\n", organism.coordinates[1], organism.coordinates[2], organism.direction, organism.genotype, length(organism.rules))
end

function Base.show(io::IO, network::Network)
    apply_to_all(network.inputs[1]) do node 
        Base.show(io, node)
    end
end

function Base.show(io::IO, node::Node)
    if node.type == ExternalNode()
        println(io, "EXT\t", node.string, " ", sum(node.excitatory_activation))
    elseif node.type == InputNode()
        println(io, "INP\t", node.string, " ", [x.string for x in node.in_inhibitory], [x.string for x in node.in_excitatory],
                [x.string for x in node.out_inhibitory], [x.string for x in node.out_excitatory])
    elseif node.type == OutputNode()
        println(io, "OUT\t", node.string, " ", [x.string for x in node.in_inhibitory], [x.string for x in node.in_excitatory],
                [x.string for x in node.out_inhibitory], [x.string for x in node.out_excitatory])
    else
        println(io, "HID\t", node.string, " ", [x.string for x in node.in_inhibitory], [x.string for x in node.in_excitatory],
                [x.string for x in node.out_inhibitory], [x.string for x in node.out_excitatory])
    end
end
    