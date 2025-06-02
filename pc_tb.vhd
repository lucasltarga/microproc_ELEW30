library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tb is
end;

architecture a_pc_tb of pc_tb is
    component pc is port (
            clk, rst, wr_en : in std_logic;
            data_in:    in unsigned(6 downto 0);
            data_out:   out unsigned(6 downto 0)
        );
    end component;

    constant period_time     : time := 100 ns;
    signal finished          : std_logic := '0';
    signal clk, rst, wr_en   : std_logic;
    signal data_in, data_out : unsigned(6 downto 0);

begin
    pc_uut : pc port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en,
        data_in => data_in,
        data_out => data_out
    );

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2;
        rst <= '0';
        wait;
    end process;

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
        wait until rst = '0';
        wr_en <= '1';
        data_in <= "0000000";
        wait until rising_edge(clk);

        data_in <= "0000010";
        wait until rising_edge(clk);

        data_in <= "0001010";
        wait until rising_edge(clk);
        
        wr_en <= '0';
        data_in <= "1100010";
        wait until rising_edge(clk);

        data_in <= "1101010";
        wait until rising_edge(clk);

        data_in <= "1100110";
        wait until rising_edge(clk);

        wr_en <= '1';
        data_in <= "0100010";
        wait until rising_edge(clk);

        wait;
    end process;
end architecture;