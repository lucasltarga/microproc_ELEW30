library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- wr_en dos flipflops só quando for instrução de ULA (nas flags)
-- para o lab 6 as flags devem ser implementadas em flipflops

entity uc is
    port (
        clk, rst     : in std_logic;
        instruction  : in unsigned(18 downto 0);
        pc_wr_en, rom_rd_en, jump_en, reg_instr_wr_en : out std_logic; -- sinais de controle
        jump_address : out unsigned(6 downto 0); -- endereço absoluto de salto
        ula_op_sel   : out unsigned(1 downto 0);
        operando_sel : out std_logic;
        reg_wr       : out unsigned(2 downto 0);
        reg_wr_en    : out std_logic;
        reg_src1     : out unsigned(2 downto 0);
        reg_src2     : out unsigned(2 downto 0);
        imm_value    : out unsigned(15 downto 0);
        flag_zero, flag_neg : in std_logic
    );
end entity;

architecture a_uc of uc is
    -- 0 = fetch, 1 = decode/execute
    signal estado     : std_logic := '0'; -- por enquanto std_logic é suficiente por usarmos apenas 2 estados. se não, usar unsigned.
    signal rom_rd_en_s, pc_wr_en_s, reg_instr_wr_en_s : std_logic;
    signal opcode     : unsigned(3 downto 0);
    signal reg_dest_s : unsigned(2 downto 0) := "000";
    signal reg_src1_s : unsigned(2 downto 0) := "000";
    signal reg_src2_s : unsigned(2 downto 0) := "000";
    signal immediate_s  : unsigned(15 downto 0) := x"0000";
    signal jump_addr  : unsigned(6 downto 0) := "0000000";
    signal flag_zero_ula, flag_neg_ula : std_logic;

begin
    -- Extração de campos da instrução
    --- Tipo R
    ---  0000   000   000   000   0000000
    --- opcode  dest  src1  src2  endereço 

    -- Tipo I
    --  0000   000   000   000000000
    -- opcode  dest  src1  imm (estender para 16 bits)

    -- Saltos
    --  0000  xxxxxxxx 0000000
    -- opcode          endereço    

    opcode <= instruction(18 downto 15);

    -- Ativo para instruções tipo R e tipo I
    reg_dest_s <= instruction(14 downto 12) when (opcode = "0001" or opcode = "0010" or opcode = "0011" or opcode = "0100" or 
                                                  opcode = "0101" or opcode = "0110" or opcode = "0111") else "000";
    -- Mesmo de reg_dest_s
    reg_src1_s  <= instruction(11 downto 9) when (opcode = "0001" or opcode = "0010" or opcode = "0011" or opcode = "0100" or 
                                                  opcode = "0101" or opcode = "0110" or opcode = "0111") else "000";
    -- Ativo para instruções tipo R
    reg_src2_s  <= instruction(8 downto 6) when (opcode = "0001" or opcode = "0010" or opcode = "0011" or opcode = "0100") else "000";

    -- Ativo para instruções tipo I
    immediate_s <= "0000000" & instruction(8 downto 0) when (opcode = "0101" or opcode = "0110" or opcode = "0111") else x"0000";

    -- Ativo apenas para saltos
    jump_addr   <= instruction(6 downto 0) when opcode = "1111" else "0000000";

    -- Máquina de dois estados
    process(clk,rst) -- acionado se houver mudança em clk ou rst
        begin
            if rst='1' then
                estado <= '0';
            elsif rising_edge(clk) then
                estado <= not estado; -- alterna entre fetch e decode/execute
            end if;
    end process;
    
    -- FETCH
    -- Leitura da ROM

    -- REFAZER: deixar sempre em 1
    rom_rd_en_s <= '1' when estado = '0' else '0';
    -- Escrita no registrador de instrução (somente em fetch)
    reg_instr_wr_en_s <= '1' when (estado = '0') else '0'; 

    -- DECODE/EXECUTE
    -- Escrita do PC
    pc_wr_en_s <= '1' when estado = '1' else '0';
    -- Habilita escrita para ops ULA (exceto para CMPI)
    reg_wr_en <= '1' when (estado = '1' and (
        opcode = "0001" or -- ADD
        opcode = "0010" or -- SUB
        opcode = "0011" or -- OR
        opcode = "0100" or -- AND
        opcode = "0101" or -- ADDI
        opcode = "0110"    -- SUBI
    )) else '0';

    -- Controle de saltos 
    jump_en <=  '1' when (estado = '1' and opcode = "1111") else   -- Salto incondicional (opcode 1111)
                '1' when (estado = '1' and opcode="1000" and flag_zero='0') else   -- Salto condicional BNE (opcode 1000)
                '1' when (estado = '1' and opcode="1001" and flag_neg='0') else '0'; -- Salto condicional BPL (1001)
    
    -- Controle do caminho de dados
    ula_op_sel <= "00" when opcode = "0001" else -- ADD
                  "01" when opcode = "0010" else -- SUB
                  "10" when opcode = "0011" else -- OR
                  "11" when opcode = "0100" else -- AND
                  "00" when opcode = "0101" else -- ADDI
                  "01" when opcode = "0110" else -- SUBI
                  "01" when opcode = "0111" else -- CMPI
                  "00";                          -- Padrão
    
    -- Seleção do segundo operando (0 para imediato e 1 para registrador)
    operando_sel <= '0' when opcode = "0101" else  -- ADDI
                    '0' when opcode = "0110" else  -- SUBI
                    '0' when opcode = "0111" else  -- CMPI
                    '1';
    rom_rd_en <= rom_rd_en_s;
    pc_wr_en <= pc_wr_en_s;
    reg_instr_wr_en <= reg_instr_wr_en_s;
    reg_wr <= reg_dest_s;
    reg_src1 <= reg_src1_s;
    reg_src2 <= reg_src2_s;
    imm_value <= immediate_s;
    jump_address <= jump_addr;
end architecture;