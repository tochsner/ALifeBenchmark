function search_template(model::TierraModel, organism::TierrianOrganism, start_address, direction::SearchDirection)
    template = _get_template(model, start_address)
    template_length = length(template)

    if 0 < template_length
        for distance in 1:MAX_SEARCH_DISTANCE
            template_address = _get_address_if_match(direction, model, start_address, template, distance)

            if (template_address != -1)
                return template_address, template_length
            end
        end
    end

    # no match found -> set error flag and return address after template
    organism.error_flag = true

    template_address = normalize_address(start_address + template_length)
    return template_address, template_length
end

function _get_address_if_match(direction::Union{SearchBackward, SearchForward}, model, template_address, template, distance)
    template_length = length(template)
    start_address = _get_address_within_distance(direction, template_address, template_length, distance)

    for i in 0:(template_length - 1)
        instruction = read_memory(model, start_address + i)

        if instruction != template[i+1]
            return -1
        end
    end

    next_address = normalize_address(start_address + template_length)
    return next_address
end

function _get_address_if_match(::SearchBoth, model, template_address, template, distance)
    forward_address = _get_address_if_match(SearchForward(), model, template_address, template, distance)

    if forward_address != -1
        return forward_address
    else
        return _get_address_if_match(SearchBackward(), model, template_address, template, distance)
    end
end

function _get_address_within_distance(::SearchBackward, template_address, template_length, distance)
    return normalize_address(template_address - distance - template_length + one(UInt16))
end
function _get_address_within_distance(::SearchForward, template_address, template_length, distance)
    return normalize_address(template_address + template_length + distance - one(UInt16))
end

function _get_template(model, address)
    template = []

    current_address = address

    while length(template) < MAX_TEMPLATE_LENGTH
        instruction_int = read_memory(model, current_address)
        instruction = convert_instruction(instruction_int)

        if (instruction != NOP_0() && instruction != NOP_1()) break end

        push!(template, 1-instruction_int)
        current_address += one(UInt16)
    end

    return template
end
