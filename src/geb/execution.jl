using Random
import SharedArrays
import Base.Threads.@threads

function execute!(model::GebModel)
    # 0. log births of the initial organisms in the first execution step

    if model.time == 0
        for organism in model.organisms
            log_birth(model.logger, model, organism)
        end
    end
    
    shuffle(model.organisms)
    organisms_in_batch = [(i, o) for (i, o) in enumerate(model.organisms)] # model.organisms[((batch - 1)*NUM_THREADS_GEB + 1):min(end, batch*NUM_THREADS_GEB)]
    
    activations_in_batch = SharedArrays.SharedArray{Float64}(length(organisms_in_batch), 4*MAX_NEURONS)
    activation_size_in_batch = SharedArrays.SharedArray{UInt8}(length(organisms_in_batch))
    
    for i in 1:length(organisms_in_batch)
        for j in 1:MAX_NEURONS
            activations_in_batch[i, j] = 0.0
        end
        activation_size_in_batch[i] = 0
    end
    
    @threads for (i, organism) in organisms_in_batch
        develop_nodes!(organism.network, organism.rules)
    end
    
    @threads for (i, organism) in organisms_in_batch
        activations = determine_input_activations(model, organism)
        num_outputs = length(activations)
        
        activations_in_batch[i, 1:num_outputs] = activations
        activation_size_in_batch[i] = num_outputs
    end
    
    @threads for (i, organism) in organisms_in_batch
        activate_inputs!(organism.network, activations_in_batch[i, 1:activation_size_in_batch[i]])
    end

    for (_, organism) in organisms_in_batch
        if !(organism in model.organisms) continue end

        perform!(model, organism)
        organism.age += 1
    end

    model.time += 1
    log_step(model.logger, model, false)
end
