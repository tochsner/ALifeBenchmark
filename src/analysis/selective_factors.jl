get_total_fitness_variance(history::History) = var(get_fitness.(get_detailed_history(history)))

function get_inherent_variance(history::History)
    organisms = get_detailed_history(history)
    return mean(var(mean(organisms, [EnvironmentType(), PopulationType(), NumOffspringsType()]), [EnvironmentType(), PopulationType()]))
end

function get_mutational_variance(history::History)
    organisms = get_detailed_history(history)
    return mean(var(organisms, [EnvironmentType(), PopulationType(), NumOffspringsType()]))
end

function get_abiotic_variance(history::History) 
    organisms = get_detailed_history(history)
    return var(mean(organisms, [EnvironmentType()]))
end

function get_biotic_variance(history::History) 
    organisms = get_detailed_history(history)
    return mean(var(mean(organisms, [EnvironmentType(), PopulationType()]), [EnvironmentType()]))
end