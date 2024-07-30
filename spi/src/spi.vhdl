library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity spi is
  port (clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic;
        data_out : out std_logic;
        cs       : out std_logic;
        sclk     : out std_logic;
        mosi     : out std_logic;
        miso     : in  std_logic);
end spi;

architecture behavioral of spi is

begin

  process(clk, reset)
  begin
    if reset = '1' then
    -- reset the state machine
    elsif rising_edge(clk) then
    -- state machine

    end if;
  end process;

end behavioral;

