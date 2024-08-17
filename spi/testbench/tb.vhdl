library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.spi_pkg.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end entity;

architecture rtl of tb is

  signal clk     : std_logic                                                := '0';
  signal rstn    : std_logic                                                := '0';
  signal spi_in  : spi_in_type;
  signal spi_out : spi_out_type;
  signal miso    : std_logic_vector(datawidth - 1 downto 0)                 := "11110001";
  signal mosi    : std_logic_vector(1 + addrwidth + datawidth - 1 downto 0) := (others => 'X');
  signal tx_data : std_logic_vector(datawidth - 1 downto 0)                 := "11110001";
  signal tx_addr : std_logic_vector(addrwidth - 1 downto 0)                 := "11110000";

  constant clk_period : time := 10 ns;

  -- calculate the total number of bits to handle before MISO data is fed
  constant pre_miso_bits : integer := addrwidth + 1;  -- Address bits + RW bit

begin

  -- instantiate the SPI master component
  spi_inst : entity work.spi
    port map (
      clk     => clk,
      rstn    => rstn,
      spi_in  => spi_in,
      spi_out => spi_out
      );

  -- clock generation
  clk <= not clk after clk_period / 2;

  -- stimulus process
  stimulus_process : process
  begin

    if (cpol = '0' and cpha = '1') or (cpol = '1' and cpha = '0') then  -- falling_edge(clk)

      -- reset the system
      rstn <= '0';
      wait for 20 ns;
      rstn <= '1';
      wait for 20 ns;

      spi_in.miso <= 'X';

      -- write operation test (master sends data)
      spi_in.enable  <= '1';
      spi_in.rw      <= '0';            -- write operation
      spi_in.tx_addr <= tx_addr;        -- address to write to
      spi_in.tx_data <= tx_data;        -- data to be sent

      wait until falling_edge(spi_out.sclk);

      for i in 1 + addrwidth + datawidth - 1 downto 0 loop
        wait until falling_edge(spi_out.sclk);
        mosi(i)       <= spi_out.mosi;
        spi_in.enable <= '0';
      end loop;

      -- wait for done signal to indicate end of transmission
      if spi_out.done /= '1' then
        wait until spi_out.done = '1';
      end if;
      wait for 1000 ns;

      -- read operation test (master reads data)
      spi_in.enable  <= '1';
      spi_in.rw      <= '1';              -- read operation
      spi_in.tx_addr <= (others => '0');  -- example address, adjust as needed
      spi_in.tx_data <= (others => 'X');  -- don't care data

      -- wait for the correct number of SCLK edges before starting MISO
      for i in 0 to pre_miso_bits - 1 loop
        wait until falling_edge(spi_out.sclk);
        spi_in.enable <= '0';
      end loop;

      wait until falling_edge(spi_out.sclk);

      -- feed the MISO line with the data bits
      for i in datawidth - 1 downto 0 loop
        spi_in.miso <= miso(i);
        wait until falling_edge(spi_out.sclk);
      end loop;

      -- reset MISO line after transmission
      spi_in.miso <= 'X';

      -- wait for done signal to indicate end of transmission
      wait until spi_out.done = '1';
      wait for 100 ns;

    else                                -- rising_edge(clk)

      -- reset the system
      rstn <= '0';
      wait for 20 ns;
      rstn <= '1';
      wait for 20 ns;

      spi_in.miso <= 'X';

      -- write operation test (master sends data)
      spi_in.enable  <= '1';
      spi_in.rw      <= '0';            -- write operation
      spi_in.tx_addr <= tx_addr;        -- address to write to
      spi_in.tx_data <= tx_data;        -- data to be sent

      wait until rising_edge(spi_out.sclk);

      for i in 1 + addrwidth + datawidth - 1 downto 0 loop
        wait until rising_edge(spi_out.sclk);
        mosi(i)       <= spi_out.mosi;
        spi_in.enable <= '0';
      end loop;

      -- wait for done signal to indicate end of transmission
      if spi_out.done /= '1' then
        wait until spi_out.done = '1';
      end if;
      wait for 1000 ns;

      -- read operation test (master reads data)
      spi_in.enable  <= '1';
      spi_in.rw      <= '1';              -- read operation
      spi_in.tx_addr <= (others => '0');  -- example address, adjust as needed
      spi_in.tx_data <= (others => 'X');  -- don't care data

      -- wait for the correct number of SCLK edges before starting MISO
      for i in 0 to pre_miso_bits - 1 loop
        wait until rising_edge(spi_out.sclk);
        spi_in.enable <= '0';
      end loop;

      wait until rising_edge(spi_out.sclk);

      -- feed the MISO line with the data bits
      for i in datawidth - 1 downto 0 loop
        spi_in.miso <= miso(i);
        wait until rising_edge(spi_out.sclk);
      end loop;

      -- reset MISO line after transmission
      spi_in.miso <= 'X';

      -- wait for done signal to indicate end of transmission
      wait until spi_out.done = '1';
      wait for 100 ns;

    end if;

    -- stop the simulation
    report "-------- WRITE OPERATTION --------";
    report "TO BE SENT : ADDRESS : " & to_string(tx_addr) & " DATA : " & to_string(tx_data);
    report "DETECTED ON MOSI LINE : ADDRESS : " & to_string(mosi(addrwidth + datawidth - 1 downto datawidth)) & " DATA : " & to_string(mosi(datawidth - 1 downto 0));
    report "-------- READ OPERATTION --------";
    report "DATA SENT ON MISO LINE : " & to_string(miso);
    report "DATA DETECTED BY MASTER : " & to_string(spi_out.rx_data);
    report "-------- TEST FINISHED SUCESSFULLY --------"
      severity failure;

  end process;

end architecture;
