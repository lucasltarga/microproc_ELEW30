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
    constant content_rom: mem := (
        0  => "0000000000000001111",
        1  => "0000000000010000000",  -- 19 bits / especificação para largura da ROM
        2  => "0000000000000000011",
        3  => "1111110000000100100",  -- bits aleatórios
        4  => "0100100000100000000",
        5  => "0000000000000000000",
        6  => "1111110000000000100",
        7  => "1111110000000000011",
        8  => "0000000000000000000",
        9  => "0001110010100100000",
        10 => "1111110000000000000",
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