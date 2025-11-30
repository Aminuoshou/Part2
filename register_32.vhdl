------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : register_32.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description : 32-bit register. 
--               On each rising clock edge, if 'write_en' is asserted, 
--               the output is updated with the value of 'write_data'.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY register_32 IS
    PORT (
        clock      : IN STD_LOGIC;
        write_en   : IN STD_LOGIC;
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE behavioral OF register_32 IS

BEGIN

    PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) AND write_en = '1' THEN
            data <= write_data;
        END IF;
    END PROCESS;

END behavioral;
