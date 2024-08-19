library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.uart_pkg.all;

entity tb is
end entity;

architecture rtl of tb is

  signal clk             : std_logic := '0';
  signal rstn            : std_logic := '0';
  signal uart_tx_in      : uart_tx_in_type;
  signal uart_tx_out     : uart_tx_out_type;
  signal baud_clk        : std_logic := '0';
  signal sys_clk_counter : integer   := 0;

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

  -- baud clock generation process
  baud_clk_gen : process(clk)
  begin
    if rising_edge(clk) then
      if (sys_clk_counter = sys_clk_counts) then
        sys_clk_counter <= 0;
        baud_clk        <= not baud_clk;
      else
        sys_clk_counter <= sys_clk_counter + 1;
      end if;
    end if;
  end process;

  -- stimulus process
  stimulus_process : process
  begin

    -- reset the system
    rstn <= '0';
    wait for 20 ns;
    rstn <= '1';
    wait for 1000 ns;

    -- first transmission
    uart_tx_in.start <= '1';
    uart_tx_in.data  <= "10000001";
    wait for clk_period;
    uart_tx_in.start <= '0';

--      for i in 0 to 1 + datawidth-1 + 1 loop
--        wait until rising_edge(baud_clk);
--        assert uart_tx_out.tx = '1' report "Bit " & integer'image(i) & " is not correct" severity failure;
--      end loop;

    if uart_tx_out.done /= '1' then
      wait until uart_tx_out.done = '1';
    end if;

    wait for 1000 ns;

    -- second transmission
    uart_tx_in.start <= '1';
    uart_tx_in.data  <= "01111110";
    wait for clk_period;
    uart_tx_in.start <= '0';

      for i in 0 to 1 + datawidth-1 + 1 loop
        wait until rising_edge(baud_clk);
        assert uart_tx_out.tx /= uart_tx_in.data(i) report "Bit " & integer'image(i) & " is not correct" severity failure;
      end loop;

    if uart_tx_out.done /= '1' then
      wait until uart_tx_out.done = '1';
    end if;

    wait for 1000 ns;

    -- stop the simulation
    report "-------- TEST FINISHED SUCESSFULLY --------"
      severity failure;

  end process;

end architecture;
