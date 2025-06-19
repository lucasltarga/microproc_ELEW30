library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port (
        clk:     in std_logic;
        address: in unsigned(6 downto 0); -- ROM com 128 endereços
        rd_en:   in std_logic; -- read_enable
        data:    out unsigned(18 downto 0)
    );
end entity;

architecture a_rom of rom is
    type mem is array (0 to 127) of unsigned(18 downto 0);
    constant content_rom: mem := ( -- 19 bits / especificação para largura da ROM
        -- Escrita inicial
        0  => "0101001000000001010",  -- ADDI R1,R0,10
        1  => "0101010000000010100",  -- ADDI R2,R0,20
        2  => "0101011000000011110",  -- ADDI R3,R0,30
        3  => "0101100000000101000",  -- ADDI R4,R0,40
        4  => "0101101000000110010",  -- ADDI R5,R0,50
        5  => "0101110000000010010",  -- ADDI R6,R0,0x12 (18)
        6  => "0101111000000110100",  -- ADDI R7,R0,0x34 (52)
        7  => "1011110001000000000",  -- SW R6,0(R1)
        8  => "1011111010000000000",  -- SW R7,0(R2)
        9  => "0101110000010101100",  -- ADDI R6,R0,0x56 (86)
        10 => "0101111000011110000",  -- ADDI R7,R0,0x78 (120)
        11 => "1011110011000000000",  -- SW R6,0(R3)
        12 => "1011111100000000000",  -- SW R7,0(R4)
        13 => "0101110000100110100",  -- ADDI R6,R0,0x9A (154)
        14 => "1011110101000000000",  -- SW R6,0(R5)
        
        -- Leituras
        15 => "0101001000000010100",  -- ADDI R1,R0,20
        16 => "1010110001000000000",  -- LW R6,0(R1)
        17 => "0101010000001010000",  -- ADDI R2,R0,40
        18 => "1010111010000000000",  -- LW R7,0(R2)
        19 => "0101011000000001010",  -- ADDI R3,R0,10
        20 => "1010001001100000000",  -- LW R1,0(R3)
        21 => "0101100000001100100",  -- ADDI R4,R0,50
        22 => "1010010100000000000",  -- LW R2,0(R4)
        23 => "0101101000000011110",  -- ADDI R5,R0,30
        24 => "1010011101000000000",  -- LW R3,0(R5)
        others => (others => '0')
    );

begin
    process(clk)
    begin
        if rising_edge(clk) and rd_en = '1' then 
            data <= content_rom(to_integer(address));  --ROM Síncrona!! Necessita de clock/ rampa de subida
        end if;
    end process;
end architecture;