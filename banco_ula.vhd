library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_ula is
    port (
        clk, rst, wr_en : in std_logic;
        reg_wr:           in unsigned(2 downto 0);  -- qual registrador será escrito
        reg_read1, reg_read2: in unsigned(2 downto 0); -- escolhe qual registrador ler
        ula_operation_sel: in unsigned(1 downto 0);
        operando_cte:   in unsigned(15 downto 0);
        operando_selector: in std_logic; -- define se o operando é uma constante ou um registrador
        out_ula:        out unsigned(15 downto 0); 
        flag_zero_out, flag_neg_out : out std_logic
    );
end entity;

architecture a_banco_ula of banco_ula is
    component banco_reg is
        port (
            clk:         in std_logic;
            rst:         in std_logic;
            wr_en:       in std_logic;
            data_wr:     in unsigned(15 downto 0);
            reg_wr:      in unsigned(2 downto 0);
            reg_read1:    in unsigned(2 downto 0);
            data_out1:    out unsigned(15 downto 0);
            reg_read2:    in unsigned(2 downto 0);
            data_out2:    out unsigned(15 downto 0)
        );
    end component;

    component ula is
        port (
            entr0, entr1: in unsigned(15 downto 0);
            sel: in unsigned(1 downto 0);
            flag_zero: out std_logic; -- Resultado = 0
            flag_neg: out std_logic; -- Negativo (MSB = 1)
            saida: out unsigned(15 downto 0)
        );
    end component;

    signal data_out_reg1,data_out_reg2 : unsigned(15 downto 0);
    signal operando_banco1, operando_banco2: unsigned(15 downto 0);
    signal ula_saida : unsigned(15 downto 0);
    signal flag_zero, flag_neg : std_logic := '0';

begin
    banco_reg_i: banco_reg port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en,
        data_wr => ula_saida, --recebe a saída da ULA
        reg_wr => reg_wr,
        reg_read1 => reg_read1,
        reg_read2 => reg_read2,
        data_out1 => data_out_reg1,
        data_out2 => data_out_reg2
    );

    ula_i: ula port map(
        entr0 => operando_banco1, -- primeira entrada --> recebe do registrador
        entr1 => operando_banco2, -- segunda entrada --> pode ser uma constante ou a saida do registrador
        sel => ula_operation_sel,
        flag_zero => flag_zero,
        flag_neg => flag_neg,
        saida => ula_saida
    );
    
    -- Operando 1 = registrador
    operando_banco1 <= data_out_reg1;

    -- Operando 2 = registrador ou constante imediata
    operando_banco2 <= operando_cte when operando_selector = '0' else -- se o operando_selector for 0, o operando vai ser a constante
    data_out_reg2 when operando_selector = '1' else -- se o operando_selector for 1, o operando vai ser a saida do registrador
                x"0000";
    
    -- Saídas das flags
    flag_zero_out <= flag_zero;
    flag_neg_out <= flag_neg;
    
    -- Saída da ULA
    out_ula <= ula_saida;
end architecture;