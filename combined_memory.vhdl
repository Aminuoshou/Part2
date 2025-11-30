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
        
        -- 0x00300093   addi x1, x0, 3
        0  => x"93", 1  => x"00", 2  => x"30", 3  => x"00",
        
        -- 0x00400113   addi x2, x0, 4
        4  => x"13", 5  => x"01", 6  => x"40", 7  => x"00",
        
        -- [MODIFIED] 0x422081B3   mul x3, x1, x2 (Bit 30 set to '1' for custom logic)
        -- Original was 0x022081B3. Changed 0x02 to 0x42.
        8  => x"B3", 9  => x"81", 10 => x"20", 11 => x"42",
        
        -- [MODIFIED] 0x0011D463   bge x3, x1, 8
        -- Replaces incorrect BEQ instruction. 
        12 => x"63", 13 => x"D4", 14 => x"11", 15 => x"00",
        
        -- 0x00100213   addi x4, x0, 1 (should be skipped when branch taken)
        16 => x"13", 17 => x"02", 18 => x"10", 19 => x"00",
        
        -- 0x0000007F   halt
        20 => x"7F", 21 => x"00", 22 => x"00", 23 => x"00",
        
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