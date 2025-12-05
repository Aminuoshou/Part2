------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : combined_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB data memory with 32-bit read/write interface.
--                Supports synchronous writes and asynchronous reads.
--                [MODIFIED] Pre-loaded with Factorial(5) Calculation Program
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY combined_mem IS
    PORT (
        clock      : IN STD_LOGIC;
        write_en   : IN STD_LOGIC;
        address    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF combined_mem IS

    -- Byte-addressable RAM
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : memory_data := (
        -- Program: Calculate 5! (Factorial)
        -- Logic: x2 = x2 * x1, then x1 = x1 - 1, repeat until x1 <= 1.
        -- Expected Result: x2 = 120 (0x78) in Hex

        -- 0x00: addi x1, x0, 5      ; n = 5
        0  => x"93", 1  => x"00", 2  => x"50", 3  => x"00",

        -- 0x04: addi x2, x0, 1      ; result (accumulator) = 1
        4  => x"13", 5  => x"01", 6  => x"10", 7  => x"00",

        -- 0x08: addi x3, x0, 1      ; constant 1 for comparison
        8  => x"93", 9  => x"01", 10 => x"10", 11 => x"00",

        -- 0x0C: bge x3, x1, 16      ; Loop Check: if 1 >= n, jump to Halt (PC + 16 -> 0x1C)
        -- Imm: 16 (skip 4 instructions). 
        12 => x"63", 13 => x"D8", 14 => x"11", 15 => x"00",

        -- 0x10: mul x2, x2, x1      ; result = result * n
        -- Custom MUL instruction (bit 30 = '1')
        16 => x"33", 17 => x"01", 18 => x"11", 19 => x"42",

        -- 0x14: addi x1, x1, -1     ; n = n - 1
        -- Imm: -1 (0xFFF)
        20 => x"93", 21 => x"80", 22 => x"F0", 23 => x"FF",

        -- 0x18: beq x0, x0, -12     ; Unconditional Jump back to 0x0C
        -- Imm: -12. Machine Code: 0xFE000AE3
        -- [FIXED] Byte 25 changed from 0x06 (-20) to 0x0A (-12)
        24 => x"E3", 25 => x"0A", 26 => x"00", 27 => x"FE",

        -- 0x1C: halt                ; Infinite loop here
        28 => x"7F", 29 => x"00", 30 => x"00", 31 => x"00",

        OTHERS => (OTHERS => '0')
    );
    SIGNAL addr_int : INTEGER := 0;

BEGIN
    -- Address conversion fits 1 KB
    addr_int <= to_integer(unsigned(address(9 DOWNTO 0)));

    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) AND write_en = '1' THEN
            RAM(addr_int)     <= write_data(7 DOWNTO 0);
            RAM(addr_int + 1) <= write_data(15 DOWNTO 8);
            RAM(addr_int + 2) <= write_data(23 DOWNTO 16);
            RAM(addr_int + 3) <= write_data(31 DOWNTO 24);
        END IF;
    END PROCESS;
    
    -- read 4 consecutive bytes form one 32-bit word
    data <= RAM(addr_int + 3) &
            RAM(addr_int + 2) &
            RAM(addr_int + 1) &
            RAM(addr_int);

END ARCHITECTURE rtl;
