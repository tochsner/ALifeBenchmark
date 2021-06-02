abstract type ALifeModel end

function init! end
function iterate! end
function set_state! end

function run_simulation(model::ALifeModel, num_iterations)
    organisms_lived = Organism[]

    init!(model)

    for _ in 1:num_iterations
        new_organisms = iterate!(model)
        append!(organisms_lived, new_organisms)
    end

    for (id, organism) in enumerate(organisms_lived)
        organism.id = id
    end

    return organisms_lived
end