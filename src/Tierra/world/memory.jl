get_free_memory_size(model::TierraModel) = model.memory_size - model.used_memory
normalize_address(x) = mod(x, 2^16)

function read_memory(model::TierraModel, address) model.memory[mod(address, model.memory_size) + one(UInt16)] end
function read_memory(model::TierraModel, address, length) 
    return [read_memory(model, curr_addr) for curr_addr in address:(address + length - one(UInt16))]
end
function write_memory(model::TierraModel, organism::TierrianOrganism, address, instruction::UInt8)
    if organism_has_access(organism, address, 1)
        if MUTATE && rand() < FLAW_PROBABILITY
            model.memory[mod(address, model.memory_size) + one(UInt16)] = get_mutated_instruction(instruction)
        else
            model.memory[mod(address, model.memory_size) + one(UInt16)] = instruction
        end
    else # organism has no write access to this address
        organism.error_flag = true
    end   
end
function write_memory(model::TierraModel, organism::TierrianOrganism, start_address, instructions::Vector{UInt8})
    for (i, instrucion) in enumerate(instructions)
        write_memory(model, organism, start_address + i - 1, instrucion)
    end
end

function organism_has_access(organism::TierrianOrganism, address, length)
    if _is_within_range(address, length, organism.start_address, organism.length)
        true
    elseif organism.has_daughter && _is_within_range(address, length, organism.daughter_address, organism.daughter_length)
        true
    else
        false
    end
end

function clear_memory!(model::TierraModel, start_address, length)
    length = min(length, model.memory_size - start_address)

    # first, we test if there are existing overlapping blocks

    for i in 1:Base.length(model.free_blocks)
        free_block = model.free_blocks[i]

        overlap = _determine_overlap(start_address, length, free_block.start_address, free_block.length)
        
        if overlap in [ExactMatch(), Within(), WithinFromStart(), WithinToEnd()]
            return 0

        elseif overlap == LeftOverlap()
            return clear_memory!(model, start_address, free_block.start_address - start_address)

        elseif overlap == RightOverlap()
            return clear_memory!(model, free_block.start_address + free_block.length, start_address + length - free_block.start_address - free_block.length)

        elseif overlap == CompleteOverlap()
            return sum([
                clear_memory!(model, start_address, free_block.start_address - start_address),
                clear_memory!(model, free_block.start_address + free_block.length, start_address + length - free_block.start_address - free_block.length)
                ])
        end
    end

    # if there is no overlapping block, we serach for potential neighboring free blocks to merge

    index_left_neighbor = -1
    index_right_neighbor = -1

    for i in 1:Base.length(model.free_blocks)
        free_block = model.free_blocks[i]

        overlap = _determine_overlap(start_address, length, free_block.start_address, free_block.length)
        
        if overlap == LeftNeighbor()
            @assert index_left_neighbor == -1
            index_left_neighbor  = i
        elseif overlap == RightNeighbor()
            @assert index_right_neighbor == -1
            index_right_neighbor = i
        end
    end
    
    if index_left_neighbor != -1 && index_right_neighbor == -1
        free_block = model.free_blocks[index_left_neighbor]

        model.free_blocks[index_left_neighbor] = FreeMemoryBlock(start_address, free_block.length + length)
        model.used_memory -= length

        return length

    elseif index_left_neighbor == -1 && index_right_neighbor != -1
        free_block = model.free_blocks[index_right_neighbor]
        
        model.free_blocks[index_right_neighbor] = FreeMemoryBlock(free_block.start_address, free_block.length + length)
        model.used_memory -= length
        
        return length
        
    elseif index_left_neighbor != -1 && index_right_neighbor != -1
        free_block_right = model.free_blocks[index_left_neighbor] # the free block where the block to clear is the left neighbor is its right neighbor!!
        free_block_left = model.free_blocks[index_right_neighbor] # TODO

        model.free_blocks[index_left_neighbor] = FreeMemoryBlock(free_block_left.start_address, free_block_left.length + free_block_right.length + length)
        deleteat!(model.free_blocks, index_right_neighbor)

        model.used_memory -= length

        return length
    end
    
    # no overlapping or neighboring free memory blocks => create a new one

    push!(model.free_blocks, FreeMemoryBlock(start_address, length))
    model.used_memory -= length
    return length
end

function allocate_free_memory!(model::TierraModel, length)
    if get_free_memory_size(model) < length # no memory left
        return -1
    end

    for _ in 1:100
        block_index = rand(1:Base.length(model.free_blocks))
        block = model.free_blocks[block_index]

        if length <= block.length
            alloc_start, new_free_block = _allocate_in_block!(model, block, length)

            if new_free_block === nothing || new_free_block.length == 0
                deleteat!(model.free_blocks, block_index)
            else
                model.free_blocks[block_index] = new_free_block
            end

            model.used_memory += length            

            return alloc_start
        end 
    end

    return -1
end

function _allocate_in_block!(model::TierraModel, block::FreeMemoryBlock, length)
    if block.length == length
        return block.start_address, nothing
    end

    block_start = block.start_address

    if rand(["beginning", "end"]) == "beginning"
        alloc_start = block_start
        alloc_end = block_start + length
        new_free_block = FreeMemoryBlock(alloc_end, block.length - length)
    else
        alloc_start = block_start + block.length - length
        new_free_block = FreeMemoryBlock(block_start, block.length - length)
    end

    return alloc_start, new_free_block
end