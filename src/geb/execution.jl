using Random

function execute!(model::GebModel)
    if model.time == 0
        for organism in model.organisms
            log_birth(model.logger, model, organism)
        end
    end

    shuffle(model.organisms)

    for index in 1:length(model.organisms)
        if length(model.organisms) < index break end

        organism = model.organisms[index]

        if get_number_neurons(organism) < MAX_NEURONS
            develop_nodes!(organism.network, organism.rules)
        end

        update_inputs!(model, organism)
        perform!(model, organism)

        organism.age += 1
    end

    model.time += 1

    log_step(model.logger, model)
end
