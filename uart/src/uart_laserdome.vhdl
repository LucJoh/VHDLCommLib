library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity uart_tx is
  port (clk   : in  std_logic;
        reset : in  std_logic;
        tx    : out std_logic);
end uart_tx;

architecture Behavioral of uart_tx is
  type state is (ready, start, stop);
  signal present_state : state     := ready;
  signal store         : std_logic_vector(7 downto 0);
  signal number        : std_logic_vector(7 downto 0);
  signal two           : std_logic_vector(7 downto 0);
  signal baud_rate     : std_logic := '0';
--signal baud_clk : std_logic;
--signal baud_reg : std_logic;
  signal begin1        : std_logic := '0';
  signal number_count  : integer   := 0;
  signal clk_count     : integer range 0 to 500000;
begin

  process(clk, reset)
  begin
    if reset = '0' then
      clk_count    <= 0;
      number_count <= 0;
      begin1       <= '0';
    else
      if rising_edge(clk) then
        if baud_rate = '1' then
          if clk_count < 32*780 then
            clk_count <= clk_count + 1;
            begin1    <= '0';
          else
            number_count <= number_count + 1;
            begin1       <= '1';
            clk_count    <= 0;
            if number_count = 10 then
              number_count <= 0;
            end if;
          end if;
        end if;
      end if;
    end if;

    case number_count is
      when 0 =>
        number <= x"30";
      when 1 =>
        number <= "00110001";
      when 2 =>
        number <= x"32";
      when 3 =>
        number <= x"33";
      when 4 =>
        number <= x"34";
      when 5 =>
        number <= x"35";
      when 6 =>
        number <= x"36";
      when 7 =>
        number <= x"37";
      when 8 =>
        number <= x"38";
      when 9 =>
        number <= x"39";
      when 10 =>
        number <= x"58";                -- this will not be displayed
      when others =>
        number <= x"00";
    end case;



  end process;

  process(clk, reset)
    variable baud_count : integer range 0 to 651;
  begin
    if reset = '0' then
      baud_count := 0;
    else
      if rising_edge(clk) then
        if baud_count = 651 then        -- 100 MHz / (9600 * 16)
          baud_rate  <= '1';
          baud_count := 0;
        else
          baud_count := baud_count + 1;
          baud_rate  <= '0';
        end if;
      end if;
    end if;
  end process;

--  baud_reg <= baud_rate when rising_edge(clk);
--  baud_clk <= not baud_reg and baud_rate;
  store <= number;

  process(clk, baud_rate, begin1, reset)
    variable i : integer := 0;
  --variable j : integer := 0;
  begin
    if reset = '0' then
      present_state <= ready;
      i             := 0;
    else
      if rising_Edge(clk) then
        if baud_rate = '1' then
          if present_state = ready then
            tx <= '1';
            if begin1 = '1' then
              tx            <= '0';
              present_state <= start;
            --store <= number;
            end if;
          end if;

          if present_state = start then
            i := i + 1;

            if i = 16 then
              tx <= store(0);
            end if;

            if i = 32 then
              tx <= store(1);
            end if;

            if i = 48 then
              tx <= store(2);
            end if;

            if i = 64 then
              tx <= store(3);
            end if;

            if i = 80 then
              tx <= store(4);
            end if;

            if i = 96 then
              tx <= store(5);
            end if;

            if i = 112 then
              tx <= store(6);
            end if;

            if i = 128 then
              tx <= store(7);
            end if;

            if i = 144 then
              tx <= '1';
            end if;

            if i = 160 then
              i             := 0;
              present_state <= ready;
            end if;
          end if;
        end if;
      end if;
    end if;

  end process;

end Behavioral;
