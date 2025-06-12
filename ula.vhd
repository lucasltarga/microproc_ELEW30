library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Especificações:
-- [x] ULA Ortogonal (segue modelo RISC-V, 2 operandos);
-- [x] Duas entradas de dados de 16 bits;
-- [x] Uma saída de dados de 16 bits;
-- [x] Duas ou mais saídas de sinalização de 1 bit (flags);
-- [x] Entrada para a seleção das operações
-- [x] Mínimo 4 operações: soma, subtração e mais duas escolhidas pela equipe.
-- [x] Não implementar divisão!
-- [x] Deve somar e subtrair com constantes também

entity ula is
    port(
        clk, rst : in std_logic;
        entr0: in unsigned(15 downto 0);
        entr1: in unsigned(15 downto 0);
        sel: in unsigned(1 downto 0);
        wr_en: in std_logic; -- habilita atualização das flags
        flag_zero: out std_logic; -- Resultado = 0
        flag_neg: out std_logic; -- Negativo (MSB = 1)
        saida: out unsigned(15 downto 0)
    );
end entity;


architecture a_ula of ula is
    signal resultado: unsigned(15 downto 0);
    signal reg_zero, reg_neg: std_logic := '0';

begin
    -- Operações:
    -- 00 -> Soma
    -- 01 -> Subtração (sem borrow)
    -- 10 -> OU
    -- 11 -> E

    resultado <= entr0+entr1 when sel="00"
    else    entr0-entr1 when sel="01"
    else    entr0 or entr1 when sel="10"
    else    entr0 and entr1 when sel="11" 
    else    "0000000000000000";

    saida <= resultado;

    process(clk, rst)
    begin
        if rst = '1' then
            reg_zero <= '0';
            reg_neg <= '0';
        elsif rising_edge(clk) then
            if wr_en = '1' then
                if resultado = x"0000" then
                    reg_zero <= '1';
                else
                    reg_zero <= '0';
                end if;
                
                reg_neg <= resultado(15);
            end if;
        end if;
    end process;

    flag_zero <= reg_zero;
    flag_neg <= reg_neg;
end architecture;
