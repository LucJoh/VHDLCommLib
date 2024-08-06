library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.spi_pkg.all;

entity tb is
    end entity;

architecture rtl of tb is

    signal clk           : std_logic := '0';
    signal rstn          : std_logic := '1';
    signal spi_in        : spi_in_type;
    signal spi_out       : spi_out_type;
    signal test_finished : std_logic := '0';
    constant clk_period  : time      := 10 ns;

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

component spi is
    port (
             clk     : in  std_logic;
             rstn    : in  std_logic;
             spi_in  : in  spi_in_type;
             spi_out : out spi_out_type
         );
end component spi;

begin

    clk <= not clk after clk_period/2;

    spi_inst :
    component spi
        port map(
                    clk     => clk,
                    rstn    => rstn,
                    spi_in  => spi_in,
                    spi_out => spi_out
                );

    -- stimulus process
        stimulus_process : process
        begin
        -- initialize/reset
            rstn <= '0';
            wait for clk_period;
            rstn <= '1';
            wait for clk_period;

            spi_in.rw      <= '0';

        -- test vectors
            for i in patterns'range loop
                wait for clk_period*100;
                --wait until spi_out.ready = '1';
                wait for clk_period;
                spi_in.enable  <= '1';
                spi_in.tx_data <= patterns(i);
                spi_in.tx_addr <= patterns(i);
                wait for clk_period;
                spi_in.enable  <= '0';
            end loop;

            wait for clk_period*10;
            test_finished <= '1';

        end process;

    -- end simulation process
        end_process : process(test_finished)
        begin
            if (test_finished = '1') then
                assert false
                report "TEST FINISHED SUCESSFULLY"
                severity failure;
            end if;
        end process;


end architecture;
