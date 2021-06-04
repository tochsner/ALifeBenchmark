function apply!(::NOP_0, organism::TierrianOrganism, model::TierraModel) end
function apply!(::NOP_1, organism::TierrianOrganism, model::TierraModel) end

function apply!(::OR_1, organism::TierrianOrganism, model::TierraModel) organism.c = organism.c | 1 end
function apply!(::SH_L, organism::TierrianOrganism, model::TierraModel) organism.c = organism.c << 1 end
function apply!(::ZERO, organism::TierrianOrganism, model::TierraModel) organism.c = 0 end

function apply!(::IF_0, organism::TierrianOrganism, model::TierraModel)
    if (organism.c != 0) organism.ip = _address_within(organism, organism.ip + one(UInt16)) end 
end

function apply!(::SUB_AB, organism::TierrianOrganism, model::TierraModel) organism.c = organism.a - organism.b end
function apply!(::SUB_AC, organism::TierrianOrganism, model::TierraModel) organism.a = organism.a - organism.c end

function apply!(::INC_A, organism::TierrianOrganism, model::TierraModel) organism.a += one(UInt16) end
function apply!(::INC_B, organism::TierrianOrganism, model::TierraModel) organism.b += one(UInt16) end
function apply!(::INC_C, organism::TierrianOrganism, model::TierraModel) organism.c += one(UInt16) end
function apply!(::DEC_C, organism::TierrianOrganism, model::TierraModel) organism.c -= one(UInt16) end

function apply!(::PUSH_A, organism::TierrianOrganism, model::TierraModel) push!(organism.stack, organism.a) end
function apply!(::PUSH_B, organism::TierrianOrganism, model::TierraModel) push!(organism.stack, organism.b) end
function apply!(::PUSH_C, organism::TierrianOrganism, model::TierraModel) push!(organism.stack, organism.c) end
function apply!(::PUSH_D, organism::TierrianOrganism, model::TierraModel) push!(organism.stack, organism.d) end

function apply!(::POP_A, organism::TierrianOrganism, model::TierraModel) organism.a = _pop_stack!(organism) end
function apply!(::POP_B, organism::TierrianOrganism, model::TierraModel) organism.b = _pop_stack!(organism) end
function apply!(::POP_C, organism::TierrianOrganism, model::TierraModel) organism.c = _pop_stack!(organism) end
function apply!(::POP_D, organism::TierrianOrganism, model::TierraModel) organism.d = _pop_stack!(organism) end

function apply!(::JMP, organism::TierrianOrganism, model::TierraModel) 
    organism.ip, _ = search_template(model, organism, organism.ip, SearchBoth())
end
function apply!(::JMP_BACK, organism::TierrianOrganism, model::TierraModel)
    organism.ip, _ = search_template(model, organism, organism.ip, SearchBackward())
end

function apply!(::CALL, organism::TierrianOrganism, model::TierraModel) 
    callee_address, _ = search_template(model, organism, organism.ip, SearchBoth())
    push!(organism.stack, organism.ip)
    organism.ip = callee_address
end
function apply!(::RET, organism::TierrianOrganism, model::TierraModel) organism.ip = _pop_stack!(organism) end

function apply!(::MOV_AB, organism::TierrianOrganism, model::TierraModel) organism.b = organism.a end
function apply!(::MOV_CD, organism::TierrianOrganism, model::TierraModel) organism.d = organism.c end
function apply!(::MOVI_BA, organism::TierrianOrganism, model::TierraModel) 
    instruction = read_memory(model, organism.b)
    write_memory(model, organism, organism.a, instruction)
end

function apply!(::ADR_A, organism::TierrianOrganism, model::TierraModel) 
    organism.a, organism.c = search_template(model, organism, organism.ip, SearchBoth())
end
function apply!(::ADR_BACK_A, organism::TierrianOrganism, model::TierraModel) 
    organism.a, organism.c = search_template(model, organism, organism.ip, SearchBackward())
end
function apply!(::ADR_FORW_A, organism::TierrianOrganism, model::TierraModel) 
    organism.a, organism.c = search_template(model, organism, organism.ip, SearchForward())
end

function apply!(::MALLOC, organism::TierrianOrganism, model::TierraModel) allocate_daughter(model, organism) end
function apply!(::DIVIDE, organism::TierrianOrganism, model::TierraModel) divide(model, organism) end

function _pop_stack!(organism::TierrianOrganism)
    if isempty(organism.stack)
        organism.error_flag = true
        return 0
    else
        return pop!(organism.stack) 
    end
end
