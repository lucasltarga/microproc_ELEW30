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
        0  => "0101011000000000101",  -- ADDI R3,R0,5
        1  => "0101100000000001000",  -- ADDI R4,R0,8
        2  => "0001101011100000000",  -- ADD R5,R3,R4
        3  => "0110101101000000001",  -- SUBI R5,R5,1
        4  => "1111000000000010100",  -- JMP 20
        5  => "0101101000000000000",  -- ADDI R5,R0,0
        6 to 19 => (others => '0'),
        20  => "0001011101000000000", -- ADD R3,R5,R0
        21  => "1111000000000000010", -- JMP 2
        22  => "0101011000000000000", -- ADDI R3,R0,0
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