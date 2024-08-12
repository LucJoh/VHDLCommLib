library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.spi_pkg.all;

entity tb is
end entity;

architecture rtl of tb is

  type state_type is (tbidle, tbwrite, tbread, tbsim_completed);
  signal tbstate : state_type := tbwrite;

  signal clk                : std_logic                    := '0';
  signal rstn               : std_logic                    := '0';
  signal spi_in             : spi_in_type;
  signal spi_out            : spi_out_type;
  signal test_finished      : std_logic                    := '0';
  signal dummy_data         : std_logic_vector(7 downto 0) := "10000001";
  signal addr_bit_counter   : integer                      := 0;
  signal addr_received      : boolean                      := false;
  signal sclk_prev          : std_logic                    := cpol;
  signal sclk_rising_edge   : boolean                      := false;
  signal sclk_falling_edge  : boolean                      := false;
  signal ready_prev         : std_logic                    := '0';
  signal ready_rising_edge  : boolean                      := false;
  signal ready_falling_edge : boolean                      := false;
  signal received_addr      : std_logic_vector(7 downto 0) := (others => '0');
  constant clk_period       : time                         := 10 ns;
  signal i                  : integer                      := 0;
  signal j                  : integer                      := 0;
  signal bit_counter        : integer                      := 0;

  type t_array is array(0 to 4) of std_logic_vector(7 downto 0);

  constant data : t_array := (
    "10000001",
    "01111110",
    "10000001",
    "01111110",
    "10000001"
    );

  constant addr : t_array := (
    "10000001",
    "01111110",
    "10000001",
    "01111110",
    "10000001"
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

  clk  <= not clk after clk_period/2;
  rstn <= '1'     after clk_period;

  spi_inst :
    component spi
      port map(
        clk     => clk,
        rstn    => rstn,
        spi_in  => spi_in,
        spi_out => spi_out
        );

  -- SCLK edge detection process
  sclk_detection_process : process(clk)
  begin
    if rising_edge(clk) then
      sclk_rising_edge  <= spi_out.sclk = '1' and sclk_prev = '0';
      sclk_falling_edge <= spi_out.sclk = '0' and sclk_prev = '1';
      sclk_prev         <= spi_out.sclk;
    end if;
  end process;

  -- SPI ready edge detection process
  ready_detection_process : process(clk)
  begin
    if rising_edge(clk) then
      ready_rising_edge  <= spi_out.ready = '1' and ready_prev = '0';
      ready_falling_edge <= spi_out.ready = '0' and ready_prev = '1';
      ready_prev         <= spi_out.ready;
    end if;
  end process;

  -- stimulus process
  stimulus_process : process(clk)
  begin

    if rising_edge(clk) then

--      if spi_out.ready = '1' then
--        spi_in.enable <= '1';
--        tbstate       <= tbwrite;
--      end if;

      case tbstate is

        when tbwrite =>

          spi_in.rw <= '0';

          if spi_out.ready = '1' then
            spi_in.enable <= '1';
          else
            spi_in.enable <= '0';
          end if;
          if spi_out.done = '1' then
            i <= i + 1;
          end if;
          if i = 4 then
            tbstate <= tbread;
            i       <= 0;
          end if;
          spi_in.tx_addr <= addr(i);
          spi_in.tx_data <= data(i);

        when tbread =>

          spi_in.rw <= '1';

          if sclk_rising_edge then
            if bit_counter > 1 + addrwidth then
              spi_in.miso <= dummy_data(j);
              j           <= j + 1;
          else
              spi_in.miso <= 'X';
            end if;

            bit_counter <= bit_counter + 1;

            if bit_counter > 1 + addrwidth + datawidth - 1 then
              bit_counter <= 0;
              j           <= 0;
            end if;
          end if;

          if spi_out.ready = '1' then
            spi_in.enable <= '1';
          else
            spi_in.enable <= '0';
          end if;
          if spi_out.done = '1' then
            i <= i + 1;
          end if;
          if i = 4 then
            tbstate <= tbsim_completed;
            i       <= 0;
          end if;
          spi_in.tx_addr <= addr(i);
          spi_in.tx_data <= (others => 'X');

        when tbsim_completed =>

          test_finished <= '1';

        when others =>

          -- nothing

      end case;

    end if;

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
