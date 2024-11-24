library vunit_lib;
context vunit_lib.vunit_context;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
  generic (
    runner_cfg     : string;
    sys_clk_period : integer := 10;     -- The period of the system clock (ns)
    scl_freq       : integer := 100;    -- The frequency of SCL (kHz)
    addrwidth      : integer := 7;      -- number of bits in the address bus
    datawidth      : integer := 8;      -- number of bits in the data bus
    databytes      : integer := 1  -- number of data bytes following the address byte
    );
end entity;

architecture rtl of tb is

  signal clk         : std_ulogic                                := '0';
  signal rstn        : std_ulogic                                := '0';
  signal start       : std_ulogic                                := '0';
  signal rw          : std_ulogic                                := '0';
  signal ready       : std_ulogic                                := '0';
  signal done        : std_ulogic                                := '0';
  signal sda         : std_logic                                 := 'Z';
  signal scl         : std_ulogic                                := 'Z';
  signal addr        : std_ulogic_vector(addrwidth - 1 downto 0) := "1110111";
  signal tx_data     : std_ulogic_vector(datawidth - 1 downto 0) := "11110001";
  signal rx_data     : std_ulogic_vector(datawidth-1 downto 0)   := (others => '0');
  signal clk_counter : integer                                   := 0;

  constant clk_period : time := 10 ns;

begin

  -------------------------------------------------------------
  -- DUT
  -------------------------------------------------------------
  i2c_inst : entity work.i2c
    port map (
      clk     => clk,                   -- i 
      rstn    => rstn,                  -- i 
      start   => start,                 -- i
      rw      => rw,                    -- i
      addr    => addr,                  -- i
      tx_data => tx_data,               -- i
      ready   => ready,                 -- i
      rx_data => rx_data,               -- o
      done    => done,                  -- o
      scl     => scl,                   -- io
      sda     => sda                    -- io 
      );

  --------------------------------------------------------------
  -- SYSTEM CLOCK GENERATION
  --------------------------------------------------------------
  clk <= not clk after clk_period / 2;

  --------------------------------------------------------------
  -- STIMULUS PROCESS
  --------------------------------------------------------------
  stimulus_process : process
  begin

    test_runner_setup(runner, runner_cfg);

    sda <= 'Z';

    ------------------------------------------------------------
    -- RESET THE SYSTEM
    ------------------------------------------------------------
   -- rstn <= '0';
   -- wait for 20 ns;
   -- rstn <= '1';
    wait for 10000 ns;

    ------------------------------------------------------------
    -- WRITE OPERATION TEST (MASTER SENDS DATA)
    ------------------------------------------------------------
    start   <= '1';
    rw      <= '0';              -- write operation

    wait for clk_period;

    start <= '0';

    -------------------------------------------------------------
    -- WAIT FOR ADDRESS BITS TO BE TRANSMITTED
    -------------------------------------------------------------
    for i in addrwidth downto 0 loop
      wait until rising_edge(scl);
    end loop;

    wait until rising_edge(scl);
    sda <= '0';                         -- ack 
    wait until rising_edge(scl);
    sda <= 'Z';                         -- release SDA line

    wait for 10000 ns;

    report "-------- TEST FINISHED SUCESSFULLY --------";
    test_runner_cleanup(runner);
    wait;

    --------------------------------------------------------------
    -- WAIT FOR DONE SIGNAL TO INDICATE END OF TRANSMISSION
    --------------------------------------------------------------
    if done /= '1' then
      wait until done = '1';
    end if;
    wait for 1000 ns;

    report "-------- TEST FINISHED SUCESSFULLY --------";
    test_runner_cleanup(runner);
    wait;

  end process;

end architecture;
