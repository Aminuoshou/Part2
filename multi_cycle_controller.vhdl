------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : multi_cycle_controller.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : RISC-V Multi-Cycle Controller
-- Two-process FSM implementation with current_state and next_state.
-- Controls sequencing of datapath operations across FETCH, DECODE, MEMORY, etc.
-- Generates control signals for ALU, memory, register file, and immediate logic.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY multi_cycle_controller IS
    PORT (
        clock       : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        op_code     : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7_bit5 : IN  STD_LOGIC;
        zero_flag   : IN  STD_LOGIC;
        lt_flag     : IN  STD_LOGIC;
        output_en   : OUT STD_LOGIC;
        adr_src     : OUT STD_LOGIC;
        pc_write    : OUT STD_LOGIC;
        ir_write    : OUT STD_LOGIC;
        mem_write   : OUT STD_LOGIC;
        reg_write   : OUT STD_LOGIC;
        result_src  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        imm_sel     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_src_a   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_src_b   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_ctrl    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END multi_cycle_controller;

ARCHITECTURE behavioral OF multi_cycle_controller IS

    --------------------------------------------------------------------------
    -- State and Instruction Type Definitions
    --------------------------------------------------------------------------
    TYPE instr IS (LW, SW, ADD, ADDI, MUL, BEQ, BGE, HALT, NOP);
    TYPE instruction_type IS (U, J, I, S, B, R, NONE);
    TYPE state_type IS (
        RESET_INIT,
        FETCH,
        DECODE,
        MEM_ADR,
        MEM_READ,
        MEM_WB,
        ALU_EX,
        ALU_WB,
        MEM_W,
        BRANCH,
        HALT_STATE
    );

    SIGNAL current_state, next_state : state_type := RESET_INIT;
    SIGNAL instr_type : instruction_type := NONE;
    SIGNAL instruction : instr := NOP;

    --------------------------------------------------------------------------
    -- Opcode definitions
    --------------------------------------------------------------------------
    CONSTANT OPCODE_LW    : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
    CONSTANT OPCODE_SW    : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100011";
    CONSTANT OPCODE_OP    : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110011";
    CONSTANT OPCODE_OP_IMM: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010011";
    CONSTANT OPCODE_BRANCH: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100011";
    CONSTANT OPCODE_HALT  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";

    TYPE imm_codes IS ARRAY (instruction_type) OF STD_LOGIC_VECTOR(2 DOWNTO 0);
    CONSTANT imm_code : imm_codes := (
        U    => "000",
        J    => "001",
        I    => "010",
        S    => "011",
        B    => "100",
        R    => "111",
        NONE => "111"
    );

    --------------------------------------------------------------------------
    -- Control signals
    --------------------------------------------------------------------------
    SIGNAL adr_src_s    : STD_LOGIC;
    SIGNAL pc_write_s   : STD_LOGIC;
    SIGNAL ir_write_s   : STD_LOGIC;
    SIGNAL mem_write_s  : STD_LOGIC;
    SIGNAL reg_write_s  : STD_LOGIC;
    SIGNAL result_src_s : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL imm_sel_s    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_src_a_s  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_src_b_s  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_ctrl_s   : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL aux : STD_LOGIC_VECTOR(10 DOWNTO 0); -- added for visibility

BEGIN

    --------------------------------------------------------------------------
    -- Control signal assignments to output ports
    --------------------------------------------------------------------------
    adr_src    <= adr_src_s;
    pc_write   <= pc_write_s;
    ir_write   <= ir_write_s;
    mem_write  <= mem_write_s;
    reg_write  <= reg_write_s;
    result_src <= result_src_s;
    imm_sel    <= imm_sel_s;
    alu_src_a  <= alu_src_a_s;
    alu_src_b  <= alu_src_b_s;
    alu_ctrl   <= alu_ctrl_s;
    output_en  <= '1';

    --------------------------------------------------------------------------
    -- Instruction decoding and immediate selection
    --------------------------------------------------------------------------
    decode_logic : PROCESS(op_code, funct3, funct7_bit5)
    BEGIN
        instruction <= NOP;
        instr_type  <= NONE;

        CASE op_code IS
            WHEN OPCODE_LW =>
                instruction <= LW;
                instr_type  <= I;
            WHEN OPCODE_SW =>
                instruction <= SW;
                instr_type  <= S;
            WHEN OPCODE_OP_IMM =>
                IF funct3 = "000" THEN
                    instruction <= ADDI;
                    instr_type  <= I;
                END IF;
            WHEN OPCODE_OP =>
                IF funct3 = "000" AND funct7_bit5 = '0' THEN
                    instruction <= ADD;
                    instr_type  <= R;
                ELSIF funct3 = "000" AND funct7_bit5 = '1' THEN
                    instruction <= MUL;
                    instr_type  <= R;
                END IF;
            WHEN OPCODE_BRANCH =>
                IF funct3 = "000" THEN
                    instruction <= BEQ;
                    instr_type  <= B;
                ELSIF funct3 = "101" THEN
                    instruction <= BGE;
                    instr_type  <= B;
                END IF;
            WHEN OPCODE_HALT =>
                instruction <= HALT;
                instr_type  <= NONE;
            WHEN OTHERS =>
                instruction <= NOP;
                instr_type  <= NONE;
        END CASE;
    END PROCESS decode_logic;

    imm_sel_s <= imm_code(instr_type);

    aux <= funct7_bit5 & funct3 & op_code;

    --------------------------------------------------------------------------
    -- Sequential process: state register update
    --------------------------------------------------------------------------
    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= RESET_INIT;
        ELSIF rising_edge(clock) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------------
    -- Combinational process: next state and control signal logic
    --------------------------------------------------------------------------
    PROCESS (current_state, instruction, zero_flag, lt_flag)
    BEGIN
        -- Default control signal values
        pc_write_s   <= '0';
        ir_write_s   <= '0';
        mem_write_s  <= '0';
        reg_write_s  <= '0';
        adr_src_s    <= '0';
        alu_src_a_s  <= "01";
        alu_src_b_s  <= "10";
        result_src_s <= "01";
        alu_ctrl_s   <= "100";
        next_state   <= current_state;

        CASE current_state IS
            WHEN RESET_INIT =>
                -- Hold state machine in a known state; first fetch happens in FETCH
                -- so the very first instruction is not skipped.
                next_state   <= FETCH;

            WHEN FETCH =>
                next_state   <= DECODE;
                ir_write_s   <= '1';
                pc_write_s   <= '1';
                adr_src_s    <= '0';
                alu_src_a_s  <= "01";
                alu_src_b_s  <= "10";
                result_src_s <= "01";
                alu_ctrl_s   <= "100";

            WHEN DECODE =>
                alu_src_a_s  <= "00"; -- pc_old
                alu_src_b_s  <= "01"; -- imm
                alu_ctrl_s   <= "100";
                result_src_s <= "01";

                CASE instruction IS
                    WHEN LW | SW =>
                        next_state  <= MEM_ADR;
                    WHEN ADD | ADDI | MUL =>
                        next_state  <= ALU_EX;
                    WHEN BEQ | BGE =>
                        next_state  <= BRANCH;
                    WHEN HALT =>
                        next_state  <= HALT_STATE;
                    WHEN OTHERS =>
                        next_state  <= FETCH;
                END CASE;

            WHEN MEM_ADR =>
                adr_src_s    <= '1';
                alu_src_a_s  <= "10"; -- rs1
                alu_src_b_s  <= "01"; -- imm
                alu_ctrl_s   <= "100";
                result_src_s <= "01";

                CASE instruction IS
                    WHEN LW =>
                        next_state <= MEM_READ;
                    WHEN SW =>
                        next_state <= MEM_W;
                    WHEN OTHERS =>
                        next_state <= FETCH;
                END CASE;

            WHEN MEM_READ =>
                adr_src_s    <= '1';
                result_src_s <= "00"; -- hold address via alu_reg
                next_state   <= MEM_WB;

            WHEN MEM_WB =>
                reg_write_s  <= '1';
                result_src_s <= "10";
                next_state   <= FETCH;

            WHEN MEM_W =>
                adr_src_s    <= '1';
                mem_write_s  <= '1';
                result_src_s <= "00";
                next_state   <= FETCH;

            WHEN ALU_EX =>
                result_src_s <= "01";
                CASE instruction IS
                    WHEN ADD =>
                        alu_src_a_s <= "10";
                        alu_src_b_s <= "00";
                        alu_ctrl_s  <= "100";
                    WHEN ADDI =>
                        alu_src_a_s <= "10";
                        alu_src_b_s <= "01";
                        alu_ctrl_s  <= "100";
                    WHEN MUL =>
                        alu_src_a_s <= "10";
                        alu_src_b_s <= "00";
                        alu_ctrl_s  <= "110";
                    WHEN OTHERS =>
                        NULL;
                END CASE;
                next_state <= ALU_WB;

            WHEN ALU_WB =>
                reg_write_s  <= '1';
                result_src_s <= "00";
                next_state   <= FETCH;

            WHEN BRANCH =>
                adr_src_s    <= '1';
                result_src_s <= "00"; -- branch target from alu_reg
                alu_src_a_s  <= "10";
                alu_src_b_s  <= "00";
                alu_ctrl_s   <= "101";
                IF instruction = BEQ THEN
                    pc_write_s <= zero_flag;
                ELSIF instruction = BGE THEN
                    pc_write_s <= NOT lt_flag;
                END IF;
                next_state <= FETCH;

            WHEN HALT_STATE =>
                next_state <= HALT_STATE;

            WHEN OTHERS =>
                next_state <= FETCH;
        END CASE;
    END PROCESS;

END behavioral;
