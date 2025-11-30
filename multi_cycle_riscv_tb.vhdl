------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : multi_cycle_riscv_tb.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Testbench for the multi cycle RISC-V CPU core
--                Program is preloaded in the combined memory module
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY multi_cycle_riscv_tb IS
END ENTITY;

ARCHITECTURE tb OF multi_cycle_riscv_tb IS

    SIGNAL clock  : STD_LOGIC                     := '0';
    SIGNAL reset  : STD_LOGIC                     := '0';
    SIGNAL result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    DUT : ENTITY work.multi_cycle_riscv(structural)
        PORT MAP(
            clock  => clock,
            reset  => reset,
            result => result
        );

    PROCESS IS BEGIN
        reset <= '1';
        WAIT FOR 1 ns;
        reset <= '0';
        WAIT FOR 1 ns;
        FOR i IN 0 TO 60 LOOP
            clock <= '1';
            WAIT FOR 2 ns;
            clock <= '0';
            WAIT FOR 2 ns;
        END LOOP;
        WAIT;
    END PROCESS;

END ARCHITECTURE;
