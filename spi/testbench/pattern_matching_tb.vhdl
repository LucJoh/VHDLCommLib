library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity pattern_matching_tb is
end entity;

architecture sim of pattern_matching_tb is

    signal clk           : std_logic                     := '0';
    signal reset_n       : std_logic                     := '0';
    signal data_in       : std_logic_vector(7 downto 0)  := x"00";
    signal match         : std_logic_vector(31 downto 0) := x"00000000";
    signal prev_match    : std_logic_vector(31 downto 0) := x"00000000";
    signal test_finished : std_logic                     := '0';
    constant clk_period  : time                          := 10 ns;

    type patterns_array is array(0 to 43) of std_logic_vector(7 downto 0);

    constant patterns : patterns_array := (
        x"68", x"6F", x"73", x"74",     -- host
        x"68", x"6F", x"73", x"74",     -- host
        x"13", x"37", x"13", x"37",     -- [junk]
        x"19", x"99", x"19", x"99",     -- [junk]
        x"31", x"41", x"59", x"26",     -- [junk]
        x"55", x"53", x"45", x"52",     -- USER
        x"55", x"53", x"45", x"52",     -- USER
        x"72", x"30", x"30", x"74",     -- r00t
        x"72", x"30", x"30", x"74",     -- r00t
        x"72", x"65", x"77", x"74",     -- rewt
        x"72", x"65", x"77", x"74"      -- rewt
        );

    component pattern_matching is
        generic (pattern_size    : integer := 4;
                 character_width : integer := 8;
                 pattern_width   : integer := 32;
                 stored_patterns : integer := 111;
                 register_size   : integer := 4);
        port (clk     : in  std_logic;
              reset_n : in  std_logic;
              data_in : in  std_logic_vector(7 downto 0);
              match   : out std_logic_vector(31 downto 0)
              );
    end component;

begin

    clk <= not clk after clk_period/2;

    pattern_matching_inst :
        component pattern_matching
            port map(
                clk     => clk,
                reset_n => reset_n,
                data_in => data_in,
                match   => match
                );

    -- Stimulus process
    stimulus_process : process
    begin
        -- Initialize/reset
        reset_n <= '0';
        wait for clk_period;
        reset_n <= '1';
        wait for clk_period;

        -- Test vectors
        for i in patterns'range loop
            data_in <= patterns(i);
            wait for clk_period;
        end loop;

        wait for clk_period*10;
        test_finished <= '1';

    end process;

    -- Process for writing to file
    dump_process : process(reset_n, clk, match, prev_match, test_finished)
--          file test_vector      : text open write_mode is "output_file.txt";
--          variable row          : line;
    begin

--          if(reset_n='0') then
        ------------------------------------
--              elsif(rising_edge(clk)) then
--                  --if(match /= prev_match) then
--                      hwrite(row,match, right, 8);
--                      writeline(test_vector,row);
--                      prev_match <= match;
--                  --end if;
--              end if;

        -- End simulation

        if (test_finished = '1') then
            assert false
                report "TEST FINISHED SUCESSFULLY"
                severity failure;
        end if;

    end process;


end architecture;
