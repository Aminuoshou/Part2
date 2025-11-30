------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : extend_unit.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Sign extension unit for RISC-V immediate values
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY extend_unit IS
    PORT(
        instr   : IN  STD_LOGIC_VECTOR(31 DOWNTO 7); -- instruction bits
        imm_sel : IN  STD_LOGIC_VECTOR(2  DOWNTO 0); -- immediate format selector
        imm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- extended output
    );

END ENTITY;

ARCHITECTURE behavioral OF extend_unit IS
    CONSTANT U  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";  -- U type instruction
    CONSTANT J  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";  -- J type instruction
    CONSTANT I  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";  -- I type instruction
    CONSTANT S  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";  -- S type instruction
    CONSTANT B  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";  -- B type instruction
BEGIN
    WITH imm_sel SELECT
        imm_ext <=
           instr(31 DOWNTO 12) & (11 DOWNTO 0 => '0')                                                          WHEN U,
           (31 DOWNTO 20 => instr(31)) & instr(19 DOWNTO 12) & instr(20) & instr(30 DOWNTO 21) & '0'           WHEN J,
           (31 DOWNTO 12 => instr(31)) & instr(31 DOWNTO 20)                                                   WHEN I,
           (31 DOWNTO 12 => instr(31)) & instr(31 DOWNTO 25) & instr(11 DOWNTO 7)                              WHEN S,
           (31 DOWNTO 13 => instr(31)) & instr(31) & instr(7) & instr(30 DOWNTO 25) & instr(11 DOWNTO 8) & '0' WHEN B,
           (OTHERS => '0')                                                                                     WHEN OTHERS;
END behavioral;