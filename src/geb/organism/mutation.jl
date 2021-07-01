function get_mutated_genotype(genotype)
    if MUTATION_PROBABILITY*length(genotype) < rand() return genotype end

    choices = [i for (i, _) in enumerate(genotype)]
    choice = rand(choices) # determine which bit to flip
    return genotype[1:(choice-1)] * ((genotype[choice] == '1') ? "0" : "1" ) * genotype[(choice+1):end]
end