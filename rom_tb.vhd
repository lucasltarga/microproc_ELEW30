
--Marcia Eliana Ferreira
--Lucas Targa

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_tb is
end;

architecture a_rom_tb of rom_tb is
    component rom is port (
            clk:        in std_logic;
            address:    in unsigned(6 downto 0);
            rd_en:      in std_logic;
            data:       out unsigned(18 downto 0)
        );
    end component;

    constant period_time     : time := 100 ns;
    signal finished          : std_logic := '0';
    signal clk, rd_en        : std_logic;
    signal data              : unsigned(18 downto 0);
    signal address           : unsigned(6 downto 0);

begin
    uut : rom port map(
        clk => clk,
        address => address,
        rd_en => rd_en,
        data => data
    );

    sim_time_proc: process
    begin
        wait for 10 us;         -- <== TEMPO TOTAL DA SIMULACAO!!!
        finished <= '1';
        wait;
    end process sim_time_proc;

    clk_proc: process
    begin                       
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

    process
    begin
        rd_en <= '1';
        address <= "0000000";
        wait until rising_edge(clk);
        wait for 1 ns; -- tempo para propagação do sinal
        assert data = "0000000000000001111" report "Erro no end. 0";
        
        address <= "0000010";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert data = "0000000000000000011" report "Erro no end. 2";
        
        address <= "0001010";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert data = "1111110000000000000" report "Erro no end. 10";

        wait;
    end process;
end architecture;