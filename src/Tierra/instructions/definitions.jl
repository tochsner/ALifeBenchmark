abstract type TierrianInstruction end

struct NOP_0 <: TierrianInstruction end
struct NOP_1 <: TierrianInstruction end

struct OR_1 <: TierrianInstruction end
struct SH_L <: TierrianInstruction end
struct ZERO <: TierrianInstruction end

struct IF_0 <: TierrianInstruction end

struct SUB_AB <: TierrianInstruction end
struct SUB_AC <: TierrianInstruction end

struct INC_A <: TierrianInstruction end
struct INC_B <: TierrianInstruction end
struct INC_C <: TierrianInstruction end
struct DEC_C <: TierrianInstruction end

struct PUSH_A <: TierrianInstruction end
struct PUSH_B <: TierrianInstruction end
struct PUSH_C <: TierrianInstruction end
struct PUSH_D <: TierrianInstruction end

struct POP_A <: TierrianInstruction end
struct POP_B <: TierrianInstruction end
struct POP_C <: TierrianInstruction end
struct POP_D <: TierrianInstruction end

struct JMP <: TierrianInstruction end
struct JMP_BACK <: TierrianInstruction end

struct CALL <: TierrianInstruction end
struct RET <: TierrianInstruction end

struct MOV_AB <: TierrianInstruction end
struct MOV_CD <: TierrianInstruction end
struct MOVI_BA <: TierrianInstruction end

struct ADR_A <: TierrianInstruction end
struct ADR_BACK_A <: TierrianInstruction end
struct ADR_FORW_A <: TierrianInstruction end

struct MALLOC <: TierrianInstruction end
struct DIVIDE <: TierrianInstruction end

const INT_TO_INS = Dict{UInt8, TierrianInstruction}(
    00 => NOP_0(),
    01 => NOP_1(),
    02 => OR_1(),
    03 => SH_L(),
    04 => ZERO(),
    05 => IF_0(),
    06 => SUB_AB(),
    07 => SUB_AC(),
    08 => INC_A(),
    09 => INC_B(),
    10 => INC_C(),
    11 => DEC_C(),
    12 => PUSH_A(),
    13 => PUSH_B(),
    14 => PUSH_C(),
    15 => PUSH_D(),
    16 => POP_A(),
    17 => POP_B(),
    18 => POP_C(),
    19 => POP_D(),
    20 => JMP(),
    21 => JMP_BACK(),
    22 => CALL(),
    23 => RET(),
    24 => MOV_AB(),
    25 => MOV_CD(),
    26 => MOVI_BA(),
    27 => ADR_A(),
    28 => ADR_BACK_A(),
    29 => ADR_FORW_A(),
    30 => MALLOC(),
    31 => DIVIDE()
)

const INS_TO_INT = Dict{TierrianInstruction, UInt8}(
    NOP_0() => 00,
    NOP_1() => 01,
    OR_1() => 02,
    SH_L() => 03,
    ZERO() => 04,
    IF_0() => 05,
    SUB_AB() => 06,
    SUB_AC() => 07,
    INC_A() => 08,
    INC_B() => 09,
    INC_C() => 10,
    DEC_C() => 11,
    PUSH_A() => 12,
    PUSH_B() => 13,
    PUSH_C() => 14,
    PUSH_D() => 15,
    POP_A() => 16,
    POP_B() => 17,
    POP_C() => 18,
    POP_D() => 19,
    JMP() => 20,
    JMP_BACK() => 21,
    CALL() => 22,
    RET() => 23,
    MOV_AB() => 24,
    MOV_CD() => 25,
    MOVI_BA() => 26,
    ADR_A() => 27,
    ADR_BACK_A() => 28,
    ADR_FORW_A() => 29,
    MALLOC() => 30,
    DIVIDE() => 31
)

convert_instruction(instruction::Integer) = INT_TO_INS[instruction % 32]
convert_instruction(instruction::TierrianInstruction) = INS_TO_INT[instruction]

convert_instructions(instructions::Vector{Integer}) = [INT_TO_INS[i] for i in instructions]
convert_instructions(instructions::Vector{TierrianInstruction}) = [INS_TO_INT[i] for i in instructions]