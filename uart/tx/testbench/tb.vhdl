library vunit_lib;
context vunit_lib.vunit_context;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.uart_pkg.all;

entity tb is
  generic (runner_cfg : string);
end entity;

architecture rtl of tb is

  signal clk                   : std_logic := '0';
  signal rstn                  : std_logic := '0';
  signal uart_tx_in            : uart_tx_in_type;
  signal uart_tx_out           : uart_tx_out_type;
  signal baud_clk              : std_logic := '0';
  signal baud_clk_prev         : std_logic := '0';
  signal baud_clk_rising_edge  : boolean   := false;
  signal baud_clk_falling_edge : boolean   := false;
  signal sys_clk_counter       : integer   := 0;
  signal tx_vector             : std_logic_vector(1 + datawidth-1 + 1 downto 0);

  constant clk_period : time := 10 ns;

begin

  -- instantiate the UART Tx module
  uart_tx_inst : entity work.uart_tx
    port map (
      clk         => clk,
      rstn        => rstn,
      uart_tx_in  => uart_tx_in,
      uart_tx_out => uart_tx_out
      );

  -- clock generation
  clk <= not clk after clk_period / 2;

  -- baud clock generation and edge detection process
  baud_clk_gen : process(clk)
  begin
    if rising_edge(clk) then
      if uart_tx_out.ready /= '1' then
        if (sys_clk_counter = sys_clk_counts) then
          sys_clk_counter <= 0;
          baud_clk        <= not baud_clk;
        else
          sys_clk_counter <= sys_clk_counter + 1;
        end if;
      end if;
      -- baud_clk edge detection
      baud_clk_rising_edge  <= baud_clk = '1' and baud_clk_prev = '0';
      baud_clk_falling_edge <= baud_clk = '0' and baud_clk_prev = '1';
      baud_clk_prev         <= baud_clk;
    end if;
  end process;

  -- stimulus process
  stimulus_process : process
  begin

    test_runner_setup(runner, runner_cfg);

    -- reset the system
    rstn <= '0';
    wait for 20 ns;
    rstn <= '1';
    wait for 1000 ns;

    -- first transmission
    report "-------- FIRST TRANSMISSION --------" severity note;
    uart_tx_in.start <= '1';
    uart_tx_in.data  <= "10000001";
    tx_vector        <= '1' & "10000001" & '0';
    wait for clk_period;
    uart_tx_in.start <= '0';

    for i in 0 to 1 + datawidth-1 + 1 loop
      wait until baud_clk_rising_edge;
      wait for clk_period*5;  -- because this baud clock is a few cycles ahead
      assert uart_tx_out.tx = tx_vector(i) report "Bit " & integer'image(i) & " is not correct" severity failure;
      report "Bit " & integer'image(i) & " is correct" severity note;
    end loop;

    if uart_tx_out.done /= '1' then
      wait until uart_tx_out.done = '1';
    end if;

    wait for 1000 ns;

    -- second transmission
    report "-------- SECOND TRANSMISSION --------" severity note;
    uart_tx_in.start <= '1';
    uart_tx_in.data  <= "01111110";
    tx_vector        <= '1' & "01111110" & '0';
    wait for clk_period;
    uart_tx_in.start <= '0';

    for i in 0 to 1 + datawidth-1 + 1 loop
      wait until baud_clk_rising_edge;
      wait for clk_period*5;  -- because this baud clock is a few cycles ahead
      assert uart_tx_out.tx = tx_vector(i) report "Bit " & integer'image(i) & " is not correct" severity failure;
      report "Bit " & integer'image(i) & " is correct" severity note;
    end loop;

    if uart_tx_out.done /= '1' then
      wait until uart_tx_out.done = '1';
    end if;

    wait for 1000 ns;

    -- stop the simulation
    report "-------- TEST FINISHED SUCESSFULLY --------";
    test_runner_cleanup(runner);
      --severity failure;

  end process;

end architecture;
