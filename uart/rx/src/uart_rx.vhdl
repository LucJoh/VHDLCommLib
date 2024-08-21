-------------------------------------------------------------------------------
-- Title      : UART receiver
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : uart_rx.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-08-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: UART receiver implemented in VHDL
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-08-20  1.0      lucjoh  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_pkg.all;

entity uart_rx is
  port (clk         : in  std_logic;
        rstn        : in  std_logic;
        uart_rx_in  : in  uart_rx_in_type;
        uart_rx_out : out uart_rx_out_type
        );
end uart_rx;

architecture rtl of uart_rx is

  type state_type is (idle, transfer);

  type reg_type is record
    state                 : state_type;
    i                     : integer;    -- rx_vector index
    sys_clk_counter       : integer;
    data                  : std_logic_vector(datawidth - 1 downto 0);
    rx_vector             : std_logic_vector(1 + datawidth-1 + 1 downto 0);
    baud_clk              : std_logic;
    baud_clk_prev         : std_logic;
    baud_clk_rising_edge  : boolean;
    baud_clk_falling_edge : boolean;
    rx                    : std_logic;
    rx_prev               : std_logic;
    rx_falling_edge       : boolean;
    done                  : std_logic;
    ready                 : std_logic;
  end record;

  -- default register values
  constant reg_init : reg_type := (state                 => idle,
                                   i                     => 0,
                                   sys_clk_counter       => 0,
                                   data                  => (others => 'X'),
                                   rx_vector             => (others => 'X'),
                                   baud_clk              => '0',
                                   baud_clk_prev         => '0',
                                   baud_clk_rising_edge  => false,
                                   baud_clk_falling_edge => false,
                                   rx                    => '0',
                                   rx_prev               => '0',
                                   rx_falling_edge       => false,
                                   done                  => '0',
                                   ready                 => '0');

  signal r, rin : reg_type := reg_init;

---------- begin architecture ------------

begin

  combinational : process(uart_rx_in, r) is
    variable v : reg_type;
  begin

    ----------- default assignment -----------

    v    := r;
    v.rx := uart_rx_in.rx;

    ---------------- algorithm ---------------

    -- UART Tx state machine 
    case r.state is

      when idle =>

        -- rx falling edge detection
        v.rx_falling_edge := v.rx = '0' and v.rx_prev = '1';
        v.rx_prev         := v.rx;

        v.done := '0';
        if r.rx_falling_edge then
          v.done         := '0';
          v.i            := 1;
          v.ready        := '0';
          v.state        := transfer;
          v.rx_vector(0) := '0';        -- start bit
        else
          v.ready     := '1';
          v.done      := '0';
          v.rx_vector := (others => 'X');
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

        -- receive data
        if r.baud_clk_rising_edge then

          if r.i > 1 + datawidth-1 + 1 then
            v.done  := '1';
            v.state := idle;
            v.data  := v.rx_vector(datawidth downto 1);
          else
            v.rx_vector(v.i) := r.rx;
            v.i              := v.i + 1;
          end if;

        end if;

      when others =>

        -- nothing

    end case;

    ----- register input to seq process -----

    rin <= v;

    ------------- entity output -------------

    uart_rx_out.ready <= r.ready;
    uart_rx_out.done  <= r.done;
    uart_rx_out.data  <= r.data;

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
