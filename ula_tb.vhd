library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Especificações:
-- Cobrir todas as operações (incluindo números negativos na entrada).

entity ula_tb is
end;

architecture a_ula_tb of ula_tb is
    component ula
    port(
        entr0: in unsigned(15 downto 0);
        entr1: in unsigned(15 downto 0);
        sel: in unsigned(1 downto 0);
        flag_zero: out std_logic;
        flag_neg: out std_logic;
        saida: out unsigned(15 downto 0)
    );
end component;

signal entr0, entr1, saida : unsigned(15 downto 0);
signal sel : unsigned(1 downto 0);
signal flag_zero, flag_neg : std_logic;

begin
    uut: ula port map(
        entr0 => entr0,
        entr1 => entr1,
        sel   => sel,
        flag_zero => flag_zero,
        flag_neg => flag_neg,
        saida => saida
    );

    process
    begin

        -- Teste da operação de adição (sel="00")
        -- 5 + 10
        sel <="00";
        entr0 <= x"0005";
        entr1 <= x"000A";
        wait for 50 ns;
        assert saida = x"000F" report "Erro ADD: 5 + 10" severity error;
        assert flag_zero = '0' report "Erro flag_zero em ADD 5 + 10" severity error;
        assert flag_neg = '0' report "Erro flag_neg em ADD 5 + 10" severity error;

        -- Teste da operação de adição (sel="00")
        -- -5 + 10
        sel <="00";
        entr0 <= "1111111111111011"; -- -5 em complemento de 2
        entr1 <= x"000A";
        wait for 50 ns;
        assert saida = x"0005" report "Erro ADD: -5 + 10" severity error;
        assert flag_zero = '0' report "Erro flag_zero em ADD -5 + 10" severity error;
        assert flag_neg = '0' report "Erro flag_neg em ADD -5 + 10" severity error;

        -- Teste da operação de subtração (sel="01")
        -- 20 - 7
        sel <="01";
        entr0 <= x"0014";
        entr1 <= x"0007";
        wait for 50 ns;
        assert saida = x"000D" report "Erro SUB: 20 - 7" severity error;
        assert flag_zero = '0' report "Erro flag_zero em SUB 20 - 7" severity error;
        assert flag_neg = '0' report "Erro flag_neg em SUB 20 - 7" severity error;

        -- Teste da operação de subtração (sel="01")
        -- -5 - 7
        sel <="01";
        entr0 <= "1111111111111011";
        entr1 <= x"0007";
        wait for 50 ns;
        assert saida = "1111111111110100" report "Erro SUB: -5 - 7" severity error;
        assert flag_zero = '0' report "Erro flag_zero em SUB -5 - 7" severity error;
        assert flag_neg = '1' report "Erro flag_neg em SUB -5 - 7" severity error;

        -- Teste da operação de subtração (sel="01")
        -- Resultado negativo: 5 - 10
        sel <="01";
        entr0 <= x"0005";
        entr1 <= x"000A";
        wait for 50 ns;
        assert saida = "1111111111111011" report "Erro SUB: 5 - 10" severity error;
        assert flag_zero = '0' report "Erro flag_zero em SUB 5 - 10" severity error;
        assert flag_neg = '1' report "Erro flag_neg em SUB 5 - 10" severity error;

        -- Teste da operação OR entre entr0 e entr1 (sel="10")
        -- 0x00FF | 0xFF00
        sel <="10";
        entr0 <= x"00FF";
        entr1 <= x"FF00";
        wait for 50 ns;
        assert saida = x"FFFF" report "Erro OR: 00FF | FF00" severity error;
        assert flag_zero = '0' report "Erro flag_zero em OR 00FF | FF00" severity error;
        assert flag_neg = '1' report "Erro flag_neg em OR 00FF | FF00" severity error;
        
        -- Teste da operação AND entre entr0 e entr1 (sel="11")
        -- Resultado zero
        sel <="11";
        entr0 <=x"FFFF";
        entr1 <=x"0000";
        wait for 50 ns;
        assert saida = x"0000" report "Erro AND: FFFF & 0000" severity error;
        assert flag_zero = '1' report "Erro flag_zero em AND FFFF&0000" severity error;
        assert flag_neg = '0' report "Erro flag_neg em AND FFFF&0000" severity error;
        wait;
    end process;
end architecture;


