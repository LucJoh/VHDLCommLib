-------------------------------------------------------------------------------
-- Title      : SPI package file
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : spi_pkg.vhdl
-- Author     : lucjoh
-- Company    :
-- Created    : 2024-07-31
-- Last update: 2024-08-01
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Package file for SPI master. Contains the record types for the
--              input and output signals of the SPI master, as well as the
--              component declaration and the constants for the SPI master.
--
--              Parameters:
--              - sysclk_div: The division factor for the system clock to get
--                the SPI clock frequency.
--              - datalength: The number of bits in the data bus.
--              - cpol: The clock polarity of SCLK. '0' for idle low, '1' for
--                idle high.
-------------------------------------------------------------------------------
-- Copyright (c) 2024
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-07-31  1.0      Lucas   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package spi_pkg is

  ------------------------------------  
  ------------ Parameters ------------
  ------------------------------------

  constant sysclk_div : integer   := 8;    -- sclk = sysclk / sysclk_div
  constant datalength : integer   := 8;    -- data length
  constant cpol       : std_logic := '0';  -- clock polarity

  ------------------------------------
  ------------------------------------
  ------------------------------------

  type spi_in_type is record
    enable : std_logic;
    tx     : std_logic_vector(datalength - 1 downto 0);
    miso   : std_logic;
  end record spi_in_type;

  type spi_out_type is record
    rx   : std_logic_vector(datalength - 1 downto 0);
    mosi : std_logic;
    sclk : std_logic;
    cs   : std_logic;
  end record spi_out_type;

  component spi is
    port (
      clk     : in  std_logic;
      rstn    : in  std_logic;
      spi_in  : in  spi_in_type;
      spi_out : out spi_out_type
      );
  end component spi;

end package spi_pkg;
