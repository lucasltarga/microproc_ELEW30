library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc_tb is
end;

architecture a_uc_tb of uc_tb is
    component uc is port (
            clk, rst     : in std_logic;
            instruction  : in unsigned(18 downto 0);
            pc_wr_en     : out std_logic;
            rom_rd_en    : out std_logic;
            jump_en      : out std_logic;
            jump_address : out unsigned(6 downto 0)
        );
    end component;

    constant period_time       : time := 100 ns;
    signal finished            : std_logic := '0';
    signal clk, rst            : std_logic;
    signal pc_wr_en, rom_rd_en : std_logic := '1';
    signal jump_en             : std_logic;
    signal instruction         : unsigned(18 downto 0) := (others => '0');
    signal jump_address        : unsigned(6 downto 0) := "0000000";

begin

    uut : uc port map(
        clk => clk,
        rst => rst,
        instruction => instruction,
        pc_wr_en => pc_wr_en,
        rom_rd_en => rom_rd_en,
        jump_en => jump_en,
        jump_address => jump_address
    );

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2;
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
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

end architecture;