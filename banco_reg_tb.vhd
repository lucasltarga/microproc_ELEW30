library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity banco_reg_tb is
end entity banco_reg_tb;

architecture a_banco_reg_tb of banco_reg_tb is
    component banco_reg
    port(
            clk, rst, wr_en: in std_logic;
            data_wr  : in unsigned(15 downto 0);
            reg_wr   : in unsigned(2 downto 0);
            reg_read1: in unsigned(2 downto 0);
            reg_read2: in unsigned(2 downto 0);
            data_out1: out unsigned(15 downto 0);
            data_out2: out unsigned(15 downto 0)
    );
    end component;

    signal clk, rst, wr_en, finished    : std_logic := '0';
    signal data_wr                      : unsigned(15 downto 0) := x"0000";
    signal reg_wr, reg_read1, reg_read2 : unsigned(2 downto 0) := "000";

    signal data_out1, data_out2 : unsigned(15 downto 0) := x"0000";

    constant period_time : time := 100 ns;
begin
    uut: banco_reg port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en,
        data_wr => data_wr,
        reg_wr => reg_wr,
        reg_read1 => reg_read1,
        reg_read2 => reg_read2,
        data_out1 => data_out1,
        data_out2 => data_out2 
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
    
    main_test: process
    begin
        wait until rst = '0';
        -- Teste 1: escrita
        wr_en <= '1';
        
        -- Escrever em r1
        reg_wr <= "001";
        data_wr <= x"1234";
        wait until rising_edge(clk);
        reg_read1 <= "001";
        wait for 1 ns;
        assert data_out1 = x"1234" report "Erro escrevendo em R1" severity error;

        -- Escrever em R2
        reg_wr <= "010";
        data_wr <= x"5678";
        wait until rising_edge(clk);
        reg_read1 <= "010";
        wait for 1 ns;
        assert data_out1 = x"5678" report "Erro escrevendo em R2" severity error;

        -- Escrever em R3
        reg_wr <= "011";
        data_wr <= x"9ABC";
        wait until rising_edge(clk);
        reg_read1 <= "011";
        wait for 1 ns;
        assert data_out1 = x"9ABC" report "Erro escrevendo em R3" severity error;

        -- Escrever em R4
        reg_wr <= "100";
        data_wr <= x"DEF0";
        wait until rising_edge(clk);
        reg_read1 <= "100";
        wait for 1 ns;
        assert data_out1 = x"DEF0" report "Erro escrevendo em R4" severity error;
        
        -- Escrever em R5
        reg_wr <= "101";
        data_wr <= x"1357";
        wait until rising_edge(clk);
        reg_read1 <= "101";
        wait for 1 ns;
        assert data_out1 = x"1357" report "Erro escrevendo em R5" severity error;
        
        -- Escrever em R6
        reg_wr <= "110";
        data_wr <= x"2468";
        wait until rising_edge(clk);
        reg_read1 <= "110";
        wait for 1 ns;
        assert data_out1 = x"2468" report "Erro escrevendo em R6" severity error;
        
        -- Escrever em R7
        reg_wr <= "111";
        data_wr <= x"FACE";
        wait until rising_edge(clk);
        reg_read1 <= "111";
        wait for 1 ns;
        assert data_out1 = x"FACE" report "Erro escrevendo em R7" severity error;
        
        -- Teste 2: tentativa de escrita com wr_en = 0
        wr_en <= '0';
        reg_wr <= "001";
        data_wr <= x"4321";
        wait until rising_edge(clk);
        reg_read1 <= "001";
        wait for 1 ns;
        assert data_out1 = x"1234" report "Erro na escrita wr_en = 0" severity error;
        
        wait;
    end process;
end architecture;