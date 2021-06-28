using Printf

function Base.show(io::IO, organism::TierrianOrganism, model::TierraModel)
    println(io, "-"^10)

    println(io, organism.hash)
    println(io, organism.parent_hash)
    
    println(io, "*Last Instruction*")

    ip = _address_within(organism, organism.ip - 1)
    instruction_int = read_memory(model, ip)
    instruction = convert_instruction(instruction_int)
    @printf(io, "%16i \t %5i %s \n", ip, instruction_int, instruction)

    println(io, "*GENOME*")
    
    for line::UInt16 in organism.start_address:(organism.start_address - 1 + organism.length)
        instruction_int = read_memory(model, line)
        instruction = convert_instruction(instruction_int)
        if line == ip
            @printf(io, "=> %16i \t %5i %s \n", line, instruction_int, instruction)
        else
            @printf(io, "   %16i \t %5i %s \n", line, instruction_int, instruction)
        end
    end

    println(io, "*STACK*")
    
    for element in organism.stack
        @printf(io, "%16i", element)
    end

    println(io, "*Registers*")

    @printf(io, "a: %16i \t", organism.a)
    @printf(io, "b: %16i \t", organism.b)
    @printf(io, "c: %16i \t", organism.c)
    @printf(io, "d: %16i \n", organism.d)
end

function Base.show(io::IO, model::TierraModel)
    println(io, "-"^50)
    print(model.free_blocks)
    println(io, "-"^50)
    for key in model.organism_keys[1:min(length(model.organism_keys), 5)]
        print(key)
        organism = model.organisms[key]
        show(io, organism, model)
    end
end

function Base.show(io::IO, free_block::FreeMemoryBlock)
    @printf(io, "%16i \t %16i \n", free_block.start_address, free_block.length)
end

function print_program(program::Vector{UInt8})
    for instruction_int in program
        instruction = convert_instruction(instruction_int)
        println(instruction)
    end
end