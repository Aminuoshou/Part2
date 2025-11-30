------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : program_counter.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description : 32-bit register. 
--               On each rising clock edge, if 'write_en' is asserted, 
--               the output is updated with the value of 'write_data'.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY pc IS
    PORT (
        clock    : IN STD_LOGIC;
        write_en : IN STD_LOGIC;
        pc_next  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavioral OF pc IS
    SIGNAL pc_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
    pc_out <= pc_reg;

    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) and write_en = '1' THEN
            pc_reg <= pc_next;
        END IF;
    END PROCESS;

END behavioral;
