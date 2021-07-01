struct Rule
    predecessor::String

    successor_1::String
    successor_2::String

    reverse_input::Bool
    reverse_output::Bool

    inhibitory_1_2::Bool
    excitatory_1_2::Bool

    inhibitory_2_1::Bool
    excitatory_2_1::Bool

    start_index::UInt32
    end_index::UInt32
end

Base.length(rule::Rule) = length(rule.predecessor)
Base.isequal(rule1::Rule, rule2::Rule) = hash(rule1) == hash(rule2)
function Base.hash(rule1::Rule)
    hash((rule1.predecessor, rule1.successor_1, rule1.successor_2, rule1.reverse_input, rule1.reverse_output, rule1.inhibitory_1_2, rule1.excitatory_1_2, rule1.inhibitory_2_1, rule1.excitatory_2_1))
end