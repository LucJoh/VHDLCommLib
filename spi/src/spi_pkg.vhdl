library ieee;
use ieee.std_logic_1164.all;

package spi_pkg is

    constant datalength : integer := 8;

    type spi_in_type is record
        enable : std_logic;
        tx     : std_logic_vector(datalength-1 downto 0);
        miso   : std_logic;
    end record;

    type spi_out_type is record
        rx   : std_logic_vector(datalength-1 downto 0);
        mosi : std_logic;
        sclk : std_logic;
        cs   : std_logic;
    end record;

    component spi is
        port(
            clk     : in  std_logic;
            rstn    : in  std_logic;
            spi_in  : in  spi_in_type;
            spi_out : out spi_out_type
            );
    end component;

end package;
