library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maquina_estados is
    port (
        clk, rst : in std_logic;
        estado   : out std_logic
    );
end entity;

architecture a_maquina_estados of maquina_estados is

    signal estado_atual: std_logic := '0';

begin
        process(clk,rst) -- acionado se houver mudança em clk ou rst
        begin
            if rst='1' then
                estado_atual <= '0';
            elsif rising_edge(clk) then
                estado_atual <= not estado_atual;
            end if;
        end process;
        
    estado <= estado_atual;

end architecture;
