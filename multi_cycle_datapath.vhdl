------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : multi_cycle_datapath.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Structural implementation of a multi-cycle RISC-V datapath.
--                Includes PC, instruction fetch, decode, ALU, memory, and write-back.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY multi_cycle_datapath IS
    PORT (
        clock       : IN STD_LOGIC;
        adr_src     : IN STD_LOGIC;
        pc_write    : IN STD_LOGIC;
        ir_write    : IN STD_LOGIC;
        mem_write   : IN STD_LOGIC;
        reg_write   : IN STD_LOGIC;
        output_en   : IN STD_LOGIC;
        result_src  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        imm_sel     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_src_a   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_src_b   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_ctrl    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        op_code     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7_bit5 : OUT STD_LOGIC;
        zero_flag   : OUT STD_LOGIC;
        lt_flag     : OUT STD_LOGIC;
        dp_out      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF multi_cycle_datapath IS
    SIGNAL pc, pc_old, pc_next             : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext            : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, read_data   : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_reg, rs2_reg, alu_reg       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_result, src_a, src_b        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL address, result_mux_o           : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_mux_o, write_data, data_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
    --------------------------------------------------------------------
    -- Instruction Field Extraction
    --------------------------------------------------------------------
    funct7_bit5 <= instruction(30);
    funct3      <= instruction(14 DOWNTO 12);
    op_code     <= instruction(6 DOWNTO 0);

    --------------------------------------------------------------------
    -- FETCH STAGE
    -- Program Counter, Address Mux, and Instruction Memory
    --------------------------------------------------------------------
    dp_pc : ENTITY work.pc(Behavioral)
        PORT MAP(
            clock    => clock,
            write_en => pc_write,
            pc_out   => pc,
            pc_next  => result_mux_o
        );

    dp_adr_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => pc,
            in1   => result_mux_o,
            out_y => address,
            sel   => adr_src
        );

    dp_memory : ENTITY work.combined_mem(rtl)
        PORT MAP(
            clock      => clock,
            write_en   => mem_write,
            address    => address,
            write_data => rs2_reg,
            data       => read_data
        );

    dp_pc_reg : ENTITY work.register_32(Behavioral)
        PORT MAP(
            clock      => clock,
            write_en   => ir_write,
            write_data => pc,
            data       => pc_old
        );

    dp_ir : ENTITY work.register_32(Behavioral)
        PORT MAP(
            clock      => clock,
            write_en   => ir_write,
            write_data => read_data,
            data       => instruction
        );

    --------------------------------------------------------------------
    -- DECODE STAGE
    -- Register File and Immediate Extension
    --------------------------------------------------------------------

    dp_regfile : ENTITY work.register_file(behavioral)
        PORT MAP(
            clock    => clock,
            rs1_addr => instruction(19 DOWNTO 15),
            rs2_addr => instruction(24 DOWNTO 20),
            rd_addr  => instruction(11 DOWNTO 7),
            rd_data  => result_mux_o,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rd_we    => reg_write
        );

    dp_imm_ext : ENTITY work.extend_unit(behavioral)
        PORT MAP(
            instr   => instruction(31 DOWNTO 7),
            imm_sel => imm_sel,
            imm_ext => imm_ext
        );

    --------------------------------------------------------------------
    -- EXECUTE STAGE
    -- Operand Registers, ALU Source Muxes, and ALU
    --------------------------------------------------------------------

    dp_acc_a : ENTITY work.register_32(Behavioral)
        PORT MAP(
            clock      => clock,
            write_en   => '1',
            write_data => rs1_data,
            data       => rs1_reg
        );

    dp_acc_b : ENTITY work.register_32(Behavioral)
        PORT MAP(
            clock      => clock,
            write_en   => '1',
            write_data => rs2_data,
            data       => rs2_reg
        );

    dp_a_src : ENTITY work.mux_3to1(behavioral)
        PORT MAP(
            in0   => pc_old,
            in1   => pc,
            in2   => rs1_reg,
            out_y => src_a,
            sel   => alu_src_a
        );

    dp_b_src : ENTITY work.mux_3to1(behavioral)
        PORT MAP(
            in0   => rs2_reg,
            in1   => imm_ext,
            in2   => x"00000004",
            out_y => src_b,
            sel   => alu_src_b
        );

    dp_alu : ENTITY work.alu(behavioral)
        PORT MAP(
            src_a     => src_a,
            src_b     => src_b,
            alu_ctrl  => alu_ctrl,
            result    => alu_result,
            zero_flag => zero_flag,
            lt_flag   => lt_flag
        );

    dp_alu_reg : ENTITY work.register_32(Behavioral)
        PORT MAP(
            clock      => clock,
            write_en   => '1',
            write_data => alu_result,
            data       => alu_reg
        );
    
    --------------------------------------------------------------------
    -- MEMORY STAGE
    -- Data Register (for memory read values)
    --------------------------------------------------------------------

     dp_data_reg : ENTITY work.register_32(Behavioral)
        PORT MAP(
            clock      => clock,
            write_en   => '1',
            write_data => read_data,
            data       => data_reg
        );

    --------------------------------------------------------------------
    -- WRITE-BACK STAGE
    -- Result Mux and Output Buffer
    --------------------------------------------------------------------

    dp_result_src : ENTITY work.mux_3to1(behavioral)
        PORT MAP(
            in0   => alu_reg,
            in1   => alu_result,
            in2   => data_reg,
            out_y => result_mux_o,
            sel   => result_src
        );

    dp_output_buffer: ENTITY work.tri_state_buffer(behavioral)
        PORT MAP (
            output_en     => output_en,
            buffer_input  => result_mux_o,
            buffer_output => dp_out
        );

END structural;
