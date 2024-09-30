-------------------------------------------------------------------------------
-- Title      : I2C master
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : i2c.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-08-23
-- Last update: 2024-09-22
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: I2C master implementation in VHDL
-------------------------------------------------------------------------------
-- Copyright (c) 2024 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2024-08-23  1.0      lucjoh  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_pkg.all;

entity i2c is
  port (
    clk     : in    std_logic;
    rstn    : in    std_logic;
    i2c_in  : in    i2c_in_type;
    i2c_out : out   i2c_out_type;
    scl     : inout std_logic;
    sda     : inout std_logic
   --ack        : buffer std_logic
    );
end i2c;

architecture rtl of i2c is

  type state_type is (idle, addr, data);

  type reg_type is record
    state            : state_type;
    i                : integer;         -- data index
    byte_counter     : integer;         -- bytes to send/receive
    tx_addr          : std_logic_vector(addrwidth downto 0);  -- address to send + rw bit
    tx_data          : std_logic_vector(datawidth - 1 downto 0);  -- data to send
    rx_data          : std_logic_vector(datawidth - 1 downto 0);  -- received data
    rx_data_temp     : std_logic_vector(datawidth - 1 downto 0);  -- received data
    rw               : std_logic;       -- read/write bit
    dcl              : std_logic;       -- data clock (shifted scl)
    dcl_enable       : std_logic;
    dcl_prev         : std_logic;
    dcl_falling_edge : boolean;
    dcl_rising_edge  : boolean;
    dcl_sample       : boolean;
    dcl_counter      : integer;
    scl              : std_logic;
    scl_enable       : std_logic;
    scl_prev         : std_logic;
    scl_falling_edge : boolean;
    scl_rising_edge  : boolean;
    scl_sample       : boolean;
    scl_counter      : integer;
    sda              : std_logic;
    sda_enable       : std_logic;
    ack              : std_logic;
    ack_prev         : std_logic;
    ack_falling_edge : boolean;
    ack_rising_edge  : boolean;
    done             : std_logic;       -- SPI transfer done
    ready            : std_logic;       -- SPI master ready for transfer
  end record;

  -- default register values
  constant reg_init : reg_type := (state            => idle,
                                   i                => 0,
                                   byte_counter     => 0,
                                   tx_addr          => (others => '0'),
                                   tx_data          => (others => '0'),
                                   rx_data          => (others => '0'),
                                   rx_data_temp     => (others => '0'),
                                   rw               => '0',
                                   dcl              => '1',
                                   dcl_enable       => '0',
                                   dcl_prev         => '1',
                                   dcl_falling_edge => false,
                                   dcl_rising_edge  => false,
                                   dcl_sample       => false,
                                   dcl_counter      => 0,
                                   scl              => 'Z',
                                   scl_enable       => '0',
                                   scl_prev         => '1',
                                   scl_falling_edge => false,
                                   scl_rising_edge  => false,
                                   scl_sample       => false,
                                   scl_counter      => 0,
                                   sda              => 'Z',
                                   sda_enable       => '0',
                                   ack              => '0',
                                   ack_prev         => '1',
                                   ack_falling_edge => false,
                                   ack_rising_edge  => false,
                                   done             => '0',
                                   ready            => '0');

  signal r, rin : reg_type := reg_init;

---------- begin architecture ------------

begin

  combinational : process(i2c_in, sda, r) is
    variable v : reg_type;
  begin

    ----------- default assignment -----------

    v    := r;
    v.rw := i2c_in.rw;
    --v.ack  := ack;

    ---------------- algorithm ---------------

    -- DCL generation
    if r.dcl_enable = '1' then
      v.scl_enable := '1';
      if (r.dcl_counter = sys_clk_counts) then
        v.dcl_counter := 0;
        v.dcl         := not v.dcl;
      else
        v.dcl_counter := v.dcl_counter + 1;
      end if;
    else
      v.scl_enable := '0';
      v.dcl        := '1';
    end if;

    -- SCL generation
    if r.scl_enable = '1' then
      if (r.scl_counter = sys_clk_counts) then
        v.scl_counter := 0;
        v.scl         := not v.scl;
      else
        v.scl_counter := v.scl_counter + 1;
      end if;
    else
      v.scl := '1';
    end if;

    -- DCL edge detection
    v.dcl_rising_edge  := v.dcl = '1' and v.dcl_prev = '0';
    v.dcl_falling_edge := v.dcl = '0' and v.dcl_prev = '1';
    v.dcl_prev         := v.dcl;

    -- SCL edge detection
    v.scl_rising_edge  := v.scl = '1' and v.scl_prev = '0';
    v.scl_falling_edge := v.scl = '0' and v.scl_prev = '1';
    v.scl_prev         := v.scl;

    -- ACK edge detection
    --v.ack_rising_edge  := v.ack = '1' and v.ack_prev = '0';
    --v.ack_falling_edge := v.ack = '0' and v.ack_prev = '1';
    --v.ack_prev         := v.ack;

    -- I2C state machine 
    case r.state is

      when idle =>

        v.done := '0';
        if i2c_in.start = '1' then
          v.done       := '0';
          v.i          := addrwidth;
          v.ready      := '0';
          v.state      := addr;
          v.tx_addr    := i2c_in.addr & i2c_in.rw;
          v.rw         := i2c_in.rw;
          v.tx_data    := i2c_in.tx_data;
          v.sda        := '0';
          v.sda_enable := '1';
          v.dcl        := '0';
        else
          v.ready            := '1';
          v.done             := '0';
          v.sda              := 'Z';
          v.sda_enable       := '0';
          v.dcl              := '1';
          v.dcl_enable       := '0';
          v.dcl_prev         := '1';
          v.dcl_rising_edge  := false;
          v.dcl_falling_edge := false;
          v.dcl_counter      := 0;
          v.scl              := 'Z';
          v.scl_enable       := '0';
          v.scl_prev         := '1';
          v.scl_rising_edge  := false;
          v.scl_falling_edge := false;
          v.scl_counter      := 0;
          v.scl_enable       := '0';
        end if;

      when addr =>

        v.dcl_enable := '1';
        if r.dcl_rising_edge then
          v.sda := v.tx_addr(v.i);
          v.i   := v.i - 1;
          if r.i = 0 then
            v.sda_enable := '0';
          end if;
          if r.i = -1 then
            -- ack
            if r.sda = '0' then
              v.state      := data;
              v.sda        := 'Z';
              v.sda_enable := not v.rw;  -- only enable sda if writing
              v.i          := datawidth - 1;
            -- nack  
            else
              v.state := idle;
            end if;
          end if;
        end if;

      when data =>

        if r.dcl_rising_edge then
          -- write  
          if r.rw = '0' then
            v.sda := v.tx_data(v.i);
            v.i   := v.i - 1;
            if r.i = 0 then
              v.sda_enable := '0';
            end if;
            if r.i = -1 then
              -- ack
              if r.sda = '0' then
                if r.byte_counter = databytes then
                  v.state := idle;
                  v.scl   := 'Z';
                  v.done  := '1';       -- done flag set because of ack
                else
                  v.byte_counter := v.byte_counter + 1;
                  v.i            := datawidth - 1;
                end if;
              -- nack
              else
                v.state := idle;        -- done flag not set because of nack
              end if;
            end if;
          -- read 
          else
            v.rx_data_temp(v.i) := v.sda;
            v.i                 := v.i - 1;
            if r.i = -1 then
              v.rx_data := v.rx_data_temp;
            elsif r.i = -2 then         -- skip ack when reading
              if r.byte_counter = databytes then
                v.state      := idle;
                v.scl_enable := '0';
                v.done       := '1';
              else
                v.byte_counter := v.byte_counter + 1;
                v.i            := datawidth - 1;
              end if;
            end if;
          end if;
        end if;

      when others =>

        -- nothing

    end case;

    ----- register input to seq process -----

    rin <= v;

    ------------- entity output -------------

    i2c_out.done    <= r.done;
    i2c_out.ready   <= r.ready;
    i2c_out.rx_data <= r.rx_data;
    sda             <= r.sda when r.sda_enable = '1' else 'Z';
    scl             <= r.scl when r.scl_enable = '1' else 'Z';

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
