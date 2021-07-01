get_filtered_rules(genotype::String) = filter_rules(get_rules(genotype))

function get_rules(genotype::String)
    rules = []

    for (i, _) in enumerate(genotype)
        rule = _get_rule_at(genotype, i)

        if rule !== nothing
            push!(rules, rule)
        end
    end

    return rules
end

function filter_rules(rules)
    if length(rules) <= 1 return rules end

    rules = unique(rules)

    all_chosen_rules = []

    currently_chosen_rules = []

    # add best-matching rules for axiom network

    for node in AXIOM_NODES
        append!(currently_chosen_rules, find_best_matches(node, rules))
    end

    currently_chosen_rules = unique(currently_chosen_rules)
    currently_chosen_rules = _append_non_overlapping!(all_chosen_rules, currently_chosen_rules)

    # repeatedly add the best matching predecessor for each successor

    while 0 < length(currently_chosen_rules)
        last_chosen_rules = currently_chosen_rules
        currently_chosen_rules = []

        for chosen_rule in last_chosen_rules
            append!(currently_chosen_rules, find_best_matches(chosen_rule.successor_1, rules))
            append!(currently_chosen_rules, find_best_matches(chosen_rule.successor_2, rules))
        end

        currently_chosen_rules = unique(currently_chosen_rules)
        setdiff!(currently_chosen_rules, all_chosen_rules)
        currently_chosen_rules = _append_non_overlapping!(all_chosen_rules, currently_chosen_rules)
    end

    all_chosen_rules = unique(all_chosen_rules)

    return all_chosen_rules
end

function _append_non_overlapping!(existing_rules, rules_to_add)
    rules_added = []
    
    for to_add in rules_to_add
        exists_overlapping_rule = false

        for existing in existing_rules
            if _overlap(to_add, existing)
                exists_overlapping_rule = true
                break
            end
        end

        if !exists_overlapping_rule
            push!(existing_rules, to_add)
            push!(rules_added, to_add)
        end
    end

    return rules_added
end

function _overlap(rule_1, rule_2)
    rule_1.start_index <= rule_2.start_index <= rule_1.end_index ||
        rule_2.start_index <= rule_1.start_index <= rule_2.end_index
end

find_best_matches(node::Node, rules) = find_best_matches(node.string, rules)
function find_best_matches(node::String, rules)
    best_matches = []
    best_match_length = 0

    for rule in rules
        if _is_match(rule, node)
            if best_match_length == length(rule)
                push!(best_matches, rule)
            elseif best_match_length < length(rule)
                best_match_length = length(rule)
                best_matches = [rule]
            end
        end
    end

    return best_matches
end

_is_match(rule::Rule, node) = _is_match(rule.predecessor, node)
_is_match(rule, node) = startswith(node, rule)

function _get_rule_at(genotype, position)
    start = position

    len_genotype = length(genotype)

    if len_genotype <= position + 2 return nothing end

    #  valid rule starts with 11
    if genotype[position:position + 1] != "11" return nothing end

    position += 2
    if len_genotype < position return nothing end

    # read predecessor
    predecessor = _segment_at(genotype, position)
    position += 2*length(predecessor) + 1
    if len_genotype < position return nothing end

    # read successor 1
    successor_1 = _segment_at(genotype, position)
    position += 2*length(successor_1) + 1
    if len_genotype < position return nothing end

    # read successor 2
    successor_2 = _segment_at(genotype, position)
    position += 2*length(successor_2) + 1
    if len_genotype < position return nothing end

    # read bits
    if len_genotype < position + 5 return nothing end
    bits = genotype[position:position + 5]

    return Rule(predecessor, successor_1, successor_2,
                _to_bool(bits[1]), _to_bool(bits[2]),
                _to_bool(bits[3]), _to_bool(bits[4]),
                _to_bool(bits[5]), _to_bool(bits[6]),
                start, position + 5)
end

function _segment_at(genotype, start)
    segment = ""

    for i in start:2:(length(genotype) - 1)
        if genotype[i] == '1'
            return segment
        end

        segment = segment * genotype[i + 1]
    end

    return segment
end

_to_bool(x::Char) = x == '1'
