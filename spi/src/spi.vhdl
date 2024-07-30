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

architecture behavioral of spi is

begin

  process(clk, rstn)
  begin
    if rstn = '0' then
    -- reset the state machine
    elsif rising_edge(clk) then
      -- state machine

    end if;
  end process;

end behavioral;

