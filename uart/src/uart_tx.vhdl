-------------------------------------------------------------------------------
-- Title      : UART transmitter
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : uart_tx.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-08-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: UART transmitter implemented in VHDL
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-08-18  1.0      lucjoh  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_pkg.all;

entity uart_tx is
  port (clk         : in  std_logic;
        rstn        : in  std_logic;
        uart_tx_in  : in  uart_tx_in_type;
        uart_tx_out : out uart_tx_out_type
        );
end uart_tx;

architecture rtl of uart_tx is

  type state_type is (idle, transfer);

  type reg_type is record
    state                 : state_type;
    i                     : integer;    -- data index
    sys_clk_counter       : integer;    -- system clock counter
    data                  : std_logic_vector(datawidth - 1 downto 0);
    tx_vector             : std_logic_vector(1 + datawidth-1 + 1 downto 0);
    baud_clk              : std_logic;  -- baud clock
    baud_clk_prev         : std_logic;  -- baud clock previous value
    baud_clk_rising_edge  : boolean;    -- baud clock rising edge
    baud_clk_falling_edge : boolean;    -- baud clock falling edge
    tx                    : std_logic;  -- UART tx data
    done                  : std_logic;  -- UART tx done
    ready                 : std_logic;  -- UART tx ready
  end record;

  -- default register values
  constant reg_init : reg_type := (state                 => idle,
                                   i                     => 0,
                                   sys_clk_counter       => 0,
                                   data                  => (others => '0'),
                                   tx_vector             => (others => '0'),
                                   baud_clk              => '0',
                                   baud_clk_prev         => '0',
                                   baud_clk_rising_edge  => false,
                                   baud_clk_falling_edge => false,
                                   tx                    => '0',
                                   done                  => '0',
                                   ready                 => '0');

  signal r, rin : reg_type := reg_init;

---------- begin architecture ------------

begin

  combinational : process(uart_tx_in, r) is
    variable v : reg_type;
  begin

    ----------- default assignment -----------

    v      := r;
    v.data := uart_tx_in.data;

    ---------------- algorithm ---------------

    -- UART Tx state machine 
    case r.state is

      when idle =>

        v.done := '0';
        if uart_tx_in.start = '1' then
          v.done    := '0';
          v.i       := 0;
          v.ready   := '0';
          v.state   := transfer;
          v.tx_vector := '1' & uart_tx_in.data & '0';  -- LSB first ;-)
        else
          v.ready := '1';
          v.done  := '0';
        end if;

      when transfer =>

        -- baud_clk generation
        if (r.sys_clk_counter = sys_clk_counts) then
          v.sys_clk_counter := 0;
          v.baud_clk        := not v.baud_clk;
        else
          v.sys_clk_counter := v.sys_clk_counter + 1;
        end if;

        -- baud_clk edge detection
        v.baud_clk_rising_edge  := v.baud_clk = '1' and v.baud_clk_prev = '0';
        v.baud_clk_falling_edge := v.baud_clk = '0' and v.baud_clk_prev = '1';
        v.baud_clk_prev         := v.baud_clk;

        -- transfer data
        if r.baud_clk_rising_edge then

          if r.i = 1 + datawidth-1 + 1 then
            v.done  := '1';
            v.state := idle;
          else
            v.tx := v.tx_vector(v.i);
            v.i              := v.i + 1;
          end if;

        end if;

      when others =>

        -- nothing

    end case;

    ----- register input to seq process -----

    rin <= v;

    ------------- entity output -------------

    uart_tx_out.ready <= r.ready;
    uart_tx_out.tx    <= r.tx;
    uart_tx_out.done  <= r.done;

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
