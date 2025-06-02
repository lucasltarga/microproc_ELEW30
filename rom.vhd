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
        0  => "1111000000000000011", -- salto para o endereço 3
        1  => "0001000100000000000",  
        2  => "0001001000000000101",
        3  => "1111000000000000111", -- salto para o endereço 7
        4  => "0000000000000000000",
        5  => "0000000000000000000",
        6  => "0000000000000000000",
        7  => "0010000100100000000",
        8  => "1111000000000000111", -- salto para o endereço 7 (loop infinito)
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