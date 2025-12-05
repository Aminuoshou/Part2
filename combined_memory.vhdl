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
        -- Program (little-endian)

        -- 0x04000213   addi x4, x0, 64  ; data base at byte address 0x40
        0  => x"13", 1  => x"02", 2  => x"00", 3  => x"04",

        -- 0x00500093   addi x1, x0, 5   ; operand A
        4  => x"93", 5  => x"00", 6  => x"50", 7  => x"00",

        -- 0x00A00113   addi x2, x0, 10  ; operand B
        8  => x"13", 9  => x"01", 10 => x"A0", 11 => x"00",

        -- 0x002081B3   add x3, x1, x2   ; sum = 15
        12 => x"B3", 13 => x"81", 14 => x"20", 15 => x"00",

        -- 0x00322023   sw x3, 0(x4)      ; store sum to data area
        16 => x"23", 17 => x"20", 18 => x"32", 19 => x"00",

        -- 0x00022303   lw x6, 0(x4)      ; load stored sum
        20 => x"03", 21 => x"23", 22 => x"02", 23 => x"00",

        -- 0x021303B3   mul x7, x6, x1    ; product = 15 * 5 = 75
        24 => x"B3", 25 => x"03", 26 => x"13", 27 => x"02",

        -- 0x0023D463   bge x7, x2, 8     ; branch taken, skip next addi
        28 => x"63", 29 => x"D4", 30 => x"23", 31 => x"00",

        -- 0x00100493   addi x9, x0, 1    ; only executes if branch not taken
        32 => x"93", 33 => x"04", 34 => x"10", 35 => x"00",

        -- 0x00330263   beq x6, x3, 4     ; verify load == sum, jump to halt
        36 => x"63", 37 => x"02", 38 => x"33", 39 => x"00",

        -- 0x0000007F   halt
        40 => x"7F", 41 => x"00", 42 => x"00", 43 => x"00",

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