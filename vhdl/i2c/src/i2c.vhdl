-------------------------------------------------------------------------------
-- Title      : I2C master
-- Project    : VHDLCommLib
-------------------------------------------------------------------------------
-- File       : i2c.vhdl
-- Author     : lucjoh
-- Company    : 
-- Created    : 2024-08-23
-- Last update: 2024-11-30
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

entity i2c is
  generic (
    sys_clk_period : integer := 10;     -- The period of the system clock (ns)
    scl_freq       : integer := 100;    -- The frequency of SCL (kHz)
    addrwidth      : integer := 7;      -- number of bits in the address bus
    datawidth      : integer := 8;      -- number of bits in the data bus
    databytes      : integer := 1  -- number of data bytes following the address byte
    );
  port (
    clk  : in std_ulogic;
    rstn : in std_ulogic;

    rw    : in std_ulogic;
    start : in std_ulogic;

    addr    : in  std_ulogic_vector(addrwidth-1 downto 0);
    tx_data : in  std_ulogic_vector(datawidth-1 downto 0);
    rx_data : out std_ulogic_vector(datawidth-1 downto 0);

    ready     : out std_ulogic;
    done      : out std_ulogic;
    slave_ack : out std_ulogic;

    scl : out   std_ulogic;
    sda : inout std_logic
    );
end i2c;

architecture rtl of i2c is

  constant sys_clk_counts : integer := 1000000 / (sys_clk_period * scl_freq);

  type state_type is (idle_state, addr_state, data_state);

  signal state        : state_type := idle_state;
  signal i            : integer    := 0;
  signal byte_counter : integer    := 0;

  signal tx_addr      : std_ulogic_vector(addrwidth downto 0)     := (others => '0');  -- address + rw
  signal rx_data_temp : std_ulogic_vector(datawidth - 1 downto 0) := (others => '0');

  signal scl_local        : std_ulogic := 'Z';
  signal scl_enable       : std_ulogic := '0';
  signal scl_local_prev   : std_ulogic := '1';
  signal scl_falling_edge : boolean    := false;
  signal scl_rising_edge  : boolean    := false;
  signal scl_counter      : integer    := 0;

  signal sda_local  : std_ulogic := 'Z';
  signal sda_enable : std_ulogic := '0';

  signal start_prev         : std_ulogic := '1';
  signal start_falling_edge : boolean    := false;
  signal start_rising_edge  : boolean    := false;

-------------------------------------------------------  
-- BEGIN ARCHITECTURE 
-------------------------------------------------------
begin

  clock_gen_process : process(clk) is
  begin
    if rising_edge(clk) then
      -------------------------------------------------  
      -- SCL GENERATION
      -------------------------------------------------  
      if scl_enable = '1' then
        if (scl_counter = sys_clk_counts) then
          scl_counter <= 0;
          scl_local   <= not scl_local;
        else
          scl_counter <= scl_counter + 1;
        end if;
      else
        scl_local <= '1';
      end if;
    end if;
  end process;

  edge_detect_process : process(clk) is
  begin
    if rising_edge(clk) then
      -------------------------------------------------  
      -- SCL DETECTION
      -------------------------------------------------  
      scl_rising_edge    <= scl_local = '1' and scl_local_prev = '0';
      scl_falling_edge   <= scl_local = '0' and scl_local_prev = '1';
      scl_local_prev     <= scl_local;
      -------------------------------------------------  
      -- START DETECTION
      -------------------------------------------------  
      start_rising_edge  <= start = '1' and start_prev = '0';
      start_falling_edge <= start = '0' and start_prev = '1';
      start_prev         <= start;
    end if;
  end process;

  fsm_process : process(addr, clk, rw, start_rising_edge, state) is
  begin
    if rising_edge(clk) then
      ---------------------------------------------------
      -- I2C STATE MACHINE
      ---------------------------------------------------
      case state is

        when idle_state =>

          slave_ack <= '0';
          if start_rising_edge then
            done       <= '0';
            i          <= addrwidth;
            ready      <= '0';
            state      <= addr_state;
            tx_addr    <= addr & rw;
            sda_enable <= '1';
            sda_local  <= '0';
          else
            ready      <= '1';
            sda_local  <= '0';
            sda_enable <= '0';
            scl_enable <= '0';
            done       <= '0';
          end if;

        when addr_state =>

          scl_enable <= '1';
          if scl_falling_edge then
            if i > -1 then
              sda_local <= tx_addr(i);
            end if;
            i <= i - 1;
          end if;
          if i = -2 then
            sda_enable <= '0';
          end if;

          if scl_rising_edge and i = -2 then
            --------------------------------------------
            -- ACK
            --------------------------------------------
            if sda = '0' then
              slave_ack  <= '1';
              sda_enable <= not rw;
              state      <= data_state;
              i          <= datawidth - 1;
            --------------------------------------------
            --NACK
            --------------------------------------------
            else
              state <= idle_state;
            end if;
          end if;

        when data_state =>

          slave_ack <= '0';
          if rw     <= '0' then
            --------------------------------------------
            -- WRITE
            --------------------------------------------
            if scl_falling_edge then
              if i > -1 then
                sda_local <= tx_data(i);
              end if;
              i <= i - 1;
            end if;
            if i = -2 then
              sda_enable <= '0';
            end if;

            if scl_rising_edge and i = -2 then
              --------------------------------------------
              -- ACK
              --------------------------------------------
              if sda = '0' then
                slave_ack <= '1';
                state     <= idle_state;
                done      <= '1';
              --------------------------------------------
              --NACK
              --------------------------------------------
              else
                state <= idle_state;
              end if;
            end if;

          else
            --------------------------------------------
            -- READ
            --------------------------------------------
            rx_data   <= (others => '0');
            sda_enable <= '0';
            rx_data    <= (others => '0');
            if scl_rising_edge then
              if i > -1 then
                rx_data_temp(i) <= sda;
              end if;
              i <= i - 1;
            end if;
            if i = -2 then
              rx_data <= rx_data_temp;
              state   <= idle_state;
              done    <= '1';
            end if;

          end if;

        when others =>

          -- nothing

      end case;
    end if;
  end process;

  scl <= scl_local when scl_enable = '1' else 'Z';
  sda <= sda_local when sda_enable = '1' else 'Z';

end architecture;
