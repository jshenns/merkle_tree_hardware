library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_triangle_hash_unit is
end entity tb_triangle_hash_unit;

architecture sim of tb_triangle_hash_unit is

    -- Component declaration for the unit under test (UUT)
    component triangle_hash_unit is
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            mode      : in  std_logic;
            data_in_0 : in  std_logic_vector(255 downto 0);
            data_in_1 : in  std_logic_vector(255 downto 0);
            data_in_2 : in  std_logic_vector(255 downto 0);
            data_in_3 : in  std_logic_vector(255 downto 0);
            data_in_valid : std_logic;
            hash_out  : out std_logic_vector(255 downto 0);
            hash_valid: out std_logic;
            ready     : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk_tb        : std_logic := '0';
    signal reset_tb      : std_logic := '0';
    signal mode_tb       : std_logic;
    signal data_in_0_tb  : std_logic_vector(255 downto 0) := (others => '0');
    signal data_in_1_tb  : std_logic_vector(255 downto 0) := (others => '0');
    signal data_in_2_tb  : std_logic_vector(255 downto 0) := (others => '0');
    signal data_in_3_tb  : std_logic_vector(255 downto 0) := (others => '0');
    signal data_in_valid_tb : std_logic := '0';
    signal hash_out_tb   : std_logic_vector(255 downto 0);
    signal hash_valid_tb : std_logic;
    signal ready_tb      : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the UUT
    uut: triangle_hash_unit
        port map (
            clk        => clk_tb,
            reset      => reset_tb,
            mode       => mode_tb,
            data_in_0  => data_in_0_tb,
            data_in_1  => data_in_1_tb,
            data_in_2  => data_in_2_tb,
            data_in_3  => data_in_3_tb,
            data_in_valid => data_in_valid_tb,
            hash_out   => hash_out_tb,
            hash_valid => hash_valid_tb,
            ready      => ready_tb
        );

    -- Clock generation
    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Initial reset
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for clk_period;

        -- Testcase 1: Apply some input vectors
        data_in_0_tb <= (others => '1');
        data_in_1_tb <= (others => '0');
        data_in_2_tb <= (others => '1');
        data_in_3_tb <= (others => '0');
        data_in_valid_tb <= '1';
        mode_tb <= '1';
        wait for 100 ns;

        -- Add more test cases as needed
        -- ...

        -- End of simulation
        wait;
    end process;

end architecture sim;
