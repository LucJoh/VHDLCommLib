-------------------------------------------------------------------------------
-- Title      : SPI master
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : spi.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-07-30
-- Last update: 2024-08-06
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
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
    --counter : integer;
    i                 : integer;        -- data index
    tx_data           : std_logic_vector(addrwidth + datawidth downto 0);  -- data to send
    rx_data           : std_logic_vector(datawidth - 1 downto 0);  -- received data
    --enable  : std_logic;
    mosi              : std_logic;
    miso              : std_logic;
    sclk              : std_logic;
    sclk_prev         : std_logic;
    sclk_falling_edge : boolean;
    sclk_rising_edge  : boolean;
    sclk_sample       : boolean;
    clk_counter       : integer;
    cs                : std_logic;
    ready             : std_logic;      -- SPI master ready for transfer
  end record;

  constant reg_init : reg_type := (state             => idle,
                                   i                 => addrwidth + datawidth - 1,
                                   tx_data           => (others => '0'),
                                   rx_data           => (others => '0'),
                                   --enable => '0',
                                   mosi              => '0',
                                   miso              => '0',
                                   sclk              => cpol,
                                   sclk_prev         => cpol,
                                   sclk_falling_edge => false,
                                   sclk_rising_edge  => false,
                                   sclk_sample       => false,
                                   clk_counter       => 0,
                                   cs                => '1',
                                   ready             => '0');

  signal r, rin : reg_type := reg_init;

---------- begin architecture ------------

begin

  combinational : process(spi_in, r) is
    variable v : reg_type;
  --variable i : integer := 0;
  begin

    ----------- default assignment -----------

    v := r;

    ---------------- algorithm ---------------


    -------------------
    -- state machine --
    -------------------
    case r.state is

      when idle =>

        if spi_in.enable = '1' then
          v.i       := addrwidth + datawidth - 1;
          v.cs      := '0';
          v.ready   := '0';
          v.state   := transfer;
          v.tx_data := spi_in.rw & spi_in.tx_addr & spi_in.tx_data;
        else
          v.ready := '1';
          v.cs    := '1';
        end if;

      when transfer =>

        -- SCLK generation
        if (r.clk_counter = sys_clk * div_factor) then
          v.clk_counter := 0;
          v.sclk        := not v.sclk;
        else
          v.clk_counter := v.clk_counter + 1;
        end if;

        -- SCLK edge detection
        v.sclk_rising_edge  := v.sclk = '1' and v.sclk_prev = '0';
        v.sclk_falling_edge := v.sclk = '0' and v.sclk_prev = '1';
        if cpha = '0' then
          v.sclk_sample := v.sclk_rising_edge;
        else
          v.sclk_sample := v.sclk_falling_edge;
        end if;

        -- transfer data
        if v.sclk_rising_edge then

          -- write
          if spi_in.rw = '0' then
            if r.i = 0 then
              v.state   := idle;
              v.cs      := '1';
              v.i       := addrwidth + datawidth - 1;
              v.tx_data := (others => '0');
            else
              v.i    := v.i - 1;
              v.mosi := v.tx_data(v.i);
            end if;

          -- read (not done yet)
          else
            if r.i = 0 then
              v.state   := idle;
              v.cs      := '1';
              v.i       := addrwidth + datawidth - 1;
              v.tx_data := (others => '0');
            else
              v.i    := v.i - 1;
              v.mosi := spi_in.tx_data(v.i);
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
