library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port (
        clk:     in std_logic;
        address: in unsigned(6 downto 0); -- ROM com 128 endereços
        rd_en:   in std_logic; -- read_enable
        data:    out unsigned(18 downto 0)
    );
end entity;

architecture a_rom of rom is
    type mem is array (0 to 127) of unsigned(18 downto 0);
    constant content_rom: mem := ( -- 19 bits / especificação para largura da ROM
    -- Preenchimento inicial (1-32)
    0  => "0101001000000000001", -- ADDI R1, R0, 1     (R1=1)
    1  => "0101010000000000001", -- ADDI R2, R0, 1     (R2=1)
    2  => "0101011000000100000", -- ADDI R3, R0, 32    (R3=32)
    3  => "1011010001000000000", -- SW R2, 0(R1)       ; [1]=1
    4  => "0101010001000000001", -- ADDI R2, R2, 1     ; R2=2
    5  => "0101001001000000001", -- ADDI R1, R1, 1     ; R1=2
    6  => "0010000010011000000", -- SUB R0, R2, R3     ; Atualiza flags
    7  => "1000000000001111011", -- BNE -5 (salta para 3)

    -- Eliminar o número 1
    8  => "0101001000000000001", -- ADDI R1, R0, 1
    9  => "1011000001000000000", -- SW R0, 0(R1)

    -- Eliminar múltiplos de 2
    10 => "0101101000000000010", -- ADDI R5, R0, 2
    11 => "0101110000000000100", -- ADDI R6, R0, 4
    12 => "0101010000000001111", -- ADDI R2, R0, 15
    13 => "1011000110000000000", -- SW R0, 0(R6)
    14 => "0001110110101000000", -- ADD R6, R6, R5
    15 => "0110010010000000001", -- SUBI R2, R2, 1
    16 => "1000000000001111100", -- BNE -4 (offset -4)

    -- Eliminar múltiplos de 3
    17 => "0101101000000000011", -- ADDI R5, R0, 3
    18 => "0101110000000000110", -- ADDI R6, R0, 6
    19 => "0101010000000001001", -- ADDI R2, R0, 9
    20 => "1011000110000000000", -- SW R0, 0(R6)
    21 => "0001110110101000000", -- ADD R6, R6, R5
    22 => "0110010010000000001", -- SUBI R2, R2, 1
    23 => "1000000000001111100", -- BNE -4 (offset -4)

    -- Eliminar múltiplos de 5
    24 => "0101101000000000101", -- ADDI R5, R0, 5
    25 => "0101110000000001010", -- ADDI R6, R0, 10
    26 => "0101010000000000101", -- ADDI R2, R0, 5
    27 => "1011000110000000000", -- SW R0, 0(R6)
    28 => "0001110110101000000", -- ADD R6, R6, R5
    29 => "0110010010000000001", -- SUBI R2, R2, 1
    30 => "1000000000001111100", -- BNE -4 (offset -4)

    -- Leitura dos resultados (2-32)
    31 => "0101001000000000010", -- ADDI R1, R0, 2
    32 => "0101010000000011111", -- ADDI R2, R0, 31
    33 => "1010111001000000000", -- LW R7, 0(R1)
    34 => "0101001001000000001", -- ADDI R1, R1, 1
    35 => "0110010010000000001", -- SUBI R2, R2, 1
    36 => "1000000000001111100", -- BNE -4 (offset -4)

    -- VALIDAÇÃO CTZ = 5
    37 => "1100111011000000000", -- CTZ R7,R3
    others => (others => '0')
    );

begin
    process(clk)
    begin
        if rising_edge(clk) and rd_en = '1' then 
            data <= content_rom(to_integer(address));  --ROM Síncrona!! Necessita de clock/ rampa de subida
        end if;
    end process;
end architecture;