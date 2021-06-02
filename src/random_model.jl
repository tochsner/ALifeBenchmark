using Random: rand

mutable struct RandomModel <: ALifeModel
    num_organisms
    num_genotypes
    current_organisms::Vector{Organism}
    current_time

    RandomModel(num_organisms, num_genotypes) = new(num_organisms, num_genotypes, [], 0)
end

struct IntGenotype <: Genotype
    genotype::Int
end

function init!(model::RandomModel)
    model.current_organisms = _get_random_organism(model)
end

function iterate!(model::RandomModel)
    current_organisms = model.current_organisms
    model.current_organisms = _get_random_organism(model)
    model.current_time += 1
    return current_organisms
end

function _get_random_organism(model::RandomModel)
    new_genotypes = rand(1:model.num_genotypes, model.num_organisms)

    if model.current_organisms == []    
        return [Organism(IntGenotype(new), Ancestor(), model.current_time, model.current_time+1) 
                    for new in new_genotypes]
    else
        return [Organism(IntGenotype(new), old, model.current_time, model.current_time+1) 
                    for (new, old) in zip(new_genotypes, model.current_organisms)]
    end
end