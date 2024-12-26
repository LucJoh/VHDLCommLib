-------------------------------------------------------------------------------
-- Title      : UART package file
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : uart_pkg.vhdl
-- Author     : lucjoh
-- Company    :
-- Created    : 2024-07-31
-- Last update: 2024-08-21
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Package file for UART Rx. Contains the record types for the
--              input and output signals of the UART Rx, as well as the
--              component declarations and the parameters for the UART Rx.
--
--              Parameters:
--              - sys_clk_period  : The period of the system clock
--              - baud_rate       : The baud rate of the UART communication
--              - datawidth       : The number of bits in the data bus.
-------------------------------------------------------------------------------
-- Copyright (c) 2024
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-08-18  1.0      Lucas   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package uart_pkg is

  ------------------------------------  
  ------------ Parameters ------------
  ------------------------------------

  constant sys_clk_period : integer := 10;      -- system clock period (ns)
  constant baud_rate      : integer := 115200;  -- baud rate (bps)
  constant datawidth      : integer := 8;       -- number of data bits

  ------------------------------------
  ------------------------------------
  ------------------------------------

  constant sys_clk_counts : integer := 1000000000 / (sys_clk_period * baud_rate);

  type uart_rx_in_type is record
    rx : std_logic;
  end record uart_rx_in_type;

  constant uart_rx_in_default : uart_rx_in_type := (
    rx => '1'
    );

  type uart_rx_out_type is record
    ready : std_logic;
    done  : std_logic;
    data  : std_logic_vector(datawidth - 1 downto 0);
  end record uart_rx_out_type;

  component uart_rx is
    port (
      clk         : in  std_logic;
      rstn        : in  std_logic;
      uart_rx_in  : in  uart_rx_in_type;
      uart_rx_out : out uart_rx_out_type
      );
  end component uart_rx;

end package uart_pkg;
