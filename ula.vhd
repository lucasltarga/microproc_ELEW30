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
        sel: in unsigned(2 downto 0);
        wr_en: in std_logic; -- habilita atualização das flags
        flag_zero: out std_logic; -- Resultado = 0
        flag_neg: out std_logic; -- Negativo (MSB = 1)
        saida: out unsigned(15 downto 0)
    );
end entity;


architecture a_ula of ula is
    signal resultado: unsigned(15 downto 0);
    signal reg_zero, reg_neg: std_logic := '0';
    signal resultado_ctz: unsigned (15 downto 0);

begin
    -- Operações:
    -- 000 -> Soma
    -- 001 -> Subtração (sem borrow)
    -- 010 -> OU
    -- 011 -> E
    -- 100 -> CTZ

    process(entr0)
        variable count: integer range 0 to 16;
        variable found_one: boolean;
    begin
        count := 0;
        found_one := false;
        for i in 0 to 15 loop
            if entr0(i) = '1' then
                found_one := true;
            elsif not found_one then
                count := count + 1;
            end if;
        end loop;
        
        resultado_ctz <= to_unsigned(count, 16);
    end process;

    resultado <= resultado_ctz when sel = "100"
    else    entr0+entr1 when sel="000"
    else    entr0-entr1 when sel="001"
    else    entr0 or entr1 when sel="010"
    else    entr0 and entr1 when sel="011"
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
