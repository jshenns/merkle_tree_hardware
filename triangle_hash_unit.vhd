library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity triangle_hash_unit is
    port (
        clk          : in  std_logic;                   -- Clock input
        reset        : in  std_logic;                   -- Synchronous reset input
        mode         : in  std_logic; -- Mode input
        data_in_0    : in  std_logic_vector(255 downto 0); -- First 256-bit input vector
        data_in_1    : in  std_logic_vector(255 downto 0); -- Second 256-bit input vector
        data_in_2    : in  std_logic_vector(255 downto 0); -- Third 256-bit input vector
        data_in_3    : in  std_logic_vector(255 downto 0); -- Fourth 256-bit input vector
        data_in_valid : in std_logic;
        hash_out     : out std_logic_vector(255 downto 0); -- 256-bit hash output
        hash_valid   : out std_logic;                   -- Indicates when hash_out is valid
        ready        : out std_logic                    -- Indicates readiness to receive data
    );
end entity triangle_hash_unit;

architecture Behavioral of triangle_hash_unit is


-- SHA2-256 connection signals for instance 0
    signal s_tdata_i_0    : std_logic_vector(511 downto 0) := (others => '0');
    signal s_tlast_i_0    : std_logic := '0';
    signal s_tvalid_i_0    : std_logic := '0';
    signal s_tready_o_0    : std_logic := '0';
    signal digest_o_0      : std_logic_vector(255 downto 0) := (others => '0');
    signal digest_valid_o_0 : std_logic := '0';

    -- SHA2-256 connection signals for instance 1
    signal s_tdata_i_1    : std_logic_vector(511 downto 0) := (others => '0');
    signal s_tlast_i_1    : std_logic := '0';
    signal s_tvalid_i_1    : std_logic := '0';
    signal s_tready_o_1    : std_logic := '0';
    signal digest_o_1      : std_logic_vector(255 downto 0) := (others => '0');
    signal digest_valid_o_1 : std_logic := '0';

    -- SHA2-256 connection signals for instance 2
    signal s_tdata_i_2    : std_logic_vector(511 downto 0) := (others => '0');
    signal s_tlast_i_2    : std_logic := '0';
    signal s_tvalid_i_2    : std_logic := '0';
    signal s_tready_o_2    : std_logic := '0';
    signal digest_o_2      : std_logic_vector(255 downto 0) := (others => '0');
    signal digest_valid_o_2 : std_logic := '0';
    
    -- state machine stuff
    type state_type is (idle, hash_01, hash_2);  -- Define the state type
    signal state : state_type := idle;       -- Declare the state signal, initialized to idle
    signal next_state : state_type;          -- Declare a signal to hold the next state

    


begin

-- SHA256 Stream Instance 0
    sha256_stream_inst0: entity work.sha256_stream
        port map (
            clk       => clk,
            rst       => reset,
            mode      => '1',  -- Connect mode signal for instance 0
            s_tdata_i => s_tdata_i_0,
            s_tlast_i => s_tlast_i_0,
            s_tvalid_i => s_tvalid_i_0,
            s_tready_o => s_tready_o_0,
            digest_o   => digest_o_0,
            digest_valid_o => digest_valid_o_0
        );

    -- SHA256 Stream Instance 1
    sha256_stream_inst1: entity work.sha256_stream
        port map (
            clk       => clk,
            rst       => reset,
            mode      => '1',  -- Connect mode signal for instance 1
            s_tdata_i => s_tdata_i_1,
            s_tlast_i => s_tlast_i_1,
            s_tvalid_i => s_tvalid_i_1,
            s_tready_o => s_tready_o_1,
            digest_o   => digest_o_1,
            digest_valid_o => digest_valid_o_1
        );

    -- SHA256 Stream Instance 2
    sha256_stream_inst2: entity work.sha256_stream
        port map (
            clk       => clk,
            rst       => reset,
            mode      => '1',  -- Use suitable mode for instance 2
            s_tdata_i => s_tdata_i_2,
            s_tlast_i => s_tlast_i_2,
            s_tvalid_i => s_tvalid_i_2,
            s_tready_o => s_tready_o_2,
            digest_o   => digest_o_2,
            digest_valid_o => digest_valid_o_2
        );


    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset logic
            hash_out   <= (others => '0');
            hash_valid <= '0';
            ready      <= '0';

        elsif rising_edge(clk) then
                 case state is
            when idle =>
                ready <= '1';

                if data_in_valid = '1' then 

                    
                    if mode = '1'  then
                        next_state <= hash_01;
                    else
                        next_state <= hash_2; -- Transition to hash_2 if mode is not 1
                    end if;
                else
                    next_state <= idle;
                end if;
            when hash_01 =>
                -- Actions for hash_01 state
                
                ready <= '0';
                                
                if s_tready_o_0 = '1' and s_tready_o_1 = '1' and data_in_valid = '1' then
                
                    -- hash unit 0
                    s_tdata_i_0 <= data_in_0 & data_in_1;
                    s_tvalid_i_0 <= '1';
                    s_tlast_i_0 <= '1';
                    
                    -- hash unit 1
                    s_tdata_i_1 <= data_in_2 & data_in_3;
                    s_tvalid_i_1 <= '1';
                    s_tlast_i_1 <= '1';
                    
                    next_state <= hash_2;
                else
                    next_state <= hash_01;
                    s_tvalid_i_0 <= '0';
                    s_tlast_i_0 <= '0';
                    
                    s_tvalid_i_1 <= '0';
                    s_tlast_i_1 <= '0';

           
                end if;
                    s_tvalid_i_2 <= '0';
            when hash_2 =>
            
                ready <= '0';
                -- Make sure the other two hash units are in active
                s_tvalid_i_0 <= '0';
                s_tlast_i_0 <= '0';
                    
                s_tvalid_i_1 <= '0';
                s_tlast_i_1 <= '0';

                
                if (digest_valid_o_0 = '1' and digest_valid_o_1 = '1') then
                    -- hash unit two works when the other two are done
                    s_tdata_i_2 <= digest_o_0 & digest_o_1;
                    s_tvalid_i_2 <= '1';
                    s_tlast_i_2 <= '1';
                elsif mode = '0' and data_in_valid = '1' then
                    s_tdata_i_2 <= data_in_0 & data_in_1;
                    s_tvalid_i_2 <= '1';
                    s_tlast_i_2 <= '1';          
                
                else
                    s_tvalid_i_2 <= '0';
                    s_tlast_i_2 <= '0';
                end if;
                
                if digest_valid_o_2 = '1' then
                    next_state <= idle;
                end if;
                
            when others =>
                next_state <= idle;
                ready <= '1';
        end case;
        
            hash_out <= digest_o_2;
            hash_valid <= digest_valid_o_2;
            state <= next_state;
            
        end if;
    end process;

end architecture Behavioral;
