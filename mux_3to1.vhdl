------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : mux_3to1.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 32-bit 3-to-1 multiplexer.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux_3to1 IS
    PORT (
        in0   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        in1   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        in2   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sel   : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavioral OF mux_3to1 IS
BEGIN
    WITH sel SELECT
        out_y <=
        in0 WHEN "00",
        in1 WHEN "01",
        in2 WHEN "10",
        (OTHERS => '0') WHEN OTHERS;
END behavioral;
