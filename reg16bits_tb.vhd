library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16bits_tb is
end;

architecture a_reg16bits_tb of reg16bits_tb is
    component reg16bits is port(
            clk, rst, wr_en : in std_logic;  -- clock, reset e write_enable
            data_in         : in unsigned(15 downto 0);
            data_out        : out unsigned(15 downto 0)
        );
    end component;

    constant period_time     : time      := 100 ns;  -- 100 ns é o período escolhido para o clock
    signal   finished        : std_logic := '0';
    signal data_in, data_out : unsigned(15 downto 0) := x"0000";
    signal clk, rst, wr_en   : std_logic := '0';

begin
    uut: reg16bits port map(
        data_in => data_in,
        data_out => data_out,
        clk => clk,
        rst => rst,
        wr_en => wr_en
    );

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2; -- reset dura 2 clocks para garantir a propagação
        rst <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 10 us; -- tempo total da simulação
        finished <= '1';
        wait;
    end process sim_time_proc;

    clk_proc: process -- gera clock até que sim_time_proc termine
    begin                       
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

    process -- sinais dos casos de teste
    begin
        wait until rst = '0';
        -- wr_en = 0
        -- Teste 1
        data_in <= x"00FF";
        wait until rising_edge(clk);
        assert data_out = x"0000" report "Erro no teste 1" severity error;
        
        -- Teste 2
        wr_en <= '1';
        data_in <= "0000000010001101";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert data_out = "0000000010001101" report "Erro no teste 2" severity error;

        -- Teste 3
        data_in <= "0000000000011011";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert data_out = "0000000000011011" report "Erro no teste 3" severity error;

        -- Teste 4
        data_in <= x"00FF";
        wr_en <= '0';
        wait until rising_edge(clk);
        assert data_out /= x"00FF" report "Erro no teste 4" severity error;
        wait;
    end process;
end architecture a_reg16bits_tb;