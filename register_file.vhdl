------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : register_file.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : RISC-V register file with 32 registers (x0-x31), two read ports,
--                and one synchronous write port. x0 remains constant at zero.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY register_file IS
    PORT (
        clock    : IN STD_LOGIC;
        rs1_addr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        rs2_addr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_addr  : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rs1_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rs2_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_we    : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF register_file IS

    TYPE register_array IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_file : register_array := (OTHERS => (OTHERS => '0'));

BEGIN

    PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) THEN
            IF rd_we = '1' AND rd_addr /= "00000" THEN
                reg_file(to_integer(unsigned(rd_addr))) <= rd_data;
            END IF;
        END IF;
    END PROCESS;

    rs1_data <= reg_file(to_integer(unsigned(rs1_addr)));
    rs2_data <= reg_file(to_integer(unsigned(rs2_addr)));

END behavioral;
