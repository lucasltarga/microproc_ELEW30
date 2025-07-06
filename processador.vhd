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
            jump_address : out unsigned(6 downto 0);
            reg_wr_en   : out std_logic;
            reg_instr_wr_en : out std_logic;
            ula_op_sel  : out unsigned(1 downto 0);
            operando_sel : out std_logic;
            reg_wr    : out unsigned(2 downto 0);
            reg_src1    : out unsigned(2 downto 0);
            reg_src2    : out unsigned(2 downto 0);
            imm_value   : out unsigned(15 downto 0);
            flag_zero, flag_neg : in std_logic;
            ula_wr_en : out std_logic;
            ram_wr_en : out std_logic;
            mem_to_reg : out std_logic
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

    component reg_instr is port(
        clk, rst, wr_en : in std_logic;
        data_in    : in unsigned(18 downto 0);
        data_out   : out unsigned(18 downto 0)
    ); end component;

    component banco_reg is port(
        clk, rst, wr_en : in std_logic;
        data_wr         : in unsigned(15 downto 0);
        reg_wr          : in unsigned(2 downto 0);
        reg_read1       : in unsigned(2 downto 0);
        data_out1       : out unsigned(15 downto 0);
        reg_read2       : in unsigned(2 downto 0);
        data_out2       : out unsigned(15 downto 0)
    ); end component;
    
    component ula is port(
        clk, rst     : in std_logic;
        entr0, entr1 : in unsigned(15 downto 0);
        sel          : in unsigned(1 downto 0);
        wr_en        : in std_logic;
        saida        : out unsigned(15 downto 0);
        flag_zero    : out std_logic;
        flag_neg     : out std_logic
    ); end component;

    component ram is port(
            clk      : in std_logic;
            address : in unsigned(6 downto 0);
            wr_en    : in std_logic;
            dado_in  : in unsigned(15 downto 0);
            dado_out : out unsigned(15 downto 0)
    );
    end component;
    
    -- sinais de conexão
    signal pc_to_rom : unsigned(6 downto 0) := "0000000";
    signal rom_to_reg_instr : unsigned(18 downto 0) := "0000000000000000000";
    signal reg_instr_to_uc : unsigned(18 downto 0) := "0000000000000000000";

    -- sinais de controle da UC
    signal uc_pc_wr_en, uc_rom_rd_en, uc_jump_en, uc_reg_instr_wr_en : std_logic;
    signal uc_jump_address : unsigned(6 downto 0) := "0000000";
    signal uc_reg_wr_en, uc_operando_sel : std_logic;
    signal uc_ula_op_sel : unsigned(1 downto 0) := "00";
    signal uc_reg_dest, uc_reg_src1, uc_reg_src2 : unsigned(2 downto 0) := "000";
    signal uc_imm_value : unsigned(15 downto 0) := x"0000";

    -- sinais do caminho de dados
    signal pc_next : unsigned(6 downto 0);
    signal reg_data1, reg_data2, ula_out : unsigned(15 downto 0);
    signal ula_operando2 : unsigned(15 downto 0);
    signal ula_flag_zero, ula_flag_neg : std_logic;
    signal uc_ula_wr_en : std_logic;

    -- sinais para cálculo de salto relativo
    signal offset_relativo : signed(7 downto 0);
    signal pc_mais_offset  : unsigned(7 downto 0);
    signal is_branch       : std_logic := '0';

    -- sinais RAM
    signal ram_address : unsigned(6 downto 0);
    signal ram_data_in, ram_data_out : unsigned(15 downto 0);
    signal ram_wr_en, mem_to_reg : std_logic;
    signal reg_write_data : unsigned(15 downto 0); -- dado para escrita no banco de regs
    signal uc_ram_wr_en : std_logic;
    
begin
    uc_inst: uc port map(
        clk          => clk,
        rst          => rst,
        instruction  => reg_instr_to_uc,
        pc_wr_en     => uc_pc_wr_en,
        rom_rd_en    => uc_rom_rd_en,
        reg_instr_wr_en => uc_reg_instr_wr_en,
        jump_en => uc_jump_en,
        jump_address => uc_jump_address,
        reg_wr => uc_reg_dest,
        reg_wr_en => uc_reg_wr_en,
        ula_op_sel => uc_ula_op_sel,
        operando_sel => uc_operando_sel,
        reg_src1 => uc_reg_src1,
        reg_src2 => uc_reg_src2,
        imm_value => uc_imm_value,
        flag_zero => ula_flag_zero,
        flag_neg => ula_flag_neg,
        ula_wr_en => uc_ula_wr_en,
        ram_wr_en => uc_ram_wr_en,
        mem_to_reg => mem_to_reg
    );
    
    rom_inst: rom port map(
        clk     => clk,
        address => pc_to_rom,
        rd_en   => uc_rom_rd_en,
        data    => rom_to_reg_instr
    );
    
    pc_inst: pc port map(
        clk      => clk,
        rst      => rst,
        wr_en    => uc_pc_wr_en,
        data_in  => pc_next,
        data_out => pc_to_rom
    );

    banco_reg_inst: banco_reg port map(
        clk => clk,
        rst => rst,
        wr_en => uc_reg_wr_en,
        reg_wr => uc_reg_dest,
        reg_read1 => uc_reg_src1,
        data_out1 => reg_data1,
        reg_read2 => uc_reg_src2,
        data_out2 => reg_data2,
        data_wr => reg_write_data -- alimentado pelo MUX (ULA ou RAM)
    );

    ula_inst: ula port map(
        clk => clk,
        rst => rst,
        entr0 => reg_data1,
        entr1 => ula_operando2, -- operando 2 ou offset de endereço de RAM
        sel => uc_ula_op_sel,
        wr_en => uc_ula_wr_en, -- controle de atualização de flags
        saida => ula_out,
        flag_zero => ula_flag_zero,
        flag_neg => ula_flag_neg
    );

    reg_instr_inst: reg_instr port map(
        clk => clk,
        rst => rst,
        wr_en => uc_reg_instr_wr_en,
        data_in => rom_to_reg_instr,
        data_out => reg_instr_to_uc
    );

    ram_inst: ram port map(
        clk => clk,
        address => ram_address,
        wr_en => ram_wr_en,
        dado_in => ram_data_in,
        dado_out => ram_data_out
    );
    
    -- Identifica se é salto condicional
    is_branch <= '1' when uc_jump_en = '1' and -- é salto
        (reg_instr_to_uc(18 downto 15) = "1000" or -- BNE
        reg_instr_to_uc(18 downto 15) = "1001")    -- BPL
        else '0';

    -- Converte offset para signed (complemento de 2)
    offset_relativo <= resize(signed(uc_jump_address), 8); -- 8 bits: -128 a +127

    -- Calcula PC + offset (relativo ao próximo PC)
    pc_mais_offset <= unsigned(signed('0' & pc_to_rom) + 1 + offset_relativo);
    
    -- MUX para seleção do segundo operando
    ula_operando2 <= reg_data2 when uc_operando_sel = '1' else uc_imm_value;

    -- Seleção do próximo PC
    pc_next <= pc_mais_offset(6 downto 0) when is_branch = '1' else -- Salto relativo
    uc_jump_address when uc_jump_en = '1'  -- Salto absoluto
    else pc_to_rom + 1; -- Próxima instrução

    -- Conexões da RAM
    ram_address <= ula_out(6 downto 0); -- usa 7 LSB do endereço calculado pela ULA
    ram_data_in <= reg_data2; -- dado para escrita vem do banco de regs
    ram_wr_en <= uc_ram_wr_en;

    -- MUX para dado de escrita no banco de regs
    reg_write_data <= ram_data_out when mem_to_reg = '1' else ula_out;
end architecture;