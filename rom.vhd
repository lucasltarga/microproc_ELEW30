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
        0  => "0101011000000000000",  -- ADDI R3,R0,0
        1  => "0101100000000000000",  -- ADDI R4,R0,0
        2  => "0001100011100000000",  -- ADD R4,R3,R4
        3  => "0101011011000000001",  -- ADDI R3,R3,1
        4  => "0111000011000011110",  -- CMPI R3,30
        5  => "1000011000001111100",  -- BNE R3,-4
        6  => "0001101100000000000",  -- ADD R5,R4,R0
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