abstract type SearchDirection end
struct SearchBackward <: SearchDirection end
struct SearchForward <: SearchDirection end
struct SearchBoth <: SearchDirection end

function search_template(model::TierraModel, organism::TierrianOrganism, start_address, direction::SearchDirection)
    template = _get_template(model, start_address)
    template_length = length(template)
    
    for distance in 1:MAX_SEARCH_DISTANCE
        address = _get_address_if_match(direction, model, start_address, template, distance)
        
        if (address != -1)
            return address, template_length
        end
    end

    # no match found -> set error flag and return address after template
    organism.error_flag = true

    return start_address + template_length, template_length
end

function _get_address_if_match(direction::Union{SearchBackward, SearchForward}, model, template_address, template, distance)
    template_length = length(template)
    start_address = _get_address_within_distance(direction, template_address, template_length, distance)

    instructions = read_memory(model, start_address, template_length)

    next_address = start_address + template_length

    return instructions == template ? next_address : -1
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
    return template_address - distance - template_length + one(UInt16)
end
function _get_address_within_distance(::SearchForward, template_address, template_length, distance)
    return template_address + template_length + distance - one(UInt16)
end

function _get_template(model, address)
    template = []

    current_address = address

    while true
        instruction_int = read_memory(model, current_address) 
        instruction = convert_instruction(instruction_int)

        if (instruction != NOP_0() && instruction != NOP_1()) break end
        
        push!(template, 1-instruction_int)
        current_address += one(UInt16)
    end
    
    return template
end