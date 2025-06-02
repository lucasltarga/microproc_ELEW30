library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity banco_ula_tb is
end entity;

architecture a_banco_ula_tb of banco_ula_tb is
    component banco_ula is
        port (
            clk, rst, wr_en : in std_logic;
            reg_wr:         in unsigned(2 downto 0);
            reg_read1, reg_read2 : in unsigned(2 downto 0);
            ula_operation_sel: in unsigned(1 downto 0);
            operando_cte:   in unsigned(15 downto 0);
            operando_selector: in std_logic;
            out_ula:        out unsigned(15 downto 0);
            flag_zero_out, flag_neg_out : out std_logic
        );
    end component;

    signal clk, rst, wr_en: std_logic := '0';
    signal reg_wr, reg_read1, reg_read2: unsigned(2 downto 0) := "000";
    signal ula_operation_sel: unsigned(1 downto 0) := "00";
    signal operando_cte: unsigned(15 downto 0) := x"0000";
    signal operando_selector: std_logic := '0';
    signal out_ula: unsigned(15 downto 0);
    signal finished    : std_logic := '0';
    signal flag_zero, flag_neg: std_logic := '0';
    
    constant CLK_PERIOD: time := 100 ns;

begin
    uut: banco_ula port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en,
        reg_wr => reg_wr,
        reg_read1 => reg_read1,
        reg_read2 => reg_read2,
        ula_operation_sel => ula_operation_sel,
        operando_cte => operando_cte,
        operando_selector => operando_selector,
        out_ula => out_ula,
        flag_zero_out => flag_zero,
        flag_neg_out => flag_neg
    );
    
    reset_global: process
    begin
        rst <= '1';
        wait for CLK_PERIOD*2; -- espera 2 clocks, pra garantir
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
    begin                       -- gera clock até que sim_time_proc termine
        while finished /= '1' loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process clk_proc;
    
    process
    begin
        wait until rst = '0';
        
        -- Teste 1: escrita no registrador (reg1 = 0x0005)
        wr_en <= '1';
        reg_wr <= "001"; -- seleciona reg1
        operando_cte <= x"0005"; -- valor cte
        operando_selector <= '0'; -- operando 2 = cte
        ula_operation_sel <= "00"; -- ADD
        --reg_read1 <= "001"; -- lê reg1
        wait until rising_edge(clk); -- espera atualização do sinal
        wait for 1 ns;
        assert out_ula = x"0005" report "Erro no reg1" severity error;

        -- Teste 2: soma (x2 = x1 + x1)
        reg_wr <= "010"; -- seleciona reg2
        operando_selector <= '1'; -- operando 2 = reg
        reg_read1 <= "001";
        reg_read2 <= "001";
        ula_operation_sel <= "00"; -- ADD
        wait until rising_edge(clk);
        wait for 1 ns;
        assert out_ula = x"000A" report "Erro na soma x2 = x1 + x1" severity error;

        -- Teste 3: subtração cte (x3 = x2 - 3)
        reg_wr <= "011"; -- seleciona reg3
        operando_cte <= x"0003";
        operando_selector <= '0';
        reg_read1 <= "010"; -- lê reg2
        ula_operation_sel <= "01";  -- sub
        wait until rising_edge(clk);
        wait for 1 ns;
        assert out_ula = x"0007" report "Erro na subtração x3 = x2 - 3" severity error;
        
        -- Teste 4: operação AND
        reg_wr <= "100";        -- seleciona reg4
        operando_selector <= '1'; -- operando 2 = registrador
        reg_read1 <= "001";      -- lê reg1 (0x0005)
        reg_read2 <= "010";      -- lê reg2 (0x000A)
        ula_operation_sel <= "11"; -- AND
        wait until rising_edge(clk);
        wait for 1 ns;
        assert out_ula = x"0000" report "Erro na operação AND" severity error;

        -- Teste 5: operação OR
        reg_wr <= "101";        -- seleciona reg5
        operando_selector <= '1'; -- operando 2 = registrador
        reg_read1 <= "001";      -- lê reg1 (0x0005)
        reg_read2 <= "010";      -- lê reg2 (0x000A)
        ula_operation_sel <= "10"; -- OR
        wait until rising_edge(clk);
        wait for 1 ns;
        assert out_ula = x"000F" report "Erro na operação OR" severity error;

        -- Teste 6: subtração que resulta em negativo
        reg_wr <= "110";        -- seleciona reg6
        operando_selector <= '1'; -- operando 2 = registrador
        reg_read1 <= "001";      -- lê reg1 (5)
        reg_read2 <= "010";      -- lê reg2 (10)
        ula_operation_sel <= "01"; -- SUB
        wait until rising_edge(clk);
        wait for 1 ns;
        assert out_ula = x"FFFB"  -- -5 em complemento de 2
            report "Erro na subtração negativa." severity error;
        wait;
    end process;
end architecture;
