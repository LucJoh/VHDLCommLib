-------------------------------------------------------------------------------
-- Title      : SPI master
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : spi.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-07-30
-- Last update: 2024-08-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: SPI master implementation in VHDL
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-07-30  1.0      lucjoh  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spi_pkg.all;

entity spi is
  port (clk     : in  std_logic;
        rstn    : in  std_logic;
        spi_in  : in  spi_in_type;
        spi_out : out spi_out_type
        );
end spi;

architecture rtl of spi is

  type state_type is (idle, transfer);

  type reg_type is record
    state             : state_type;
    i                 : integer;        -- data index
    tx_data           : std_logic_vector(addrwidth + datawidth downto 0);  -- data to send
    rx_data           : std_logic_vector(datawidth - 1 downto 0);  -- received data
    rx_data_temp      : std_logic_vector(datawidth - 1 downto 0);  -- received data
    mosi              : std_logic;
    miso              : std_logic;
    sclk              : std_logic;
    sclk_prev         : std_logic;
    sclk_falling_edge : boolean;
    sclk_rising_edge  : boolean;
    sclk_sample       : boolean;
    clk_counter       : integer;
    cs                : std_logic;
    done              : std_logic;      -- SPI transfer done
    ready             : std_logic;      -- SPI master ready for transfer
  end record;

  -- default register values
  constant reg_init : reg_type := (state             => idle,
                                   i                 => addrwidth + datawidth,
                                   tx_data           => (others => '0'),
                                   rx_data           => (others => '0'),
                                   rx_data_temp      => (others => '0'),
                                   mosi              => '0',
                                   miso              => '0',
                                   sclk              => cpol,
                                   sclk_prev         => cpol,
                                   sclk_falling_edge => false,
                                   sclk_rising_edge  => false,
                                   sclk_sample       => false,
                                   clk_counter       => 0,
                                   cs                => '1',
                                   done              => '0',
                                   ready             => '0');

  signal r, rin : reg_type := reg_init;

---------- begin architecture ------------

begin

  combinational : process(spi_in, r) is
    variable v : reg_type;
  begin

    ----------- default assignment -----------

    v      := r;
    v.miso := spi_in.miso;

    ---------------- algorithm ---------------

    -- SPI state machine 
    case r.state is

      when idle =>

        v.done := '0';
        if spi_in.enable = '1' then
          v.done    := '0';
          v.i       := addrwidth + datawidth;
          v.cs      := '0';
          v.ready   := '0';
          v.state   := transfer;
          v.tx_data := spi_in.rw & spi_in.tx_addr & spi_in.tx_data;
        else
          v.ready             := '1';
          v.done              := '0';
          v.cs                := '1';
          v.sclk              := cpol;
          v.clk_counter       := 0;
          v.sclk_prev         := cpol;
          v.sclk_rising_edge  := false;
          v.sclk_falling_edge := false;
          v.mosi              := '0';
        end if;

      when transfer =>

        -- SCLK generation
        if (r.clk_counter = 4) then
          v.clk_counter := 0;
          v.sclk        := not v.sclk;
        else
          v.clk_counter := v.clk_counter + 1;
        end if;

        -- SCLK edge detection
        v.sclk_rising_edge  := v.sclk = '1' and v.sclk_prev = '0';
        v.sclk_falling_edge := v.sclk = '0' and v.sclk_prev = '1';
        v.sclk_prev         := v.sclk;

        -- CPOL and CPHA configuration
        if cpol = '0' and cpha = '0' then
          v.sclk_sample := v.sclk_rising_edge;
        elsif cpol = '0' and cpha = '1' then
          v.sclk_sample := v.sclk_falling_edge;
        elsif cpol = '1' and cpha = '0' then
          v.sclk_sample := v.sclk_falling_edge;
        elsif cpol = '1' and cpha = '1' then
          v.sclk_sample := v.sclk_rising_edge;
        end if;

        -- transfer data
        if r.sclk_sample then

          -- write
          if spi_in.rw = '0' then
            if r.i < 0 then
              v.state        := idle;
              v.done         := '1';
              v.cs           := '1';
              v.i            := addrwidth + datawidth;
              v.tx_data      := (others => '0');
              v.mosi         := '0';
              v.sclk         := cpol;
            else
              v.mosi := v.tx_data(v.i);
              v.i    := v.i - 1;
            end if;

          -- read
          else
            if r.i < 0 then
              v.state        := idle;
              v.done         := '1';
              v.cs           := '1';
              v.i            := addrwidth + datawidth;
              v.tx_data      := (others => '0');
              v.mosi         := '0';
              v.rx_data      := v.rx_data_temp;
              v.sclk         := cpol;
            elsif r.i < addrwidth then
              v.mosi              := '0';
              v.rx_data_temp(v.i) := v.miso;
              v.i                 := v.i - 1;
            else
              v.mosi := v.tx_data(v.i);
              v.i    := v.i - 1;
            end if;
          end if;

        end if;

      when others =>

        -- nothing

    end case;

    ----- register input to seq process -----

    rin <= v;

    ------------- entity output -------------

    spi_out.mosi    <= r.mosi;
    spi_out.done    <= r.done;
    spi_out.ready   <= r.ready;
    spi_out.sclk    <= r.sclk;
    spi_out.cs      <= r.cs;
    spi_out.rx_data <= r.rx_data;

  end process;

  sequential : process(clk) is
  begin
    if rstn = '0' then
      r <= reg_init;
    elsif rising_edge(clk) then
      r <= rin;
    end if;
  end process;

end architecture;
