library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc is
    port (
        clk, rst    : in std_logic;
        instruction : in unsigned(18 downto 0);
        pc_wr_en, rom_rd_en, jump_en : out std_logic; -- sinais de controle
        jump_address : out unsigned(6 downto 0) -- endereço absoluto de salto
    );
end entity;

architecture a_uc of uc is
    -- 0 = fetch, 1 = decode/execute
    signal estado                  : std_logic := '0'; -- por enquanto std_logic é suficiente por usarmos apenas 2 estados. se não, usar unsigned.
    signal opcode                  : unsigned(3 downto 0) := "0000";
    signal rom_rd_en_s, pc_wr_en_s : std_logic;

begin
    -- Extração de campos da instrução
    opcode <= instruction(18 downto 15); -- 4 MSB
    jump_address <= instruction(6 downto 0);

    -- Máquina de dois estados
    process(clk,rst) -- acionado se houver mudança em clk ou rst
        begin
            if rst='1' then
                estado <= '0';
            elsif rising_edge(clk) then
                estado <= not estado; -- alterna entre fetch e decode/execute
            end if;
    end process;

    -- Leitura da ROM apenas no estado 0 (fetch)
    rom_rd_en_s <= '1' when estado = '0' else '0';

    -- Escrita do PC apenas no estado 1 (decode/execute)
    pc_wr_en_s <= '1' when estado = '1' else '0';

    -- Controle de saltos (opcode 1111)
    jump_en <= '1' when (estado = '1' and opcode = "1111") else '0';

    rom_rd_en <= rom_rd_en_s;
    pc_wr_en <= pc_wr_en_s;
end architecture;