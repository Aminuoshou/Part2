------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : multi_cycle_riscv.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Top-level RISC-V CPU combining multi-cycle datapath and control logic.
--                Executes basic load, store, and arithmetic instructions.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY multi_cycle_riscv IS
    PORT (
        clock  : IN STD_LOGIC;
        reset  : IN STD_LOGIC;
        result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF multi_cycle_riscv IS
    SIGNAL zero_flag   : STD_LOGIC := '0';
    SIGNAL lt_flag     : STD_LOGIC := '0';
    SIGNAL adr_src     : STD_LOGIC;
    SIGNAL pc_write    : STD_LOGIC;
    SIGNAL ir_write    : STD_LOGIC;
    SIGNAL mem_write   : STD_LOGIC;
    SIGNAL reg_write   : STD_LOGIC;
    SIGNAL funct7_bit5 : STD_LOGIC;
    SIGNAL output_en   : STD_LOGIC;
    SIGNAL result_src  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_src_a   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_src_b   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL funct3      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL imm_sel     : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_ctrl    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL op_code     : STD_LOGIC_VECTOR(6 DOWNTO 0);

BEGIN

    datapath : ENTITY work.multi_cycle_datapath(structural)
        PORT MAP(
            clock       => clock,
            adr_src     => adr_src,
            pc_write    => pc_write,
            ir_write    => ir_write,
            mem_write   => mem_write,
            reg_write   => reg_write,
            output_en   => output_en,
            result_src  => result_src,
            imm_sel     => imm_sel,
            alu_src_a   => alu_src_a,
            alu_src_b   => alu_src_b,
            alu_ctrl    => alu_ctrl,
            op_code     => op_code,
            funct3      => funct3,
            funct7_bit5 => funct7_bit5,
            zero_flag   => zero_flag,
            lt_flag     => lt_flag,
            dp_out      => result

        );

    control_unit : ENTITY work.multi_cycle_controller(behavioral)
        PORT MAP(
            clock       => clock,
            reset       => reset,
            op_code     => op_code,
            funct3      => funct3,
            funct7_bit5 => funct7_bit5,
            zero_flag   => zero_flag,
            lt_flag     => lt_flag,
            output_en   => output_en,
            adr_src     => adr_src,
            pc_write    => pc_write,
            ir_write    => ir_write,
            mem_write   => mem_write,
            reg_write   => reg_write,
            result_src  => result_src,
            imm_sel     => imm_sel,
            alu_src_a   => alu_src_a,
            alu_src_b   => alu_src_b,
            alu_ctrl    => alu_ctrl
        );
END structural;
