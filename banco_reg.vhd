library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Especificações:
-- Não há acumulador (o banco sempre lê 2 registradores)
-- Possuir write_enable para habilitar a escrita apenas no momento correto

entity banco_reg is
    port(
        clk, rst, wr_en: in std_logic;  -- clock, reset e write_enable
        data_wr: in unsigned(15 downto 0);  -- dado a ser escrito no registrador (16 bits)
        reg_wr: in unsigned(2 downto 0);  -- qual registrador será escrito (3 bits para 8 registradores)
        reg_read1: in unsigned(2 downto 0);  -- qual registrador será lido  (3 bits para 8 registradores)
        reg_read2: in unsigned(2 downto 0);  -- qual registrador será lido (3 bits para 8 registradores)
        data_out1: out unsigned(15 downto 0); -- dado na saida do registrador
        data_out2: out unsigned(15 downto 0) -- dado na saida do registrador
    );
end entity banco_reg;

architecture a_banco_reg of banco_reg is

    component reg16bits is
        port (
            clk, rst, wr_en : in std_logic;
            data_in         : in unsigned(15 downto 0);
            data_out        : out unsigned(15 downto 0)
        );
    end component;
    
    signal wr_en_regs : std_logic_vector(7 downto 0);
    signal r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out: unsigned(15 downto 0);

begin
    wr_en_regs(0) <= '1' when reg_wr = "000" and wr_en = '1' else '0';
    wr_en_regs(1) <= '1' when reg_wr = "001" and wr_en = '1' else '0';
    wr_en_regs(2) <= '1' when reg_wr = "010" and wr_en = '1' else '0';
    wr_en_regs(3) <= '1' when reg_wr = "011" and wr_en = '1' else '0';
    wr_en_regs(4) <= '1' when reg_wr = "100" and wr_en = '1' else '0';
    wr_en_regs(5) <= '1' when reg_wr = "101" and wr_en = '1' else '0';
    wr_en_regs(6) <= '1' when reg_wr = "110" and wr_en = '1' else '0';
    wr_en_regs(7) <= '1' when reg_wr = "111" and wr_en = '1' else '0';
    
    reg0: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(0),
        data_in => data_wr,  -- recebe o dado a ser escrito no registrador
        data_out => r0_out -- saida do registrador
    );

    reg1: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(1),
        data_in => data_wr,
        data_out => r1_out
    );

    reg2: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(2),
        data_in => data_wr,
        data_out => r2_out
    );

    reg3: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(3),
        data_in => data_wr,
        data_out => r3_out
    );

    reg4: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(4),
        data_in => data_wr,
        data_out => r4_out
    );

    reg5: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(5),
        data_in => data_wr,
        data_out => r5_out
    );

    reg6: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(6),
        data_in => data_wr,
        data_out => r6_out
    );

    reg7: reg16bits port map(
        clk => clk,
        rst => rst,
        wr_en => wr_en_regs(7),
        data_in => data_wr,
        data_out => r7_out
    );  

    data_out1 <= r0_out when reg_read1 = "000" else
    r1_out when reg_read1 = "001" else
    r2_out when reg_read1 = "010" else
    r3_out when reg_read1 = "011" else
    r4_out when reg_read1 = "100" else
    r5_out when reg_read1 = "101" else
    r6_out when reg_read1 = "110" else
    r7_out when reg_read1 = "111" else x"0000";
    
    data_out2 <= r0_out when reg_read2 = "000" else
    r1_out when reg_read2 = "001" else
    r2_out when reg_read2 = "010" else
    r3_out when reg_read2 = "011" else
    r4_out when reg_read2 = "100" else
    r5_out when reg_read2 = "101" else
    r6_out when reg_read2 = "110" else
    r7_out when reg_read2 = "111" else x"0000";

end architecture;