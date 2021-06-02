mutable struct History
    default::Vector{Organism}
    detailed::Union{Vector{DetailedOrganism}, Nothing}
    
    ordered_by::Dict{PropertyType, Dict{Any, Vector{DetailedOrganism}}}

    History(organisms) = new(organisms, nothing, Dict())
end

get_default_history(history::History) = history.default

function get_detailed_history(history::History)
    if history.detailed === nothing
        history.detailed = [DetailedOrganism(org, 0, 0, Dict()) for org in history.default]
    
        id_to_organism = Dict([get_id(o) => o for o in history.detailed])        
        
        # calculate the numer of offsprings
        for organism in history.detailed
            if organism.parent != -1
                parent = id_to_organism[organism.parent]
                parent.num_offsprings += 1
                
                if parent.genotype == organism.genotype
                    parent.num_identical_offsprings += 1
                end
            end
        end
   
        # calculate populations
        currently_alive = []

        current_time = 0
        born_at_current_time = []

        for organism in history.detailed
            if length(born_at_current_time) == 0
                current_time = organism.time_birth
                born_at_current_time = [organism]

            elseif organism.time_birth == current_time
                push!(born_at_current_time, organism)
                continue

            else
                # remove dead from currently_alive and add newborn
                currently_alive = [o for o in currently_alive if o.time_death < current_time]                
                append!(currently_alive, born_at_current_time)
                
                for born in born_at_current_time
                    population = born.population

                    for alive in currently_alive
                        genotype = alive.genotype

                        if haskey(population, genotype)
                            population[genotype] += 1
                        else
                            population[genotype] = 1
                        end
                    end
                end

                current_time = organism.time_birth
                born_at_current_time = []
            end
        end
        
    end

    return history.detailed
end


function get_grouped_by(history::History, properties::PropertyType...) 
    if !haskey(history.ordered_by, properties)
        history.ordered_by[properties] = _group_by(get_detailed_history(history), get_group_function(properties))
    end

    history.ordered_by[properties]
end