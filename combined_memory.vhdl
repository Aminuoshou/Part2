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
        -- Program: Factorial of 5 with memory verify (little-endian)

        -- 0x04000213   addi x4, x0, 64   ; data base at byte address 0x40
        0  => x"13", 1  => x"02", 2  => x"00", 3  => x"04",

        -- 0x00500093   addi x1, x0, 5    ; n = 5
        4  => x"93", 5  => x"00", 6  => x"50", 7  => x"00",

        -- 0x00100113   addi x2, x0, 1    ; acc = 1
        8  => x"13", 9  => x"01", 10 => x"10", 11 => x"00",

        -- 0x00100193   addi x3, x0, 1    ; const_one = 1
        12 => x"93", 13 => x"01", 14 => x"10", 15 => x"00",

        -- 0x0011D863   bge x3, x1, 16    ; if 1 >= n, jump to done
        16 => x"63", 17 => x"D8", 18 => x"11", 19 => x"00",

        -- 0x02110133   mul x2, x2, x1    ; acc *= n
        20 => x"33", 21 => x"01", 22 => x"11", 23 => x"02",

        -- 0xFFF08093   addi x1, x1, -1   ; n -= 1
        24 => x"93", 25 => x"80", 26 => x"F0", 27 => x"FF",

        -- 0xFE000AE3   beq x0, x0, -12   ; loop back to bge
        28 => x"E3", 29 => x"0A", 30 => x"00", 31 => x"FE",

        -- 0x00222023   sw x2, 0(x4)      ; done: store acc to memory
        32 => x"23", 33 => x"20", 34 => x"22", 35 => x"00",

        -- 0x00022283   lw x5, 0(x4)      ; reload stored result
        36 => x"83", 37 => x"22", 38 => x"02", 39 => x"00",

        -- 0x000282B3   add x6, x5, x0    ; move result via ADD
        40 => x"B3", 41 => x"82", 42 => x"02", 43 => x"00",

        -- 0x00430263   beq x6, x2, 4     ; verify load, skip fail path
        44 => x"63", 45 => x"02", 46 => x"43", 47 => x"00",

        -- 0x00000393   addi x7, x0, 0    ; fail marker (should be skipped)
        48 => x"93", 49 => x"03", 50 => x"00", 51 => x"00",

        -- 0x0000007F   halt
        52 => x"7F", 53 => x"00", 54 => x"00", 55 => x"00",

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