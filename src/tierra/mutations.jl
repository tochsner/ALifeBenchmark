function get_mutated_instruction(instruction)
    choices = [1, 2, 4, 8, 16]
    choice = rand(choices) # determine which bit to flip
    return instruction ⊻ choice # XOR
end