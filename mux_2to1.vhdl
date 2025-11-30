------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : mux_2to1.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 32-bit 2-to-1 multiplexer.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux_2to1 IS
    PORT(
        in0   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        in1   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sel   : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF mux_2to1 IS
BEGIN
    out_y <= in0 WHEN sel = '0' ELSE in1;
END behavioral;