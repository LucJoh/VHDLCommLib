library vunit_lib;
context vunit_lib.vunit_context;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.i2c_pkg.all;

entity tb is
  generic (runner_cfg : string);
end entity;

architecture rtl of tb is

  signal clk         : std_logic                                := '0';
  signal dcl_tb      : std_logic                                := '1';
  signal rstn        : std_logic                                := '0';
  signal i2c_in      : i2c_in_type;
  signal i2c_out     : i2c_out_type;
  signal sda         : std_logic                                := 'Z';
  signal scl         : std_logic                                := 'Z';
  signal tx_data     : std_logic_vector(datawidth - 1 downto 0) := "11110001";
  signal addr        : std_logic_vector(addrwidth - 1 downto 0) := "1110111";
  signal clk_counter : integer                                  := 0;

  constant clk_period : time := 10 ns;

begin

  -- instantiate the SPI master component
  i2c_inst : entity work.i2c
    port map (
      clk     => clk,
      rstn    => rstn,
      i2c_in  => i2c_in,
      i2c_out => i2c_out,
      scl     => scl,
      sda     => sda
      );

  -- system clock generation
  clk <= not clk after clk_period / 2;

  -- tb dcl generation process
  dcl_gen : process (clk)
  begin
    if rising_edge(clk) then
      if i2c_out.ready = '0' then
        if clk_counter = sys_clk_counts then
          dcl_tb      <= not dcl_tb;
          clk_counter <= 0;
        else
          clk_counter <= clk_counter + 1;
        end if;
      else
        dcl_tb <= '1';
      end if;
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
    wait for 20 ns;

    -- write operation test (master sends data)
    i2c_in.start   <= '1';
    i2c_in.rw      <= '0';              -- write operation
    i2c_in.addr    <= addr;             -- address to write to
    i2c_in.tx_data <= tx_data;          -- data to be sent

    wait for clk_period;

    i2c_in.start <= '0';
    --dcl_tb       <= '0';

    -- wait for address bits to be transmitted
    for i in addrwidth downto 0 loop
      wait until rising_edge(scl);
    end loop;

    wait until rising_edge(scl);
    sda <= '0';                         -- ack 
    wait until rising_edge(scl);
    sda <= 'Z';                         -- release SDA line

    -- wait for done signal to indicate end of transmission
    if i2c_out.done /= '1' then
      wait until i2c_out.done = '1';
    end if;
    wait for 1000 ns;

--      -- read operation test (master reads data)
--      spi_in.enable  <= '1';
--      spi_in.rw      <= '1';              -- read operation
--      spi_in.tx_addr <= (others => '0');  -- example address, adjust as needed
--      spi_in.tx_data <= (others => 'X');  -- don't care data
--
--      -- wait for the correct number of SCLK edges before starting MISO
--      for i in 0 to pre_miso_bits - 1 loop
--        wait until falling_edge(spi_out.sclk);
--        spi_in.enable <= '0';
--      end loop;
--
--      wait until falling_edge(spi_out.sclk);
--
--      -- feed the MISO line with the data bits
--      for i in datawidth - 1 downto 0 loop
--        spi_in.miso <= miso(i);
--        wait until falling_edge(spi_out.sclk);
--      end loop;
--
--      -- reset MISO line after transmission
--      spi_in.miso <= 'X';
--
--      -- wait for done signal to indicate end of transmission
--      wait until spi_out.done = '1';
--      wait for 100 ns;

    -- stop the simulation
--    report "-------- WRITE OPERATTION --------";
--    report "TO BE SENT : ADDRESS : " & to_string(tx_addr) & " DATA : " & to_string(tx_data);
--    report "DETECTED ON MOSI LINE : ADDRESS : " & to_string(mosi(addrwidth + datawidth - 1 downto datawidth)) & " DATA : " & to_string(mosi(datawidth - 1 downto 0));
--    report "-------- READ OPERATTION --------";
--    report "DATA SENT ON MISO LINE : " & to_string(miso);
--    report "DATA DETECTED BY MASTER : " & to_string(spi_out.rx_data);
    report "-------- TEST FINISHED SUCESSFULLY --------";
    test_runner_cleanup(runner);
    wait;

  end process;

end architecture;
