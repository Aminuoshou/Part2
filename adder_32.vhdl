------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : adder_32.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description : 32-bit adder (basic version, no carry or overflow)
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY adder_32 IS
    PORT (
        op_a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        op_b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sum  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavioral OF adder_32 IS
BEGIN

    sum <= STD_LOGIC_VECTOR(UNSIGNED(op_a) + UNSIGNED(op_b));

END behavioral;
