-------------------------------------------------------------------------------
-- Title      : SPI master
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : spi.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-07-30
-- Last update: 2024-07-30
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

  type state_type is (idle, transmit, done);

  type reg_type is record
    state   : state_type;
    counter : integer;
    i       : integer;     -- data index             
    data    : std_logic_vector(7 downto 0);
    enable  : std_logic;
  end record;

  signal r, rin : reg_type;

---------- begin architecture ------------

begin

  combinational : process(d, r) is
    variable v : reg_type;
    variable i : integer := 0;
  begin

    ----------- default assignment -----------

    v := r;

    ---------------- algorithm ---------------

    case r.state is

      when idle =>


      when transmit =>


      when done =>


      when others =>

        -- nothing

    end case;

    ----- register input to seq process -----

    rin <= v;

    ------------- entity output -------------

    q.data    <= r.data;
    q.addr    <= r.addr;
    q.enable  <= r.enable;
    q.load    <= r.load;
    q.adc_rst <= r.adc_rst;

  end process;

  sequential : process(clk) is
  begin
    if rst = '1' then
      r.i       <= 0;
      r.state   <= rst_pulse;
      r.load    <= '0';
      r.enable  <= '0';
      r.counter <= 0;
    elsif rising_edge(clk) then
      r <= rin;
    end if;
  end process;

end architecture;


