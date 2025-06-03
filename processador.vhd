library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port(
        clk, rst : in std_logic
    );
end entity;

architecture a_processador of processador is
    component uc is
        port(
            clk, rst    : in std_logic;
            instruction : in unsigned(18 downto 0);
            pc_wr_en    : out std_logic;
            rom_rd_en   : out std_logic;
            jump_en     : out std_logic;
            jump_address : out unsigned(6 downto 0)
        );
    end component;
    
    component rom is
        port(
            clk     : in std_logic;
            address : in unsigned(6 downto 0);
            rd_en   : in std_logic;
            data    : out unsigned(18 downto 0)
        );
    end component;
    
    component pc is
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
        );
    end component;
    
    signal pc_to_rom : unsigned(6 downto 0);
    signal rom_to_uc : unsigned(18 downto 0);
    signal uc_pc_wr_en, uc_rom_rd_en, uc_jump_en : std_logic;
    signal pc_next : unsigned(6 downto 0);
    signal uc_jump_address : unsigned(6 downto 0);
    
begin
    uc_inst: uc port map(
        clk          => clk,
        rst          => rst,
        instruction  => rom_to_uc,
        pc_wr_en     => uc_pc_wr_en,
        rom_rd_en    => uc_rom_rd_en,
        jump_en      => uc_jump_en,
        jump_address => uc_jump_address
    );
    
    rom_inst: rom port map(
        clk     => clk,
        address => pc_to_rom,
        rd_en   => uc_rom_rd_en,
        data    => rom_to_uc
    );
    
    pc_inst: pc port map(
        clk      => clk,
        rst      => rst,
        wr_en    => uc_pc_wr_en,
        data_in  => pc_next,
        data_out => pc_to_rom
    );
    
    -- se uc_jump_en = 1, PC recebe o endereço de jump. Se não, incrementa 1 a cada clock
    pc_next <= uc_jump_address when uc_jump_en = '1' else pc_to_rom + 1;
end architecture;