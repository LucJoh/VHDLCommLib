-------------------------------------------------------------------------------
-- Title      : I2C package file
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : i2c_pkg.vhdl
-- Author     : lucjoh
-- Company    :
-- Created    : 2024-08-22
-- Last update: 2024-08-22
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Package file for SPI master. Contains the record types for the
--              input and output signals of the SPI master, as well as the
--              component declaration and the parameters for the SPI master.
--
--              Parameters:
--              - sys_clk_period  : The period of the system clock (ns).
--              - scl_freq        : The frequency of SCL (kHz).
--              - addrwidth       : The number of bits in the address bus.
--              - datawidth       : The number of bits in the data bus.
--              - databytes       : The number of data bytes following the address byte.
-------------------------------------------------------------------------------
-- Copyright (c) 2024
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-08-22  1.0      Lucas   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package i2c_pkg is

  ------------------------------------  
  ------------ Parameters ------------
  ------------------------------------

  constant sys_clk_period : integer := 10;  -- The period of the system clock (ns)
  constant scl_freq       : integer := 100;  -- The frequency of SCL (kHz)
  constant addrwidth      : integer := 7;  -- number of bits in the address bus
  constant datawidth      : integer := 8;  -- number of bits in the data bus
  constant databytes      : integer := 1;  -- number of data bytes following the address byte

  ------------------------------------
  ------------------------------------
  ------------------------------------

  constant sys_clk_counts : integer := 1000000 / (sys_clk_period * scl_freq);

--  type i2c_line_type is record
--    scl : std_logic;
--    sda : std_logic;
--    ack : std_logic;
--  end record i2c_line_type;

  type i2c_in_type is record
    start   : std_logic;
    rw      : std_logic;
    addr    : std_logic_vector(addrwidth-1 downto 0);
    tx_data : std_logic_vector(datawidth-1 downto 0);
  end record i2c_in_type;

  type i2c_out_type is record
    ready   : std_logic;
    rx_data : std_logic_vector(datawidth-1 downto 0);
    done    : std_logic;
  end record i2c_out_type;

  component i2c is
    port (
      clk        : in      std_logic;
      rstn       : in      std_logic;
      master_in  : in      i2c_in_type;
      master_out : out     i2c_out_type;
      scl        : inout   std_logic;
      sda        : inout   std_logic
      --ack        : buffer  std_logic
      );
  end component i2c;

end package i2c_pkg;
