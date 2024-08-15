-------------------------------------------------------------------------------
-- Title      : SPI package file
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : spi_pkg.vhdl
-- Author     : lucjoh
-- Company    :
-- Created    : 2024-07-31
-- Last update: 2024-08-15
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Package file for SPI master. Contains the record types for the
--              input and output signals of the SPI master, as well as the
--              component declaration and the constants for the SPI master.
--
--              Parameters:
--              - sysclk     : The frequency of the system clock.
--              - div_factor : The division factor for the system clock to get
--                             the SPI clock frequency.
--              - addrwidth  : The number of bits in the address bus.
--              - datawidth  : The number of bits in the data bus.
--              - cpol       : The clock polarity for SCLK. '0' for idle low, 
--                             '1' for idle high.
--              - cpha       : The clock phase for SCLK. '0' for sampling on
--                             the first edge, '1' for sampling on the second
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

  constant sys_clk    : integer   := 100e6;  -- system clock frequency (Hz)
  constant div_factor : integer   := 8;  -- sclk = sysclk / div_factor
  constant addrwidth  : integer   := 8;  -- number of bits in the address bus
  constant datawidth  : integer   := 8;  -- number of bits in the data bus
  constant cpol       : std_logic := '0';    -- clock polarity
  constant cpha       : std_logic := '0';    -- clock phase

  ------------------------------------
  ------------------------------------
  ------------------------------------

  type spi_in_type is record
    enable  : std_logic;
    tx_addr : std_logic_vector(addrwidth - 1 downto 0);
    tx_data : std_logic_vector(datawidth - 1 downto 0);
    miso    : std_logic;
    rw      : std_logic;
  end record spi_in_type;

  type spi_out_type is record
    rx_data : std_logic_vector(datawidth - 1 downto 0);
    mosi    : std_logic;
    sclk    : std_logic;
    cs      : std_logic;
    done    : std_logic;
    ready   : std_logic;
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
