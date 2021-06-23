using Random

function execute!(model::GebModel)
    shuffle(model.organisms)

    for index in 1:length(model.organisms)
        if length(model.organisms) < index break end

        organism = model.organisms[index]

        if get_number_neurons(organism) < MAX_NEURONS
            develop_nodes!(organism.network, organism.rules)
        end

        update_inputs!(model, organism)
        perform!(model, organism)
    end
end
