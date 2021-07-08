"""
A simple null model consisting of a fixed size population of 
organisms where in each generation, some random mutations are 
introduced.
"""
struct RandomModel
    current_population::Vector{Vector{Bool}}

    genotype_length::UInt8
    mutation_probability::FLoat64
    population_size::UInt8

    function RandomModel(genotype_length, mutation_probability, population_size)
        new([falses(genotype_length) for _ in 1:population_size], 
            genotype_length, mutation_probability, population_size)
    end
end

function execute!(model::RandomModel)
    for organism in model.current_population
        if rand() < model.mutation_probability
            index_to_change = rand(1:model.population_size)
            organism[index_to_change] = !organism[index_to_change]
        end
    end
end