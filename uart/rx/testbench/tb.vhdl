library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.uart_pkg.all;

entity tb is
end entity;

architecture rtl of tb is

  signal clk                   : std_logic       := '0';
  signal rstn                  : std_logic       := '0';
  signal uart_rx_in            : uart_rx_in_type := uart_rx_in_default;  -- rx defaulted to '1'
  signal uart_rx_out           : uart_rx_out_type;
  signal baud_clk              : std_logic       := '0';
  signal baud_clk_prev         : std_logic       := '0';
  signal baud_clk_rising_edge  : boolean         := false;
  signal baud_clk_falling_edge : boolean         := false;
  signal sys_clk_counter       : integer         := 0;
  signal rx_vector             : std_logic_vector(1 + datawidth-1 + 1 downto 0);
  signal data                  : std_logic_vector(datawidth-1 downto 0);

  constant clk_period : time := 10 ns;

  signal k : integer := 0;

begin

  -- instantiate the UART Tx module
  uart_rx_inst : entity work.uart_rx
    port map (
      clk         => clk,
      rstn        => rstn,
      uart_rx_in  => uart_rx_in,
      uart_rx_out => uart_rx_out
      );

  -- clock generation
  clk <= not clk after clk_period / 2;

  -- baud clock generation and edge detection process
  baud_clk_gen : process(clk)
  begin
    if rising_edge(clk) then
      if uart_rx_out.ready /= '1' then
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

    -- reset the system
    rstn <= '0';
    wait for 20 ns;
    rstn <= '1';
    wait for 1000 ns;

    -- first transmission
    report "-------- FIRST TRANSMISSION --------" severity note;
    data      <= "10000001";
    rx_vector <= '1' & "10000001" & '0';

    uart_rx_in.rx <= '0';  --start bit has to be outside the loop, since baud_clk is not active yet
    for i in 1 to 1 + datawidth-1 + 1 loop
      wait until baud_clk_rising_edge;
      uart_rx_in.rx <= rx_vector(i);
    end loop;

    if uart_rx_out.done /= '1' then
      wait until uart_rx_out.done = '1';
      assert uart_rx_out.data = data report "Received data is : " & to_string(uart_rx_out.data) severity failure;
      report "Data is correct" severity note;
    end if;

    k <= 0;

    wait for 1000 ns;

    -- second transmission
    report "-------- SECOND TRANSMISSION --------" severity note;
    data      <= "01111110";
    rx_vector <= '1' & "01111110" & '0';

    uart_rx_in.rx <= '0';  --start bit has to be outside the loop, since baud_clk is not active yet
    for i in 1 to 1 + datawidth-1 + 1 loop
      wait until baud_clk_rising_edge;
      uart_rx_in.rx <= rx_vector(i);
    end loop;

    if uart_rx_out.done /= '1' then
      wait until uart_rx_out.done = '1';
      assert uart_rx_out.data = data report "Received data is : " & to_string(uart_rx_out.data) severity failure;
      report "Data is correct" severity note;
    end if;

    wait for 1000 ns;

    -- stop the simulation
    report "-------- TEST FINISHED SUCESSFULLY --------"
      severity failure;

  end process;

end architecture;
